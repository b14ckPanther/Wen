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
