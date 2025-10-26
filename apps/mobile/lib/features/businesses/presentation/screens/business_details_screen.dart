import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/business_repository_provider.dart';
import '../../data/models/business.dart';
import '../../data/models/business_category.dart';
import '../../../location/application/location_controller.dart';

bool kForceBusinessDetailsTestMode = false;
bool get _kIsRunningTests =>
    kForceBusinessDetailsTestMode ||
    const bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({
    super.key,
    required this.businessId,
    this.initialBusiness,
  });

  final String businessId;
  final Business? initialBusiness;

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  Future<void> _launchUri(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${uri.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(businessCategoriesProvider);
    final asyncBusiness = ref.watch(businessByIdProvider(widget.businessId));
    final locationCenter = ref.watch(activeGeoCenterProvider);
    final locationState = ref.watch(locationControllerProvider);

    final business = asyncBusiness.asData?.value ?? widget.initialBusiness;
    final isLoading = asyncBusiness.isLoading && business == null;
    final error = asyncBusiness.asError?.error;

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (business == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error?.toString() ?? l10n.businessDetailsNotFound,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final distanceKm = business.distanceInKm(
      latitude: locationCenter.latitude,
      longitude: locationCenter.longitude,
    );
    final allowMyLocation = locationState.status == LocationStatus.ready;
    final phoneUri = business.phoneNumber == null ||
            business.phoneNumber!.isEmpty
        ? null
        : Uri(scheme: 'tel', path: business.phoneNumber);
    final whatsappUri = business.whatsappNumber == null ||
            business.whatsappNumber!.isEmpty
        ? null
        : Uri.parse(
            'https://wa.me/${business.whatsappNumber!.replaceAll(RegExp(r'[^0-9+]'), '').replaceAll('+', '')}',
          );
    final emailUri = business.contactEmail == null ||
            business.contactEmail!.isEmpty
        ? null
        : Uri(
            scheme: 'mailto',
            path: business.contactEmail,
          );
    final websiteUri =
        business.website == null || business.website!.isEmpty
            ? null
            : Uri.parse(business.website!);
    final instagramUri =
        business.instagram == null || business.instagram!.isEmpty
            ? null
            : Uri.parse(
                business.instagram!.startsWith('http')
                    ? business.instagram!
                    : 'https://instagram.com/${business.instagram!.replaceAll('@', '')}',
              );
    final facebookUri =
        business.facebook == null || business.facebook!.isEmpty
            ? null
            : Uri.parse(
                business.facebook!.startsWith('http')
                    ? business.facebook!
                    : 'https://facebook.com/${business.facebook}',
              );
    final googleMapsUri = Uri.parse(business.googleMapsUrl());
    final wazeUri = Uri.parse(business.wazeUrl());

    return Scaffold(
      appBar: AppBar(
        title: Text(business.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.businessDetailsRefreshTooltip,
            onPressed: () {
              ref.invalidate(businessByIdProvider(widget.businessId));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(businessByIdProvider(widget.businessId));
          await ref.read(businessByIdProvider(widget.businessId).future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            if (business.images.isNotEmpty)
              CachedNetworkImage(
                imageUrl: business.images.first,
                height: 220,
                fit: BoxFit.cover,
                placeholder: (context, _) => Container(
                  height: 220,
                  color: theme.colorScheme.surfaceContainerHigh,
                ),
                errorWidget: (context, _, __) => Container(
                  height: 220,
                  color: theme.colorScheme.surfaceContainerHigh,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 32,
                  ),
                ),
              )
            else
              Container(
                height: 200,
                color: theme.colorScheme.surfaceContainerHigh,
                child: Center(
                  child: Icon(
                    Icons.store_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Chip(
                        label: Text(business.plan.toUpperCase()),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        labelStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Chip(
                        label: Text('${distanceKm.toStringAsFixed(1)} km'),
                        avatar: const Icon(Icons.place_outlined, size: 16),
                      ),
                      categoriesAsync.when(
                        data: (categories) {
                          BusinessCategory? category;
                          try {
                            category = categories.firstWhere(
                              (c) => c.id == business.categoryId,
                            );
                          } catch (_) {
                            category = null;
                          }
                          if (category == null) {
                            return const SizedBox.shrink();
                          }
                          return Chip(
                            label: Text(category.name),
                            avatar: const Icon(
                              Icons.category_outlined,
                              size: 16,
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(business.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (phoneUri != null)
                        FilledButton.icon(
                          onPressed: () => _launchUri(phoneUri),
                          icon: const Icon(Icons.call),
                          label: Text(l10n.businessDetailsCallAction),
                        ),
                      if (whatsappUri != null)
                        FilledButton.icon(
                          onPressed: () => _launchUri(whatsappUri),
                          icon: const Icon(Icons.chat_outlined),
                          label: Text(l10n.businessDetailsWhatsAppAction),
                        ),
                      FilledButton.icon(
                        onPressed: () => _launchUri(googleMapsUri),
                        icon: const Icon(Icons.map_outlined),
                        label: Text(l10n.businessDetailsMapsAction),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => _launchUri(wazeUri),
                        icon: const Icon(Icons.directions_car),
                        label: const Text('Waze'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.businessDetailsLocationTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      child: _kIsRunningTests
                          ? Container(
                              color: theme.colorScheme.surfaceContainerHigh,
                              child: const Center(
                                child: Icon(Icons.map_outlined, size: 40),
                              ),
                            )
                          : GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  business.location.latitude,
                                  business.location.longitude,
                                ),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: MarkerId(business.id),
                                  position: LatLng(
                                    business.location.latitude,
                                    business.location.longitude,
                                  ),
                                  infoWindow: InfoWindow(title: business.name),
                                ),
                              },
                              myLocationEnabled: allowMyLocation,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              onMapCreated: (controller) {
                                if (!_mapController.isCompleted) {
                                  _mapController.complete(controller);
                                }
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.businessDetailsMetaTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (business.addressLine != null &&
                      business.addressLine!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(l10n.businessAddressLabel),
                      subtitle: Text(business.addressLine!),
                    ),
                  if (business.priceInfo != null &&
                      business.priceInfo!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.local_offer_outlined),
                      title: Text(l10n.businessPriceInfoLabel),
                      subtitle: Text(business.priceInfo!),
                    ),
                  if (business.regionLabel != null &&
                      business.regionLabel!.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: Text(l10n.businessRegionLabel),
                      subtitle: Text(business.regionLabel!),
                    ),
                  if (phoneUri != null)
                    ListTile(
                      leading: const Icon(Icons.call),
                      title: Text(l10n.businessPhoneLabel),
                      subtitle: Text(business.phoneNumber ?? '—'),
                      onTap: () => _launchUri(phoneUri),
                    ),
                  if (emailUri != null)
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(l10n.businessEmailLabel),
                      subtitle: Text(business.contactEmail!),
                      onTap: () => _launchUri(emailUri),
                    ),
                  if (websiteUri != null)
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: Text(l10n.businessWebsiteLabel),
                      subtitle: Text(websiteUri.toString()),
                      onTap: () => _launchUri(websiteUri),
                    ),
                  if (instagramUri != null)
                    ListTile(
                      leading: const Icon(Icons.camera_alt_outlined),
                      title: Text(l10n.businessInstagramLabel),
                      subtitle: Text(instagramUri.toString()),
                      onTap: () => _launchUri(instagramUri),
                    ),
                  if (facebookUri != null)
                    ListTile(
                      leading: const Icon(Icons.facebook),
                      title: Text(l10n.businessFacebookLabel),
                      subtitle: Text(facebookUri.toString()),
                      onTap: () => _launchUri(facebookUri),
                    ),
                  ListTile(
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(l10n.businessDetailsUpdatedAtLabel),
                    subtitle: Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(business.updatedAt),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(l10n.businessDetailsApprovalLabel),
                    subtitle: Text(
                      business.approved
                          ? l10n.businessDetailsApprovedStatus
                          : l10n.businessDetailsPendingStatus,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
