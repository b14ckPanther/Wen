import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:geolocator/geolocator.dart';
import 'package:state_notifier/state_notifier.dart';

import '../domain/location_region.dart';

const GeoPoint kFallbackGeoCenter = GeoPoint(25.2048, 55.2708);
bool kForceLocationTestMode = false;
bool get _isRunningTests =>
    kForceLocationTestMode ||
    const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

enum LocationStatus {
  initial,
  checking,
  permissionRequired,
  permissionDeniedForever,
  serviceDisabled,
  ready,
  error,
}

const _unset = Object();

@immutable
class LocationState {
  const LocationState({
    required this.status,
    required this.center,
    required this.canRequestPermission,
    required this.isLoading,
    required this.useDeviceLocation,
    this.position,
    this.errorMessage,
    this.selectedRegionId,
  });

  factory LocationState.initial() => const LocationState(
    status: LocationStatus.initial,
    center: kFallbackGeoCenter,
    canRequestPermission: true,
    isLoading: true,
    useDeviceLocation: true,
    selectedRegionId: null,
  );

  final LocationStatus status;
  final GeoPoint center;
  final bool canRequestPermission;
  final bool isLoading;
  final bool useDeviceLocation;
  final Position? position;
  final String? errorMessage;
  final String? selectedRegionId;

  LocationState copyWith({
    LocationStatus? status,
    GeoPoint? center,
    bool? canRequestPermission,
    bool? isLoading,
    Object? position = _unset,
    Object? errorMessage = _unset,
    bool? useDeviceLocation,
    Object? selectedRegionId = _unset,
  }) {
    return LocationState(
      status: status ?? this.status,
      center: center ?? this.center,
      canRequestPermission: canRequestPermission ?? this.canRequestPermission,
      isLoading: isLoading ?? this.isLoading,
      position: position == _unset ? this.position : position as Position?,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      useDeviceLocation: useDeviceLocation ?? this.useDeviceLocation,
      selectedRegionId: selectedRegionId == _unset
          ? this.selectedRegionId
          : selectedRegionId as String?,
    );
  }
}

class LocationController extends StateNotifier<LocationState> {
  LocationController() : super(LocationState.initial());

  Future<void> initialize() async {
    await _resolveLocation();
  }

  Future<void> refresh() async {
    if (!state.useDeviceLocation) return;
    state = state.copyWith(isLoading: true, status: LocationStatus.checking);
    await _resolveLocation();
  }

  Future<void> requestPermission() async {
    try {
      state = state.copyWith(isLoading: true);
      if (_isRunningTests) {
        state = state.copyWith(
          status: LocationStatus.ready,
          center: kFallbackGeoCenter,
          isLoading: false,
          useDeviceLocation: true,
          selectedRegionId: null,
          position: null,
          errorMessage: null,
        );
        return;
      }
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          status: LocationStatus.permissionRequired,
          isLoading: false,
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          status: LocationStatus.permissionDeniedForever,
          canRequestPermission: false,
          isLoading: false,
        );
        return;
      }
      await _resolveLocation();
    } on Exception catch (error) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> openSystemLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> _resolveLocation() async {
    try {
      state = state.copyWith(
        status: LocationStatus.checking,
        isLoading: true,
        errorMessage: null,
      );

      if (!state.useDeviceLocation) {
        state = state.copyWith(
          status: LocationStatus.ready,
          isLoading: false,
        );
        return;
      }

      if (_isRunningTests) {
        state = state.copyWith(
          status: LocationStatus.ready,
          center: kFallbackGeoCenter,
          isLoading: false,
          useDeviceLocation: true,
          selectedRegionId: null,
          position: null,
          errorMessage: null,
        );
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          status: LocationStatus.serviceDisabled,
          isLoading: false,
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          status: LocationStatus.permissionRequired,
          isLoading: false,
          canRequestPermission: true,
        );
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          status: LocationStatus.permissionDeniedForever,
          isLoading: false,
          canRequestPermission: false,
        );
        return;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        state = state.copyWith(
          position: lastKnown,
          center: GeoPoint(lastKnown.latitude, lastKnown.longitude),
          status: LocationStatus.ready,
          isLoading: false,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );
      state = state.copyWith(
        position: position,
        center: GeoPoint(position.latitude, position.longitude),
        status: LocationStatus.ready,
        isLoading: false,
      );
    } on TimeoutException catch (error) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: 'Location timeout: ${error.message ?? ''}'.trim(),
        isLoading: false,
      );
    } on Exception catch (error) {
      state = state.copyWith(
        status: LocationStatus.error,
        errorMessage: error.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> setUseDeviceLocation(bool useDeviceLocation) async {
    if (useDeviceLocation == state.useDeviceLocation) return;
    state = state.copyWith(
      useDeviceLocation: useDeviceLocation,
      selectedRegionId: useDeviceLocation ? null : state.selectedRegionId,
      status: useDeviceLocation ? LocationStatus.checking : LocationStatus.ready,
      isLoading: useDeviceLocation,
      position: useDeviceLocation ? state.position : null,
      errorMessage: null,
    );
    if (useDeviceLocation) {
      await _resolveLocation();
    }
  }

  void selectPresetRegion(LocationRegion region) {
    state = state.copyWith(
      center: region.center,
      status: LocationStatus.ready,
      isLoading: false,
      useDeviceLocation: false,
      selectedRegionId: region.id,
      position: null,
      errorMessage: null,
    );
  }
}

final locationControllerProvider =
    legacy.StateNotifierProvider<LocationController, LocationState>((ref) {
      final controller = LocationController();
      unawaited(controller.initialize());
      return controller;
    });

final activeGeoCenterProvider = Provider<GeoPoint>((ref) {
  final state = ref.watch(locationControllerProvider);
  return state.center;
});

final presetRegionsProvider = Provider<List<LocationRegion>>((ref) {
  return presetRegions;
});
