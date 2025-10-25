import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';

import '../../../shared/presentation/widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.tabFavorites),
      ),
      body: EmptyState(
        icon: Icons.favorite_border,
        title: l10n.favoritesEmptyTitle,
        message: l10n.favoritesEmptySubtitle,
        action: ElevatedButton(onPressed: () {}, child: Text(l10n.tabExplore)),
      ),
    );
  }
}
