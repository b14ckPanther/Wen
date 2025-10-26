import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../businesses/application/business_repository_provider.dart';
import '../../application/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final pendingBusinessesAsync = ref.watch(pendingBusinessesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminConsoleTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            l10n.adminPendingBusinessesTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          pendingBusinessesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(error.toString()),
            data: (businesses) {
              if (businesses.isEmpty) {
                return Text(l10n.adminPendingBusinessesEmpty);
              }
              return Column(
                children: businesses
                    .map(
                      (business) => Card(
                        child: ListTile(
                          title: Text(business.name),
                          subtitle: Text(business.description),
                          trailing: FilledButton.icon(
                            onPressed: () async {
                              await ref
                                  .read(businessRepositoryProvider)
                                  .approveBusiness(business.id);
                            },
                            icon: const Icon(Icons.check),
                            label: Text(l10n.adminApproveAction),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            l10n.adminUsersTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(error.toString()),
            data: (users) {
              if (users.isEmpty) {
                return Text(l10n.adminUsersEmpty);
              }

              final nonAdminUsers = users
                  .where((user) => (user['role'] as String?) != 'admin')
                  .toList();

              final pendingOwnerRequests = nonAdminUsers
                  .where(
                    (user) => (user['requestedRole'] == 'owner' &&
                        user['roleStatus'] == 'pending'),
                  )
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (pendingOwnerRequests.isNotEmpty) ...[
                    Text(
                      l10n.adminOwnerRequestsTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    ...pendingOwnerRequests.map(
                      (user) => Card(
                        child: ListTile(
                          title: Text(user['name'] as String? ?? '—'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email'] as String? ?? ''),
                              const SizedBox(height: 4),
                              Text(
                                l10n.adminOwnerRequestSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              FilledButton(
                                onPressed: () async {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .approveOwnerRequest(
                                        userId: user['id'] as String,
                                      );
                                },
                                child: Text(l10n.adminApproveAction),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .rejectOwnerRequest(
                                        userId: user['id'] as String,
                                      );
                                },
                                child: Text(l10n.adminRejectAction),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]
                  else
                    Text(l10n.adminOwnerRequestsEmpty),
                  const SizedBox(height: 16),
                  Text(
                    l10n.adminAllUsersTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ...nonAdminUsers.map(
                    (user) {
                      final status = user['roleStatus'] as String? ?? 'active';
                      return Card(
                        child: ListTile(
                          title: Text(user['name'] as String? ?? '—'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user['email'] as String? ?? ''),
                              const SizedBox(height: 4),
                              Text('${l10n.adminRoleLabel}: ${user['role'] ?? 'user'}'),
                              Text('${l10n.adminStatusLabel}: $status'),
                            ],
                          ),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              PopupMenuButton<String>(
                                onSelected: (role) async {
                                  await ref
                                      .read(adminRepositoryProvider)
                                      .updateUserRole(
                                        userId: user['id'] as String,
                                        role: role,
                                      );
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'user',
                                    child: Text(l10n.adminSetRoleUser),
                                  ),
                                  PopupMenuItem(
                                    value: 'owner',
                                    child: Text(l10n.adminSetRoleOwner),
                                  ),
                                  PopupMenuItem(
                                    value: 'admin',
                                    child: Text(l10n.adminSetRoleAdmin),
                                  ),
                                ],
                                child: const Icon(Icons.manage_accounts),
                              ),
                              IconButton(
                                tooltip: l10n.adminDeleteUser,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(l10n.adminDeleteUser),
                                      content: Text(l10n.adminDeleteUserConfirm),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                                        ),
                                        FilledButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text(MaterialLocalizations.of(context).okButtonLabel),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm != true || !context.mounted) return;
                                  try {
                                    await ref
                                        .read(adminRepositoryProvider)
                                        .deleteUser(userId: user['id'] as String);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(l10n.adminDeleteUserSuccess)),
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${l10n.adminDeleteUserError}\n${error.toString()}',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
