import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessQueryFilters {
  const BusinessQueryFilters({
    required this.center,
    this.keyword,
    this.categoryId,
    this.radiusKm = 15,
    this.limit = 20,
  });

  final GeoPoint center;
  final String? keyword;
  final String? categoryId;
  final double radiusKm;
  final int limit;

  BusinessQueryFilters copyWith({
    GeoPoint? center,
    String? keyword,
    String? categoryId,
    double? radiusKm,
    int? limit,
  }) {
    return BusinessQueryFilters(
      center: center ?? this.center,
      keyword: keyword ?? this.keyword,
      categoryId: categoryId ?? this.categoryId,
      radiusKm: radiusKm ?? this.radiusKm,
      limit: limit ?? this.limit,
    );
  }

  String cacheKey() {
    final buffer = StringBuffer()
      ..write(center.latitude.toStringAsFixed(4))
      ..write('|')
      ..write(center.longitude.toStringAsFixed(4))
      ..write('|')
      ..write(keyword?.toLowerCase() ?? '')
      ..write('|')
      ..write(categoryId ?? '')
      ..write('|')
      ..write(radiusKm.toStringAsFixed(1))
      ..write('|')
      ..write(limit);
    return buffer.toString();
  }
}
