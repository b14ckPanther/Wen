import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../../location/application/location_controller.dart';
import '../../application/auth_providers.dart';

class OwnerRegisterScreen extends ConsumerStatefulWidget {
  const OwnerRegisterScreen({super.key});

  @override
  ConsumerState<OwnerRegisterScreen> createState() => _OwnerRegisterScreenState();
}

class _OwnerRegisterScreenState extends ConsumerState<OwnerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  String? _selectedCategoryId;
  bool _submitting = false;
  late LatLng _selectedLatLng;
  Set<Marker> _markers = {};
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
    _selectedLatLng = LatLng(
      kFallbackGeoCenter.latitude,
      kFallbackGeoCenter.longitude,
    );
    _latController.text = _selectedLatLng.latitude.toStringAsFixed(6);
    _lngController.text = _selectedLatLng.longitude.toStringAsFixed(6);
    _markers = {
      Marker(
        markerId: const MarkerId('business-location'),
        position: _selectedLatLng,
        draggable: true,
        onDragEnd: _onMapPositionChanged,
      ),
    };
    unawaited(_updateAddressFromLatLng(_selectedLatLng));
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _updateAddressFromLatLng(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
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
        if (parts.isNotEmpty) {
          _addressController.text = parts.join(', ');
        }
      }
    } catch (_) {
      // Ignore reverse geocoding errors.
    }
  }

  Future<void> _animateCamera(LatLng target) async {
    if (!_mapController.isCompleted) return;
    final controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLng(target));
  }

  void _onMapPositionChanged(LatLng position) {
    setState(() {
      _selectedLatLng = position;
      _latController.text = position.latitude.toStringAsFixed(6);
      _lngController.text = position.longitude.toStringAsFixed(6);
      _markers = {
        Marker(
          markerId: const MarkerId('business-location'),
          position: position,
          draggable: true,
          onDragEnd: _onMapPositionChanged,
        ),
      };
    });
    unawaited(_updateAddressFromLatLng(position));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final lat = double.tryParse(_latController.text.trim());
    final lng = double.tryParse(_lngController.text.trim());
    final categoryId = _selectedCategoryId;
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.businessNeedCoordinates)),
      );
      return;
    }
    if (categoryId == null || categoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.businessNeedCategory)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signUp(
        name: _ownerNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        asOwner: true,
      );

      final ownerId = authRepository.currentUser!.uid;
      final businessRepository = ref.read(businessRepositoryProvider);
      await businessRepository.upsertBusiness(
        ownerId: ownerId,
        name: _businessNameController.text.trim(),
        description: _businessDescriptionController.text.trim(),
        categoryId: categoryId,
        location: GeoPoint(lat, lng),
        images: const [],
        existing: null,
        addressLine: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authOwnerRequestSubmitted),
        ),
      );
      context.go('/profile');
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categoriesAsync = ref.watch(businessCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authOwnerRequestButton)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (categories) {
          final orderedCategories = [...categories]..sort((a, b) => a.name.compareTo(b.name));
          final topLevel = orderedCategories
              .where(
                (category) =>
                    category.parentId == null || (category.parentId?.isEmpty ?? true),
              )
              .toList();
          final subCategories = orderedCategories
              .where((category) => category.parentId != null && category.parentId!.isNotEmpty)
              .toList();
          final parentLookup = {
            for (final category in topLevel) category.id: category.name,
          };
          final dropdownEntries = subCategories
              .map(
                (sub) => DropdownMenuEntry<String>(
                  value: sub.id,
                  label:
                      '${parentLookup[sub.parentId] ?? l10n.categoriesTitle} • ${sub.name}',
                ),
              )
              .toList();
          if (_selectedCategoryId == null && dropdownEntries.isNotEmpty) {
            _selectedCategoryId = dropdownEntries.first.value;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.businessCreateTitle,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.authFullNameLabel),
                  TextFormField(
                    controller: _ownerNameController,
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.authNameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.authEmailLabel),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.authEmailRequired;
                      if (!value.contains('@')) return l10n.authEmailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.authPasswordLabel),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.authPasswordRequired;
                      if (value.length < 8) return l10n.authPasswordLength;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.authConfirmPasswordLabel),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.authConfirmPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return l10n.authPasswordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.businessUpdateTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _businessNameController,
                    decoration: InputDecoration(labelText: l10n.businessNameLabel),
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.businessNameLabel : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _businessDescriptionController,
                    decoration: InputDecoration(labelText: l10n.businessDescriptionLabel),
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.businessDescriptionLabel : null,
                  ),
                  const SizedBox(height: 12),
                  if (dropdownEntries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        l10n.authOwnerNoSubcategories,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else
                    DropdownMenu<String>(
                      initialSelection: _selectedCategoryId,
                      onSelected: (value) => setState(() => _selectedCategoryId = value),
                      dropdownMenuEntries: dropdownEntries,
                      label: Text(l10n.businessCategoryLabel),
                    ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: l10n.businessAddressLabel,
                      helperText: l10n.businessAddressHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLatLng,
                          zoom: 14,
                        ),
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        markers: _markers,
                        onTap: _onMapPositionChanged,
                        onMapCreated: (controller) {
                          if (!_mapController.isCompleted) {
                            _mapController.complete(controller);
                          }
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        _onMapPositionChanged(
                          LatLng(
                            kFallbackGeoCenter.latitude,
                            kFallbackGeoCenter.longitude,
                          ),
                        );
                        unawaited(
                          _animateCamera(
                            LatLng(
                              kFallbackGeoCenter.latitude,
                              kFallbackGeoCenter.longitude,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.my_location),
                      label: Text(l10n.exploreRefreshLocation),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.businessLatitudeLabel,
                            helperText: 'e.g. 25.2048',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _lngController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.businessLongitudeLabel,
                            helperText: 'e.g. 55.2708',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.businessPhoneLabel,
                      helperText: l10n.businessPhoneHint,
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(labelText: l10n.businessWebsiteLabel),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed:
                        _submitting || dropdownEntries.isEmpty ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.storefront),
                    label: Text(l10n.authOwnerRequestButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
