import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as fr_legacy;

import '../../location/application/location_controller.dart';
import '../data/models/business.dart';
import '../data/repositories/business_repository.dart';
import '../domain/business_query_filters.dart';
import 'business_repository_provider.dart';

enum BusinessSearchStatus { initial, loading, success, failure }

class BusinessSearchState {
  const BusinessSearchState({
    required this.status,
    required this.filters,
    required this.items,
    required this.hasMore,
    required this.isFetchingMore,
    this.errorMessage,
    this.lastDocument,
  });

  factory BusinessSearchState.initial(BusinessQueryFilters filters) {
    return BusinessSearchState(
      status: BusinessSearchStatus.initial,
      filters: filters,
      items: const [],
      hasMore: true,
      isFetchingMore: false,
    );
  }

  final BusinessSearchStatus status;
  final BusinessQueryFilters filters;
  final List<Business> items;
  final bool hasMore;
  final bool isFetchingMore;
  final String? errorMessage;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;

  BusinessSearchState copyWith({
    BusinessSearchStatus? status,
    BusinessQueryFilters? filters,
    List<Business>? items,
    bool? hasMore,
    bool? isFetchingMore,
    String? errorMessage,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) {
    return BusinessSearchState(
      status: status ?? this.status,
      filters: filters ?? this.filters,
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

class BusinessSearchController extends ChangeNotifier {
  BusinessSearchController(
    this._repository,
    BusinessQueryFilters initialFilters,
  ) : _state = BusinessSearchState.initial(initialFilters) {
    unawaited(search(initialFilters));
  }

  final BusinessRepository _repository;
  BusinessSearchState _state;

  BusinessSearchState get state => _state;

  Future<void> search(BusinessQueryFilters filters) async {
    _state = BusinessSearchState.initial(
      filters,
    ).copyWith(status: BusinessSearchStatus.loading, lastDocument: null);
    notifyListeners();

    try {
      final page = await _repository.fetchBusinesses(filters: filters);
      _state = _state.copyWith(
        status: BusinessSearchStatus.success,
        filters: filters,
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
        errorMessage: null,
      );
    } catch (error) {
      _state = _state.copyWith(
        status: BusinessSearchStatus.failure,
        errorMessage: error.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (!_state.hasMore || _state.isFetchingMore) return;

    _state = _state.copyWith(isFetchingMore: true);
    notifyListeners();

    try {
      final page = await _repository.fetchBusinesses(
        filters: _state.filters,
        startAfter: _state.lastDocument,
      );
      _state = _state.copyWith(
        items: [..._state.items, ...page.items],
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
        isFetchingMore: false,
        errorMessage: null,
      );
    } catch (error) {
      _state = _state.copyWith(
        isFetchingMore: false,
        errorMessage: error.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> updateCenter(GeoPoint center) async {
    final current = _state.filters;
    if (_areGeoPointsClose(current.center, center)) return;
    final updatedFilters = current.copyWith(center: center);
    await search(updatedFilters);
  }

  bool _areGeoPointsClose(GeoPoint a, GeoPoint b) {
    const threshold = 0.0005; // Roughly ~55m
    return (a.latitude - b.latitude).abs() < threshold &&
        (a.longitude - b.longitude).abs() < threshold;
  }
}

final businessSearchControllerProvider =
    fr_legacy.ChangeNotifierProvider.autoDispose<BusinessSearchController>((
      ref,
    ) {
      final repository = ref.watch(businessRepositoryProvider);
      final center = ref.watch(activeGeoCenterProvider);
      final filters = BusinessQueryFilters(center: center);
      final controller = BusinessSearchController(repository, filters);

      ref.listen<GeoPoint>(activeGeoCenterProvider, (previous, next) {
        if (previous == null) return;
        controller.updateCenter(next);
      });

      return controller;
    });

final nearbyBusinessesProvider = FutureProvider.autoDispose((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  final center = ref.watch(activeGeoCenterProvider);
  final filters = BusinessQueryFilters(center: center, radiusKm: 20, limit: 20);
  final page = await repository.fetchBusinesses(filters: filters);
  return page.items;
});
