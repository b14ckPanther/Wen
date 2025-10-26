import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/l10n/app_localizations.dart';

class WenShell extends StatelessWidget {
  const WenShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final destinations = [
      (
        label: l10n.tabExplore,
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore,
      ),
      (
        label: l10n.tabCategories,
        icon: Icons.dashboard_outlined,
        selectedIcon: Icons.dashboard,
      ),
      (
        label: l10n.tabSearch,
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
      ),
      (
        label: l10n.tabFavorites,
        icon: Icons.favorite_border,
        selectedIcon: Icons.favorite,
      ),
      (
        label: l10n.tabProfile,
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}
