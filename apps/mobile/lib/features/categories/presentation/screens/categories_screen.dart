import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../../businesses/data/models/business_category.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _openCategory(BuildContext context, BusinessCategory category) {
    context.pushNamed(
      'category-detail',
      pathParameters: {'id': category.id},
      extra: category,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(businessCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.categoriesTitle),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load categories: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (categories) {
          final topLevel = categories
              .where(
                (c) => c.parentId == null || (c.parentId?.isEmpty ?? true),
              )
              .toList();
          if (topLevel.isEmpty) {
            return Center(
              child: Text(
                l10n.categoriesEmpty,
                style: theme.textTheme.titleMedium,
              ),
            );
          }
          final grouped = <String, List<BusinessCategory>>{};
          for (final category in categories) {
            final parentId = category.parentId;
            if (parentId == null || parentId.isEmpty) continue;
            grouped.putIfAbsent(parentId, () => []).add(category);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemBuilder: (context, index) {
              final root = topLevel[index];
              final subcategories = grouped[root.id] ?? [];
              return _CategorySectionCard(
                category: root,
                subcategories: subcategories,
                onViewAll: () => _openCategory(context, root),
                onSubCategoryTap: (subcategory) =>
                    _openCategory(context, subcategory),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemCount: topLevel.length,
          );
        },
      ),
    );
  }
}

class _CategorySectionCard extends StatelessWidget {
  const _CategorySectionCard({
    required this.category,
    required this.subcategories,
    required this.onViewAll,
    required this.onSubCategoryTap,
  });

  final BusinessCategory category;
  final List<BusinessCategory> subcategories;
  final VoidCallback onViewAll;
  final ValueChanged<BusinessCategory> onSubCategoryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.tonal(
                  onPressed: onViewAll,
                  child: Text(l10n.categoriesViewAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (subcategories.isEmpty)
              Text(
                l10n.categoriesNoSubcategories,
                style: theme.textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final subcategory in subcategories)
                    FilterChip(
                      label: Text(subcategory.name),
                      onSelected: (_) => onSubCategoryTap(subcategory),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
