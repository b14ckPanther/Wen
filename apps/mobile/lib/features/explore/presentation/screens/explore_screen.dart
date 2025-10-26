import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../../businesses/application/business_search_controller.dart';
import '../../../businesses/data/models/business.dart';
import '../../../businesses/data/models/business_category.dart';
import '../../../businesses/presentation/widgets/business_list_tile.dart';
import '../../../location/application/location_controller.dart';
import '../../../location/domain/location_region.dart';

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

  void _openCategory(String categoryId) {
    if (!mounted) return;
    context.pushNamed(
      'category-detail',
      pathParameters: {'id': categoryId},
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
    final locationNotifier = ref.read(locationControllerProvider.notifier);
    final center = locationState.center;
    final hasLocation = locationState.status == LocationStatus.ready;
    final useDeviceLocation = locationState.useDeviceLocation;
    final regions = ref.watch(presetRegionsProvider);
    final categoriesAsync = ref.watch(businessCategoriesProvider);
    LocationRegion? selectedRegion;
    if (!useDeviceLocation && regions.isNotEmpty) {
      selectedRegion = regions.firstWhere(
        (region) => region.id == locationState.selectedRegionId,
        orElse: () => regions.first,
      );
    }

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
                      const SizedBox(height: 16),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                useDeviceLocation
                                    ? l10n.exploreUseMyLocationTitle
                                    : l10n.exploreManualRegionTitle,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile.adaptive(
                                value: useDeviceLocation,
                                onChanged: (value) {
                                  locationNotifier.setUseDeviceLocation(value);
                                  if (!value && regions.isNotEmpty) {
                                    locationNotifier.selectPresetRegion(
                                      regions.first,
                                    );
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                                title: Text(l10n.exploreUseMyLocationToggle),
                                subtitle: Text(
                                  useDeviceLocation
                                      ? l10n.exploreUseMyLocationSubtitle
                                      : l10n
                                          .exploreManualRegionToggleSubtitle,
                                ),
                              ),
                              if (!useDeviceLocation) ...[
                                const SizedBox(height: 12),
                                DropdownMenu<LocationRegion>(
                                  initialSelection: selectedRegion,
                                  label: Text(l10n.exploreManualRegionLabel),
                                  dropdownMenuEntries: [
                                    for (final region in regions)
                                      DropdownMenuEntry(
                                        value: region,
                                        label: region.label(l10n),
                                      ),
                                  ],
                                  onSelected: (region) {
                                    if (region != null) {
                                      locationNotifier.selectPresetRegion(
                                        region,
                                      );
                                    }
                                  },
                                ),
                              ],
                              const SizedBox(height: 12),
                              FilledButton.tonalIcon(
                                onPressed: useDeviceLocation
                                    ? _refreshLocation
                                    : () {
                                        final region = selectedRegion ??
                                            (regions.isNotEmpty
                                                ? regions.first
                                                : null);
                                        if (region != null) {
                                          locationNotifier.selectPresetRegion(
                                            region,
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.my_location),
                                label: Text(l10n.exploreRefreshLocation),
                              ),
                              if (banner != null) ...[
                                const SizedBox(height: 12),
                                banner,
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => context.goNamed('search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.exploreSearchShortcut,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Text(
                                l10n.exploreSearchAction,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      categoriesAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Failed to load categories: $error',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ),
                        data: (categories) {
                          final topLevel = categories
                              .where(
                                (c) =>
                                    c.parentId == null ||
                                    (c.parentId?.isEmpty ?? true),
                              )
                              .toList();
                          if (topLevel.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.exploreFeaturedCategories,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 140,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: topLevel.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final category = topLevel[index];
                                    return _CategoryPreviewCard(
                                      category: category,
                                      onTap: () =>
                                          _openCategory(category.id),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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

class _CategoryPreviewCard extends StatelessWidget {
  const _CategoryPreviewCard({
    required this.category,
    required this.onTap,
  });

  final BusinessCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.85),
              theme.colorScheme.primaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.category_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const Spacer(),
            Text(
              category.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
