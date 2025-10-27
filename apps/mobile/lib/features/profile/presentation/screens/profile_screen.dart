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
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);

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
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.hourglass_bottom,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.authOwnerRequestPending,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onTertiaryContainer,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isOwnerRejected)
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.authOwnerRequestRejected,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
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
                                    content: Text(
                                      l10n.authOwnerRequestSubmitted,
                                    ),
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
    final theme = Theme.of(context);
    final mediaHeight = MediaQuery.of(context).size.height;
    final formHeight = mediaHeight.isFinite
        ? mediaHeight.clamp(380.0, 620.0) * 0.55
        : 420.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: DefaultTabController(
          length: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ClipPath(
              clipper: _PrismClipper(),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.30),
                      theme.colorScheme.tertiary.withValues(alpha: 0.12),
                      theme.colorScheme.surface.withValues(alpha: 0.90),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.22),
                      blurRadius: 42,
                      offset: const Offset(0, 28),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -90,
                      right: -60,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary.withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -70,
                      left: -50,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.secondary.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.authWelcomeTitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.authWelcomeSubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withValues(alpha: 0.65),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: TabBar(
                              indicator: const UnderlineTabIndicator(
                                borderSide: BorderSide(width: 3, color: Colors.white),
                                insets: EdgeInsets.symmetric(horizontal: 32),
                              ),
                              labelStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white70,
                              tabs: [
                                Tab(text: l10n.authSignInTab.toUpperCase()),
                                Tab(text: l10n.authSignUpTab.toUpperCase()),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            child: SizedBox(
                              height: formHeight,
                              child: const TabBarView(
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  SingleChildScrollView(child: SignInForm()),
                                  SingleChildScrollView(child: SignUpForm()),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrismClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notch = 42;
    final path = Path()
      ..moveTo(0, notch)
      ..lineTo(notch * 1.6, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - notch)
      ..lineTo(size.width - notch * 1.2, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
