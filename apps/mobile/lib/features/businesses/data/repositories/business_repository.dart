import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../../domain/business_query_filters.dart';
import '../../domain/geohash.dart';
import '../models/business.dart';
import '../models/business_category.dart';

class BusinessPage {
  BusinessPage({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<Business> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

class _CacheEntry {
  _CacheEntry({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<Business> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

class BusinessRepository {
  BusinessRepository(
    this._firestore, {
    FirebaseStorage? storage,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _storage = storage ?? FirebaseStorage.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('businesses');

  CollectionReference<Map<String, dynamic>> get _categoriesCollection =>
      _firestore.collection('categories');

  final _cache = LinkedHashMap<String, _CacheEntry>(
    equals: (a, b) => a == b,
    hashCode: (key) => key.hashCode,
  );

  Future<BusinessPage> fetchBusinesses({
    required BusinessQueryFilters filters,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final cacheKey = filters.cacheKey();
    if (startAfter == null && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      return BusinessPage(
        items: cached.items,
        lastDocument: cached.lastDocument,
        hasMore: cached.hasMore,
      );
    }

    Query<Map<String, dynamic>> query = _collection.where(
      'approved',
      isEqualTo: true,
    );

    if (filters.categoryId != null && filters.categoryId!.isNotEmpty) {
      query = query.where('categoryId', isEqualTo: filters.categoryId);
    }

    final hasRadiusFilter = filters.radiusKm > 0;

    if (hasRadiusFilter) {
      final bounds = GeoHashHelper.boundsFor(filters.center, filters.radiusKm);
      query = query
          .where('geohash', isGreaterThanOrEqualTo: bounds.start)
          .where('geohash', isLessThanOrEqualTo: bounds.end);
    }

    final effectiveLimit = hasRadiusFilter ? filters.limit * 2 : filters.limit;

    query = query
        .orderBy('geohash')
        .orderBy('updatedAt', descending: true)
        .limit(effectiveLimit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();

    final keyword = filters.keyword?.toLowerCase().trim();
    final shouldFilterByRadius = filters.radiusKm > 0;

    final items = snapshot.docs.map(Business.fromDocument).where((business) {
      final matchesKeyword = keyword == null || keyword.isEmpty
          ? true
          : business.matchesKeyword(keyword);
      final matchesRadius =
          !shouldFilterByRadius ||
          business.distanceInKm(
                latitude: filters.center.latitude,
                longitude: filters.center.longitude,
              ) <=
              filters.radiusKm;
      return matchesKeyword && matchesRadius;
    }).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : startAfter;
    final hasMore = snapshot.docs.length == effectiveLimit;

    if (startAfter == null) {
      _cache[cacheKey] = _CacheEntry(
        items: items,
        lastDocument: lastDoc,
        hasMore: hasMore,
      );
    } else {
      final previous = _cache[cacheKey];
      if (previous != null) {
        _cache[cacheKey] = _CacheEntry(
          items: [...previous.items, ...items],
          lastDocument: lastDoc,
          hasMore: hasMore,
        );
      }
    }

    return BusinessPage(items: items, lastDocument: lastDoc, hasMore: hasMore);
  }

  Future<Business?> fetchBusinessById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) return null;
    return Business.fromDocument(snapshot);
  }

  Future<List<BusinessCategory>> fetchCategories() async {
    final snapshot = await _categoriesCollection.get();
    return snapshot.docs
        .map((doc) => BusinessCategory.fromMap(doc.id, doc.data()))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Stream<List<BusinessCategory>> watchCategories() {
    return _categoriesCollection.snapshots().map(
      (snapshot) =>
          snapshot.docs
              .map((doc) => BusinessCategory.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
    );
  }

  void clearCache() {
    _cache.clear();
  }

  Future<Business?> fetchBusinessForOwner(String ownerId) async {
    final snapshot = await _collection
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return Business.fromDocument(snapshot.docs.first);
  }

  Future<void> upsertBusiness({
    required String ownerId,
    String? documentId,
    required String name,
    required String description,
    required String categoryId,
    required GeoPoint location,
    required List<String> images,
    Business? existing,
    String? phoneNumber,
    String? whatsappNumber,
    String? contactEmail,
    String? website,
    String? instagram,
    String? facebook,
    String? addressLine,
    String? priceInfo,
    String? regionLabel,
  }) async {
    final docRef = documentId != null
        ? _collection.doc(documentId)
        : _collection.doc(ownerId);

    final keywords = BusinessRepository.buildSearchKeywords([
      name,
      description,
      categoryId,
      addressLine ?? '',
      regionLabel ?? '',
    ]);

    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'location': location,
      'locationLat': location.latitude,
      'locationLng': location.longitude,
      'ownerId': ownerId,
      'images': images,
      'searchKeywords': keywords,
      'updatedAt': FieldValue.serverTimestamp(),
      'geohash': GeoHashHelper.encode(
        location.latitude,
        location.longitude,
        precision: 9,
      ),
    };

    if (addressLine != null && addressLine.isNotEmpty) {
      data['addressLine'] = addressLine.trim();
    }
    if (regionLabel != null && regionLabel.isNotEmpty) {
      data['regionLabel'] = regionLabel.trim();
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      data['phoneNumber'] = phoneNumber.trim();
    }
    if (whatsappNumber != null && whatsappNumber.isNotEmpty) {
      data['whatsappNumber'] = whatsappNumber.trim();
    }
    if (contactEmail != null && contactEmail.isNotEmpty) {
      data['contactEmail'] = contactEmail.trim();
    }
    if (website != null && website.isNotEmpty) {
      data['website'] = website.trim();
    }
    if (instagram != null && instagram.isNotEmpty) {
      data['instagram'] = instagram.trim();
    }
    if (facebook != null && facebook.isNotEmpty) {
      data['facebook'] = facebook.trim();
    }
    if (priceInfo != null && priceInfo.isNotEmpty) {
      data['priceInfo'] = priceInfo.trim();
    }

    if (existing == null) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['approved'] = false;
      data['plan'] = 'free';
    } else {
      data['createdAt'] = Timestamp.fromDate(existing.createdAt);
      data['approved'] = existing.approved;
      data['plan'] = existing.plan;
    }

    await docRef.set(data, SetOptions(merge: false));
    clearCache();
  }

  Future<String> uploadBusinessImage({
    required String ownerId,
    required String businessId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    final ref = _storage
        .ref()
        .child('businesses')
        .child(ownerId)
        .child('$fileName.jpg');

    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final downloadUrl = await ref.getDownloadURL();

    final docRef = _collection.doc(businessId);
    await docRef.update({
      'images': FieldValue.arrayUnion([downloadUrl]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    clearCache();
    return downloadUrl;
  }

  @visibleForTesting
  static List<String> buildSearchKeywords(List<String> sources) {
    final buffer = <String>{};
    for (final source in sources) {
      final sanitized = source
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
          .split(RegExp(r'\s+'))
          .where((token) => token.trim().length >= 2);
      buffer.addAll(sanitized);
    }
    return buffer.toList();
  }

  Stream<List<Business>> watchPendingBusinesses() {
    return _collection
        .where('approved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Business.fromDocument).toList());
  }

  Future<void> approveBusiness(String businessId) async {
    final callable = _functions.httpsCallable('approveBusiness');
    try {
      await callable.call({'businessId': businessId});
    } on FirebaseFunctionsException catch (error) {
      if (error.code == 'unavailable') {
        await _approveBusinessLocally(businessId);
      } else {
        throw Exception('Failed to approve business: ${error.message}');
      }
    } on MissingPluginException {
      await _approveBusinessLocally(businessId);
    }
    clearCache();
  }

  Future<void> _approveBusinessLocally(String businessId) async {
    final updates = <String, dynamic>{
      'approved': true,
      'approvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    final approvingAdminId = _auth.currentUser?.uid;
    if (approvingAdminId != null && approvingAdminId.isNotEmpty) {
      updates['approvedBy'] = approvingAdminId;
    }
    await _collection.doc(businessId).update(updates);
  }
}
