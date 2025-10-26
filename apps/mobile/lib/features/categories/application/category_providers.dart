import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../businesses/application/business_repository_provider.dart';
import '../../businesses/data/models/business.dart';
import '../../businesses/data/models/business_category.dart';
import '../../businesses/domain/business_query_filters.dart';

class CategoryBusinessesRequest {
  const CategoryBusinessesRequest({
    required this.categoryId,
    required this.center,
    required this.radiusKm,
  });

  final String categoryId;
  final GeoPoint center;
  final double radiusKm;

  @override
  bool operator ==(Object other) {
    return other is CategoryBusinessesRequest &&
        other.categoryId == categoryId &&
        other.center.latitude == center.latitude &&
        other.center.longitude == center.longitude &&
        other.radiusKm == radiusKm;
  }

  @override
  int get hashCode => Object.hash(
        categoryId,
        center.latitude,
        center.longitude,
        radiusKm,
      );
}

final categoryBusinessesProvider = FutureProvider.autoDispose
    .family<List<Business>, CategoryBusinessesRequest>((ref, request) async {
      final repository = ref.watch(businessRepositoryProvider);
      final filters = BusinessQueryFilters(
        center: request.center,
        categoryId: request.categoryId,
        radiusKm: request.radiusKm,
        limit: 50,
      );
      final page = await repository.fetchBusinesses(filters: filters);
      return page.items;
    });

final categoryByIdProvider =
    Provider.autoDispose.family<BusinessCategory?, String>((ref, categoryId) {
      final asyncCategories = ref.watch(businessCategoriesProvider);
      return asyncCategories.maybeWhen(
        data: (categories) {
          try {
            return categories.firstWhere((c) => c.id == categoryId);
          } catch (_) {
            return null;
          }
        },
        orElse: () => null,
      );
    });
