import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class Business {
  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.geohash,
    required this.ownerId,
    required this.plan,
    required this.images,
    required this.approved,
    required this.createdAt,
    required this.updatedAt,
    required this.searchKeywords,
    this.phoneNumber,
    this.whatsappNumber,
    this.contactEmail,
    this.website,
    this.instagram,
    this.facebook,
    this.addressLine,
    this.priceInfo,
    this.regionLabel,
  });

  factory Business.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return Business(
      id: snapshot.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      location: data['location'] as GeoPoint? ?? const GeoPoint(0, 0),
      geohash: data['geohash'] as String? ?? '',
      ownerId: data['ownerId'] as String? ?? '',
      plan: data['plan'] as String? ?? 'free',
      images: (data['images'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      approved: data['approved'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      searchKeywords: (data['searchKeywords'] as List<dynamic>? ?? [])
          .whereType<String>()
          .map((keyword) => keyword.toLowerCase())
          .toList(),
      phoneNumber: data['phoneNumber'] as String?,
      whatsappNumber: data['whatsappNumber'] as String?,
      contactEmail: data['contactEmail'] as String?,
      website: data['website'] as String?,
      instagram: data['instagram'] as String?,
      facebook: data['facebook'] as String?,
      addressLine: data['addressLine'] as String?,
      priceInfo: data['priceInfo'] as String?,
      regionLabel: data['regionLabel'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String categoryId;
  final GeoPoint location;
  final String geohash;
  final String ownerId;
  final String plan;
  final List<String> images;
  final bool approved;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> searchKeywords;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? contactEmail;
  final String? website;
  final String? instagram;
  final String? facebook;
  final String? addressLine;
  final String? priceInfo;
  final String? regionLabel;

  String get nameLowercase => name.toLowerCase();

  bool matchesKeyword(String keyword) {
    if (keyword.isEmpty) return true;
    final lowerKeyword = keyword.toLowerCase();
    if (nameLowercase.contains(lowerKeyword)) return true;
    return searchKeywords.contains(lowerKeyword);
  }

  double distanceInKm({required double latitude, required double longitude}) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(latitude - location.latitude);
    final dLon = _degreesToRadians(longitude - location.longitude);

    final lat1 = _degreesToRadians(location.latitude);
    final lat2 = _degreesToRadians(latitude);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * (pi / 180.0);

  bool get hasDirectContact =>
      (phoneNumber != null && phoneNumber!.isNotEmpty) ||
      (whatsappNumber != null && whatsappNumber!.isNotEmpty) ||
      (contactEmail != null && contactEmail!.isNotEmpty);

  String googleMapsUrl() {
    return 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
  }

  String wazeUrl() {
    return 'https://waze.com/ul?ll=${location.latitude},${location.longitude}&navigate=yes';
  }
}
