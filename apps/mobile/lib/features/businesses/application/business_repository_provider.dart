import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/business.dart';
import '../data/repositories/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepository(
    FirebaseFirestore.instance,
    functions: FirebaseFunctions.instance,
  );
});

final businessCategoriesProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(businessRepositoryProvider).watchCategories(),
);

final ownerBusinessProvider = FutureProvider.autoDispose
    .family<Business?, String>((ref, ownerId) {
      return ref
          .watch(businessRepositoryProvider)
          .fetchBusinessForOwner(ownerId);
    });

final businessByIdProvider = FutureProvider.autoDispose
    .family<Business?, String>((ref, businessId) {
      return ref
          .watch(businessRepositoryProvider)
          .fetchBusinessById(businessId);
    });
