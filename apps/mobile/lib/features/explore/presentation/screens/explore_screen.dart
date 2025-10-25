import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_search_controller.dart';
import '../../../businesses/data/models/business.dart';
import '../../../businesses/presentation/widgets/business_list_tile.dart';
import '../../../location/application/location_controller.dart';

bool kForceExploreTestMode = false;
bool get _kIsRunningTests =>
    kForceExploreTestMode ||
    const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  Set<Marker> _buildMarkers(List<Business> businesses, LatLng userCenter) {
    return businesses
        .map(
          (business) => Marker(
            markerId: MarkerId(business.id),
            position: LatLng(
              business.location.latitude,
              business.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: business.name,
              snippet:
                  '${business.distanceInKm(latitude: userCenter.latitude, longitude: userCenter.longitude).toStringAsFixed(1)} km',
            ),
          ),
        )
        .toSet();
  }

  Future<void> _animateCameraTo(LatLng target, {double zoom = 13}) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(target, zoom));
  }

  Future<void> _animateToBusiness(Business business) async {
    await _animateCameraTo(
      LatLng(business.location.latitude, business.location.longitude),
      zoom: 15,
    );
  }

  void _openBusinessDetails(Business business) {
    if (!mounted) return;
    context.pushNamed(
      'business-details',
      pathParameters: {'id': business.id},
      extra: business,
    );
  }

  void _requestLocationPermission() {
    ref.read(locationControllerProvider.notifier).requestPermission();
  }

  void _openLocationSettings() {
    ref.read(locationControllerProvider.notifier).openSystemLocationSettings();
  }

  void _refreshLocation() {
    ref.read(locationControllerProvider.notifier).refresh();
  }

  Widget? _buildLocationBanner(
    LocationState state,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    late final String message;
    late final VoidCallback action;
    late final String actionLabel;

    switch (state.status) {
      case LocationStatus.permissionRequired:
        message = l10n.exploreLocationPermissionRequired;
        actionLabel = l10n.exploreLocationPermissionCta;
        action = _requestLocationPermission;
        break;
      case LocationStatus.permissionDeniedForever:
        message = l10n.exploreLocationPermissionDeniedForever;
        actionLabel = l10n.exploreLocationOpenSettings;
        action = _openLocationSettings;
        break;
      case LocationStatus.serviceDisabled:
        message = l10n.exploreLocationServicesDisabled;
        actionLabel = l10n.exploreLocationOpenSettings;
        action = _openLocationSettings;
        break;
      case LocationStatus.error:
        message = state.errorMessage ?? l10n.exploreLocationErrorGeneric;
        actionLabel = l10n.exploreLocationRetry;
        action = _refreshLocation;
        break;
      case LocationStatus.initial:
      case LocationStatus.checking:
      case LocationStatus.ready:
        return null;
    }

    return Card(
      margin: const EdgeInsets.only(top: 16),
      color: theme.colorScheme.errorContainer,
      child: ListTile(
        leading: Icon(
          Icons.location_off,
          color: theme.colorScheme.onErrorContainer,
        ),
        title: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: TextButton(
          onPressed: action,
          child: Text(
            actionLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    ref.listen<LocationState>(locationControllerProvider, (previous, next) {
      if (!_mapController.isCompleted) return;
      if (previous?.center == next.center) return;
      if (next.status != LocationStatus.ready) return;
      unawaited(
        _animateCameraTo(
          LatLng(next.center.latitude, next.center.longitude),
          zoom: 13,
        ),
      );
    });
    final businessesAsync = ref.watch(nearbyBusinessesProvider);
    final locationState = ref.watch(locationControllerProvider);
    final center = locationState.center;
    final hasLocation = locationState.status == LocationStatus.ready;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle),
            Text(l10n.appTagline, style: theme.textTheme.labelMedium),
          ],
        ),
      ),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to load businesses.\n${error.toString()}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (businesses) {
          final centerLatLng = LatLng(center.latitude, center.longitude);
          final markers = _buildMarkers(businesses, centerLatLng);
          final banner = _buildLocationBanner(locationState, theme, l10n);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.exploreHeadline,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (banner != null) banner,
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 280,
                          child: _kIsRunningTests
                              ? Container(
                                  color: theme.colorScheme.surfaceContainerHigh,
                                  child: const Center(
                                    child: Icon(Icons.map_outlined, size: 48),
                                  ),
                                )
                              : Stack(
                                  children: [
                                    GoogleMap(
                                      markers: markers,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(
                                          center.latitude,
                                          center.longitude,
                                        ),
                                        zoom: hasLocation ? 13 : 11,
                                      ),
                                      myLocationEnabled: hasLocation,
                                      myLocationButtonEnabled: false,
                                      zoomControlsEnabled: false,
                                      onMapCreated: (controller) {
                                        if (!_mapController.isCompleted) {
                                          _mapController.complete(controller);
                                        }
                                      },
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: FloatingActionButton.small(
                                        heroTag: 'recenter-map',
                                        backgroundColor: theme
                                            .colorScheme
                                            .surfaceContainerHigh,
                                        onPressed: () => _animateCameraTo(
                                          LatLng(
                                            center.latitude,
                                            center.longitude,
                                          ),
                                          zoom: hasLocation ? 14 : 11,
                                        ),
                                        child: Icon(
                                          Icons.my_location,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  final business = businesses[index];
                  final distanceKm = business.distanceInKm(
                    latitude: center.latitude,
                    longitude: center.longitude,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BusinessListTile(
                      business: business,
                      distanceKm: distanceKm,
                      onTap: () => _openBusinessDetails(business),
                      onViewOnMap: () => _animateToBusiness(business),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
