import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/data/models/business.dart';
import '../../../businesses/presentation/widgets/business_list_tile.dart';
import '../../../location/application/location_controller.dart';
import '../../application/category_providers.dart';

class CategoryDetailScreen extends ConsumerStatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    this.initialCategoryName,
  });

  final String categoryId;
  final String? initialCategoryName;

  @override
  ConsumerState<CategoryDetailScreen> createState() =>
      _CategoryDetailScreenState();
}

class _CategoryDetailScreenState
    extends ConsumerState<CategoryDetailScreen> {
  double _radiusKm = 25;

  void _openBusiness(Business business) {
    if (!mounted) return;
    context.pushNamed(
      'business-details',
      pathParameters: {'id': business.id},
      extra: business,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final center = ref.watch(activeGeoCenterProvider);
    final category = ref.watch(categoryByIdProvider(widget.categoryId));
    final request = CategoryBusinessesRequest(
      categoryId: widget.categoryId,
      center: center,
      radiusKm: _radiusKm,
    );
    final businessesAsync = ref.watch(categoryBusinessesProvider(request));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(category?.name ?? widget.initialCategoryName ?? l10n.categoriesTitle),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
              child: Card(
                color: Colors.white.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoriesRadiusLabel(_radiusKm.toStringAsFixed(0)),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Slider(
                        value: _radiusKm,
                        min: 5,
                        max: 80,
                        divisions: 15,
                        label: '${_radiusKm.toStringAsFixed(0)} km',
                        onChanged: (value) {
                          setState(() {
                            _radiusKm = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: businessesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load businesses: $error',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ),
                ),
                data: (businesses) {
                  if (businesses.isEmpty) {
                    return Center(
                      child: Text(
                        l10n.categoriesNoBusinesses,
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemBuilder: (context, index) {
                      final business = businesses[index];
                      final distanceKm = business.distanceInKm(
                        latitude: center.latitude,
                        longitude: center.longitude,
                      );
                      return BusinessListTile(
                        business: business,
                        distanceKm: distanceKm,
                        onTap: () => _openBusiness(business),
                        onViewOnMap: null,
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: businesses.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
