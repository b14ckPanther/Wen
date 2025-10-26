import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../../businesses/data/models/business.dart';

class MyBusinessScreen extends ConsumerStatefulWidget {
  const MyBusinessScreen({super.key});

  @override
  ConsumerState<MyBusinessScreen> createState() => _MyBusinessScreenState();
}

class _MyBusinessScreenState extends ConsumerState<MyBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _addressController = TextEditingController();
  final _regionLabelController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _priceInfoController = TextEditingController();

  String? _selectedCategory;
  List<String> _images = const [];
  bool _initialised = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    _regionLabelController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _priceInfoController.dispose();
    super.dispose();
  }

  void _populateFromBusiness(Business business) {
    if (_initialised) return;
    _initialised = true;
    _nameController.text = business.name;
    _descriptionController.text = business.description;
    _latitudeController.text = business.location.latitude.toStringAsFixed(6);
    _longitudeController.text = business.location.longitude.toStringAsFixed(6);
    _selectedCategory = business.categoryId;
    _images = business.images;
    _addressController.text = business.addressLine ?? '';
    _regionLabelController.text = business.regionLabel ?? '';
    _phoneController.text = business.phoneNumber ?? '';
    _whatsappController.text = business.whatsappNumber ?? '';
    _emailController.text = business.contactEmail ?? '';
    _websiteController.text = business.website ?? '';
    _instagramController.text = business.instagram ?? '';
    _facebookController.text = business.facebook ?? '';
    _priceInfoController.text = business.priceInfo ?? '';
  }

  Future<void> _saveBusiness({
    Business? existing,
    required String ownerId,
  }) async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final latitude = double.tryParse(_latitudeController.text.trim());
    final longitude = double.tryParse(_longitudeController.text.trim());
    final categoryId = _selectedCategory;

    if (latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid coordinates for latitude and longitude.'),
        ),
      );
      return;
    }
    if (categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a business category.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final repository = ref.read(businessRepositoryProvider);
    try {
        await repository.upsertBusiness(
          ownerId: ownerId,
          documentId: existing?.id,
          name: name,
          description: description,
          categoryId: categoryId,
          location: GeoPoint(latitude, longitude),
          images: _images,
          existing: existing,
          addressLine: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          regionLabel: _regionLabelController.text.trim().isEmpty
              ? null
              : _regionLabelController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          whatsappNumber: _whatsappController.text.trim().isEmpty
              ? null
              : _whatsappController.text.trim(),
          contactEmail: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          instagram: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim(),
          facebook: _facebookController.text.trim().isEmpty
              ? null
              : _facebookController.text.trim(),
          priceInfo: _priceInfoController.text.trim().isEmpty
              ? null
              : _priceInfoController.text.trim(),
        );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business details saved. Pending admin review.'),
          ),
        );
      }
      _initialised = false;
      ref.invalidate(ownerBusinessProvider(ownerId));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _uploadImage({
    required String ownerId,
    required String businessId,
  }) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return;

    setState(() => _isUploadingImage = true);
    try {
      final bytes = await image.readAsBytes();
      await ref
          .read(businessRepositoryProvider)
          .uploadBusinessImage(
            ownerId: ownerId,
            businessId: businessId,
            bytes: bytes,
            fileName: 'cover_${DateTime.now().millisecondsSinceEpoch}',
          );
      _initialised = false;
      ref.invalidate(ownerBusinessProvider(ownerId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Business')),
      body: authAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (user) {
          if (user == null) {
            return Center(child: Text(l10n.profileGuestSubtitle));
          }

          final ownerId = user.uid;
          final businessAsync = ref.watch(ownerBusinessProvider(ownerId));
          final categoriesAsync = ref.watch(businessCategoriesProvider);

          return businessAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (business) {
              if (business != null) {
                _populateFromBusiness(business);
              }

              return categoriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text(error.toString())),
                data: (categories) {
                  final categoryEntries = categories
                      .map(
                        (category) => DropdownMenuEntry<String>(
                          value: category.id,
                          label: category.name,
                        ),
                      )
                      .toList();
                  if (_selectedCategory == null && categories.isNotEmpty) {
                    _selectedCategory = categories.first.id;
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            business == null
                                ? l10n.businessCreateTitle
                                : l10n.businessUpdateTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: l10n.businessNameLabel,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.businessNameLabel;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: l10n.businessDescriptionLabel,
                            ),
                            minLines: 3,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return l10n.businessDescriptionLabel;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownMenu<String>(
                            initialSelection: _selectedCategory,
                            dropdownMenuEntries: categoryEntries,
                            label: Text(l10n.businessCategoryLabel),
                            onSelected: (value) =>
                                setState(() => _selectedCategory = value),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _latitudeController,
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
                                  controller: _longitudeController,
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
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: l10n.businessAddressLabel,
                              helperText: l10n.businessAddressHint,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _regionLabelController,
                            decoration: InputDecoration(
                              labelText: l10n.businessRegionLabel,
                              helperText: l10n.businessRegionHint,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.businessContactSection,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l10n.businessPhoneLabel,
                              helperText: l10n.businessPhoneHint,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _whatsappController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: l10n.businessWhatsappLabel,
                              helperText: l10n.businessWhatsappHint,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: l10n.businessEmailLabel,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _websiteController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: l10n.businessWebsiteLabel,
                              helperText: 'https://',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _instagramController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: l10n.businessInstagramLabel,
                              helperText: '@username or URL',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _facebookController,
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              labelText: l10n.businessFacebookLabel,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _priceInfoController,
                            decoration: InputDecoration(
                              labelText: l10n.businessPriceInfoLabel,
                              helperText: l10n.businessPriceInfoHint,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.businessGalleryTitle,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              for (final imageUrl in _images)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              if (business != null)
                                OutlinedButton.icon(
                                  onPressed: _isUploadingImage
                                      ? null
                                      : () => _uploadImage(
                                          ownerId: ownerId,
                                          businessId: business.id,
                                        ),
                                  icon: _isUploadingImage
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.add_a_photo_outlined),
                                  label: Text(l10n.businessAddImage),
                                )
                              else
                                Text(l10n.businessSaveFirstMessage),
                            ],
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _isSaving
                                ? null
                                : () => _saveBusiness(
                                    existing: business,
                                    ownerId: ownerId,
                                  ),
                            icon: _isSaving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              business == null
                                  ? l10n.businessSaveButton
                                  : l10n.businessUpdateButton,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
