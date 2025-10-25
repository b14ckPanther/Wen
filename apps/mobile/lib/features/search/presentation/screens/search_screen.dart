import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../../businesses/application/business_search_controller.dart';
import '../../../businesses/data/models/business.dart';
import '../../../businesses/domain/business_query_filters.dart';
import '../../../businesses/presentation/widgets/business_list_tile.dart';
import '../../../location/application/location_controller.dart';
import '../../application/ai_search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _queryController;
  String? _selectedCategoryId;
  double _radiusKm = 15;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final center = ref.read(activeGeoCenterProvider);
    final filters = BusinessQueryFilters(
      center: center,
      keyword: _queryController.text.trim().isEmpty
          ? null
          : _queryController.text.trim(),
      categoryId: _selectedCategoryId?.isEmpty ?? true
          ? null
          : _selectedCategoryId,
      radiusKm: _radiusKm,
    );
    ref.read(businessSearchControllerProvider).search(filters);
  }

  void _onCategorySelected(String? categoryId, bool selected) {
    setState(() {
      _selectedCategoryId = selected ? categoryId : null;
    });
    _applyFilters();
  }

  void _onRadiusChange(double value) {
    setState(() {
      _radiusKm = value;
    });
  }

  void _onRadiusChangeEnd(double value) {
    _onRadiusChange(value);
    _applyFilters();
  }

  void _onBusinessTap(Business business) {
    if (!mounted) return;
    context.pushNamed(
      'business-details',
      pathParameters: {'id': business.id},
      extra: business,
    );
  }

  Future<void> _runAiSearch() async {
    await ref
        .read(aiSearchControllerProvider.notifier)
        .search(_queryController.text.trim());
  }

  void _clearAiResults() {
    ref.read(aiSearchControllerProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = ref.watch(businessSearchControllerProvider);
    final searchState = controller.state;
    final categoriesAsync = ref.watch(businessCategoriesProvider);
    final aiState = ref.watch(aiSearchControllerProvider);
    final aiResults = aiState.asData?.value ?? const [];
    final isAiLoading = aiState.isLoading;
    final aiError = aiState.asError?.error;
    final center = ref.watch(activeGeoCenterProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.tabSearch),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _applyFilters,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TextField(
                  controller: _queryController,
                  decoration: InputDecoration(
                    labelText: l10n.searchPlaceholder,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _queryController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _queryController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _applyFilters(),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n.searchPopularCategories} · ${_radiusKm.toStringAsFixed(0)} km',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _radiusKm,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${_radiusKm.toStringAsFixed(0)} km',
                  onChanged: _onRadiusChange,
                  onChangeEnd: _onRadiusChangeEnd,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: isAiLoading ? null : _runAiSearch,
                  icon: isAiLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(l10n.aiSearchButton),
                ),
                if (aiError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      aiError.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                if (!isAiLoading && aiResults.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aiSearchResultsTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final result in aiResults) ...[
                            Text(
                              result.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              result.summary,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.aiSearchConfidence} ${(result.confidence * 100).toStringAsFixed(0)}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const Divider(height: 28),
                          ],
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _clearAiResults,
                              icon: const Icon(Icons.clear),
                              label: Text(l10n.aiSearchClearButton),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (!isAiLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 8),
                    child: Text(
                      l10n.aiSearchEmptyHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                categoriesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Failed to load categories: ${error.toString()}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  data: (categories) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text(l10n.searchAll),
                          selected: _selectedCategoryId == null,
                          onSelected: (selected) =>
                              _onCategorySelected(null, selected),
                        ),
                        const SizedBox(width: 12),
                        for (final category in categories) ...[
                          ChoiceChip(
                            label: Text(category.name),
                            selected: _selectedCategoryId == category.id,
                            onSelected: (selected) =>
                                _onCategorySelected(category.id, selected),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          _buildBusinessResultsSliver(
            context,
            theme,
            searchState,
            l10n,
            center,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessResultsSliver(
    BuildContext context,
    ThemeData theme,
    BusinessSearchState searchState,
    AppLocalizations l10n,
    GeoPoint center,
  ) {
    final ref = this.ref;
    switch (searchState.status) {
      case BusinessSearchStatus.initial:
      case BusinessSearchStatus.loading:
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        );
      case BusinessSearchStatus.failure:
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              searchState.errorMessage ?? 'Search failed',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
        );
      case BusinessSearchStatus.success:
        if (searchState.items.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                l10n.favoritesEmptyTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
          );
        }
        final itemCount =
            searchState.items.length + (searchState.isFetchingMore ? 1 : 0);
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= searchState.items.length) {
                ref.read(businessSearchControllerProvider).loadMore();
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final business = searchState.items[index];
              final distanceKm = business.distanceInKm(
                latitude: center.latitude,
                longitude: center.longitude,
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: BusinessListTile(
                  business: business,
                  distanceKm: distanceKm,
                  onTap: () => _onBusinessTap(business),
                ),
              );
            }, childCount: itemCount),
          ),
        );
    }
  }
}
