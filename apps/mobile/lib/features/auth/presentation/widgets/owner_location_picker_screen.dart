import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../location/application/location_controller.dart';

class OwnerLocationPickArgs {
  const OwnerLocationPickArgs({
    required this.initialPosition,
    this.initialAddress,
  });

  final LatLng initialPosition;
  final String? initialAddress;
}

class OwnerLocationPickResult {
  const OwnerLocationPickResult({
    required this.position,
    required this.address,
  });

  final LatLng position;
  final String address;
}

class OwnerLocationPickerScreen extends ConsumerStatefulWidget {
  const OwnerLocationPickerScreen({super.key, required this.args});

  final OwnerLocationPickArgs args;

  @override
  ConsumerState<OwnerLocationPickerScreen> createState() => _OwnerLocationPickerScreenState();
}

class _OwnerLocationPickerScreenState extends ConsumerState<OwnerLocationPickerScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _selectedPosition;
  String? _selectedAddress;
  Set<Marker> _markers = {};
  bool _searching = false;
  bool _initialisedLocation = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.args.initialPosition;
    _selectedAddress = widget.args.initialAddress;
    _markers = {
      Marker(
        markerId: const MarkerId('business-location'),
        position: _selectedPosition,
        draggable: true,
        onDragEnd: _onPositionChanged,
      ),
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _animateCamera(LatLng target) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLng(target));
  }

  Future<void> _reverseGeocode(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final parts = <String?>[
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();
        setState(() {
          _selectedAddress = parts.isNotEmpty ? parts.join(', ') : null;
        });
      }
    } catch (_) {
      // Ignore reverse geocoding errors.
    }
  }

  void _onPositionChanged(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('business-location'),
          position: position,
          draggable: true,
          onDragEnd: _onPositionChanged,
        ),
      };
    });
    unawaited(_reverseGeocode(position));
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() => _searching = true);
    try {
      final results = await locationFromAddress(query);
      if (results.isNotEmpty) {
        final location = results.first;
        final latLng = LatLng(location.latitude, location.longitude);
        _onPositionChanged(latLng);
        await _animateCamera(latLng);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationState = ref.watch(locationControllerProvider);

    if (!_initialisedLocation && locationState.status == LocationStatus.ready) {
      _initialisedLocation = true;
      if (widget.args.initialAddress == null) {
        final center = locationState.center;
        final latLng = LatLng(center.latitude, center.longitude);
        _onPositionChanged(latLng);
        unawaited(_animateCamera(latLng));
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _selectedPosition, zoom: 14),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
              onTap: _onPositionChanged,
              onMapCreated: (controller) {
                if (!_mapController.isCompleted) {
                  _mapController.complete(controller);
                }
              },
            ),
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(24),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _searchAddress(),
                  decoration: InputDecoration(
                    hintText: l10n.authOwnerMapSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _searchController.text.isEmpty
                                ? null
                                : () {
                                    _searchController.clear();
                                  },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(
                        _selectedAddress ?? l10n.authOwnerLocationPlaceholder,
                      ),
                      subtitle: Text(
                        '${_selectedPosition.latitude.toStringAsFixed(5)}, '
                        '${_selectedPosition.longitude.toStringAsFixed(5)}',
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final center = ref.read(locationControllerProvider).center;
                            final latLng = LatLng(center.latitude, center.longitude);
                            _onPositionChanged(latLng);
                            unawaited(_animateCamera(latLng));
                          },
                          icon: const Icon(Icons.my_location),
                          label: Text(l10n.authOwnerUseCurrentLocation),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(
                              OwnerLocationPickResult(
                                position: _selectedPosition,
                                address: _selectedAddress ?? '',
                              ),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: Text(l10n.authOwnerConfirmLocation),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 20,
              right: 16,
              child: IconButton.filledTonal(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
