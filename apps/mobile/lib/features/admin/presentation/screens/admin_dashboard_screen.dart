import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../businesses/application/business_repository_provider.dart';
import '../../application/admin_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final pendingBusinessesAsync = ref.watch(pendingBusinessesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Pending businesses',
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
                return const Text('No businesses awaiting approval.');
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
                            label: const Text('Approve'),
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
            'Users',
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
                return const Text('No users in database yet.');
              }
              return Column(
                children: users
                    .map(
                      (user) => Card(
                        child: ListTile(
                          title: Text(user['name'] as String? ?? '—'),
                          subtitle: Text(user['email'] as String? ?? ''),
                          trailing: PopupMenuButton<String>(
                            onSelected: (role) async {
                              await ref
                                  .read(adminRepositoryProvider)
                                  .updateUserRole(
                                    userId: user['id'] as String,
                                    role: role,
                                  );
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'user',
                                child: Text('Set role: user'),
                              ),
                              PopupMenuItem(
                                value: 'owner',
                                child: Text('Set role: owner'),
                              ),
                              PopupMenuItem(
                                value: 'admin',
                                child: Text('Set role: admin'),
                              ),
                            ],
                            child: Chip(
                              label: Text('Role: ${user['role'] ?? 'user'}'),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
