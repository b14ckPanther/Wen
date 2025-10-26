import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../../location/application/location_controller.dart';
import '../../application/auth_providers.dart';
import '../widgets/owner_location_picker_screen.dart';

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
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _selectedParentCategoryId;
  String? _selectedSubcategoryId;
  GeoPoint? _selectedLocation;
  String? _selectedAddress;
  bool _locationInitialised = false;
  bool _submitting = false;

  @override
  void dispose() {
    _ownerNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubcategoryId == null || _selectedSubcategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.businessNeedCategory)),
      );
      return;
    }
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authOwnerLocationRequired)),
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
        categoryId: _selectedSubcategoryId!,
        location: _selectedLocation!,
        images: const [],
        existing: null,
        addressLine: _selectedAddress,
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty
            ? null
            : _websiteController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.authOwnerRequestSubmitted)),
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
    final locationState = ref.watch(locationControllerProvider);

    if (!_locationInitialised && locationState.status == LocationStatus.ready) {
      _locationInitialised = true;
      final center = locationState.center;
      _selectedLocation = GeoPoint(center.latitude, center.longitude);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authOwnerRequestButton)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (categories) {
          final orderedCategories = [...categories]..sort((a, b) => a.name.compareTo(b.name));
          final topLevel = orderedCategories
              .where(
                (category) => category.parentId == null || (category.parentId?.isEmpty ?? true),
              )
              .toList();
          final subCategories = orderedCategories
              .where((category) => category.parentId != null && category.parentId!.isNotEmpty)
              .toList();

          _selectedParentCategoryId ??= topLevel.isNotEmpty ? topLevel.first.id : null;
          final availableSubcategories = subCategories
              .where((category) => category.parentId == _selectedParentCategoryId)
              .toList();
          if (_selectedSubcategoryId == null && availableSubcategories.isNotEmpty) {
            _selectedSubcategoryId = availableSubcategories.first.id;
          }
          if (_selectedSubcategoryId != null &&
              availableSubcategories.every((category) => category.id != _selectedSubcategoryId)) {
            _selectedSubcategoryId = availableSubcategories.isNotEmpty
                ? availableSubcategories.first.id
                : null;
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
                  TextFormField(
                    controller: _ownerNameController,
                    decoration: InputDecoration(labelText: l10n.authFullNameLabel),
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.authNameRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: l10n.authEmailLabel),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.authEmailRequired;
                      if (!value.contains('@')) return l10n.authEmailInvalid;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: l10n.authPasswordLabel),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return l10n.authPasswordRequired;
                      if (value.length < 8) return l10n.authPasswordLength;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(labelText: l10n.authConfirmPasswordLabel),
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
                  const SizedBox(height: 16),
                  if (topLevel.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.authOwnerNoSubcategories,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  else ...[
                  DropdownMenu<String>(
                    initialSelection: _selectedParentCategoryId,
                    label: Text(l10n.authOwnerCategoryLabel),
                    onSelected: (value) {
                      setState(() {
                        _selectedParentCategoryId = value;
                        _selectedSubcategoryId = null;
                      });
                    },
                    dropdownMenuEntries: [
                      for (final category in topLevel)
                        DropdownMenuEntry(
                          value: category.id,
                          label: category.name,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownMenu<String>(
                    initialSelection: _selectedSubcategoryId,
                    label: Text(l10n.authOwnerSubcategoryLabel),
                    onSelected: (value) => setState(() => _selectedSubcategoryId = value),
                    dropdownMenuEntries: [
                      for (final category in availableSubcategories)
                        DropdownMenuEntry(
                          value: category.id,
                          label: category.name,
                        ),
                    ],
                  ),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: Text(
                        _selectedAddress ?? l10n.authOwnerLocationPlaceholder,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      subtitle: _selectedLocation == null
                          ? null
                          : Text(
                              '${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                              '${_selectedLocation!.longitude.toStringAsFixed(5)}',
                            ),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () async {
                          if (!mounted) return;
                          final initialPosition = _selectedLocation != null
                              ? LatLng(
                                  _selectedLocation!.latitude,
                                  _selectedLocation!.longitude,
                                )
                              : LatLng(
                                  kFallbackGeoCenter.latitude,
                                  kFallbackGeoCenter.longitude,
                                );
                          final result = await context.pushNamed<OwnerLocationPickResult>(
                            'owner-location-picker',
                            extra: OwnerLocationPickArgs(
                              initialPosition: initialPosition,
                              initialAddress: _selectedAddress,
                            ),
                          );
                          if (result != null && mounted) {
                            setState(() {
                              _selectedLocation = GeoPoint(
                                result.position.latitude,
                                result.position.longitude,
                              );
                              _selectedAddress = result.address;
                            });
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: Text(l10n.authOwnerPickLocation),
                      ),
                    ),
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
                    onPressed: _submitting ? null : _submit,
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
