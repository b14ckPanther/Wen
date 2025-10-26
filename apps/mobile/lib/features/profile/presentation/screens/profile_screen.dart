import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../auth/presentation/widgets/sign_in_form.dart';
import '../../../auth/presentation/widgets/sign_up_form.dart';
import '../../../payments/presentation/upgrade_plan_sheet.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/application/settings_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateChangesProvider);
    final settings = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(
      settingsControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.tabProfile),
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (user) {
          if (user == null) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const _AuthFormsCard(),
                const SizedBox(height: 24),
                _SettingsCard(
                  l10n: l10n,
                  settings: settings,
                  onThemeChanged: settingsNotifier.updateThemeMode,
                  onLocaleChanged: settingsNotifier.updateLocale,
                ),
              ],
            );
          }

          final userDocAsync = ref.watch(currentUserDocProvider);
          return userDocAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text(error.toString())),
            data: (doc) {
              final data = doc?.data() ?? {};
              final role = data['role'] as String? ?? 'user';
              final plan = data['plan'] as String? ?? 'free';
              final name = data['name'] as String? ?? user.displayName ?? '—';
              final email = user.email ?? '—';
              final roleStatus = data['roleStatus'] as String? ?? 'active';
              final requestedRole = data['requestedRole'] as String? ?? '';
              final isOwnerPending =
                  requestedRole == 'owner' && roleStatus == 'pending';
              final isOwnerRejected = roleStatus == 'rejected';
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(email),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: [
                              Chip(label: Text('Role: $role')),
                              Chip(label: Text('Plan: $plan')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FilledButton.tonalIcon(
                            onPressed: () async {
                              await ref.read(authRepositoryProvider).signOut();
                            },
                            icon: const Icon(Icons.logout),
                            label: Text(l10n.authSignOut),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (role == 'user') ...[
                    if (isOwnerPending)
                      Card(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.hourglass_bottom,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.authOwnerRequestPending,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiaryContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isOwnerRejected)
                      Card(
                        color:
                            Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.authOwnerRequestRejected,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: isOwnerPending
                          ? null
                          : () async {
                              await ref
                                  .read(authRepositoryProvider)
                                  .requestOwnerUpgrade(currentData: data);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(l10n.authOwnerRequestSubmitted),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(l10n.authOwnerRequestButton),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: Text(
                        l10n.authOwnerRequestSubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                  if (role == 'owner') ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const UpgradePlanSheet(),
                        );
                      },
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: Text(l10n.paymentsUpgradeTitle),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/profile/my-business');
                      },
                      icon: const Icon(Icons.storefront),
                      label: Text(l10n.authManageBusiness),
                    ),
                  ],
                  if (role == 'admin') ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push('/profile/admin');
                      },
                      icon: const Icon(Icons.shield_outlined),
                      label: Text(l10n.adminConsoleButton),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _SettingsCard(
                    l10n: l10n,
                    settings: settings,
                    onThemeChanged: settingsNotifier.updateThemeMode,
                    onLocaleChanged: settingsNotifier.updateLocale,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.l10n,
    required this.settings,
    required this.onThemeChanged,
    required this.onLocaleChanged,
  });

  final AppLocalizations l10n;
  final SettingsState settings;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool disabled = !settings.initialized;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.settingsAppearanceTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.settingsThemeLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l10n.settingsThemeSystem),
                  icon: const Icon(Icons.auto_awesome),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l10n.settingsThemeLight),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l10n.settingsThemeDark),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: disabled
                  ? null
                  : (values) => onThemeChanged(values.first),
            ),
            const SizedBox(height: 24),
            Text(l10n.settingsLanguageLabel, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<Locale>(
              segments: [
                ButtonSegment(
                  value: const Locale('en'),
                  label: Text(l10n.settingsLanguageEnglish),
                  icon: const Icon(Icons.language),
                ),
                ButtonSegment(
                  value: const Locale('ar'),
                  label: Text(l10n.settingsLanguageArabic),
                  icon: const Icon(Icons.translate),
                ),
              ],
              selected: {settings.locale},
              onSelectionChanged: disabled
                  ? null
                  : (values) => onLocaleChanged(values.first),
            ),
            if (disabled)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  l10n.settingsLoading,
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AuthFormsCard extends StatelessWidget {
  const _AuthFormsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: DefaultTabController(
              length: 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenHeight = MediaQuery.of(context).size.height;
                  final availableHeight = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : screenHeight * 0.75;
                  // Tab bar height (~48) + spacing (24) should be considered when clamping.
                  const tabBarHeight = 48.0;
                  const gapHeight = 24.0;
                  final formHeight = (availableHeight - tabBarHeight - gapHeight).clamp(280.0, 520.0);
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: l10n.authSignInTab),
                          Tab(text: l10n.authSignUpTab),
                        ],
                      ),
                      const SizedBox(height: gapHeight),
                      SizedBox(
                        height: formHeight,
                        child: TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          children: const [
                            SingleChildScrollView(child: SignInForm()),
                            SingleChildScrollView(child: SignUpForm()),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
