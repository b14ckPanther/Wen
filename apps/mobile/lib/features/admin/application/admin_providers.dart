import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/application/auth_providers.dart';
import '../../businesses/application/business_repository_provider.dart';
import '../../businesses/data/models/business.dart';
import '../data/admin_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
});

final adminUsersProvider = StreamProvider.autoDispose(
  (ref) => ref.watch(adminRepositoryProvider).watchUsers(),
);

final pendingBusinessesProvider = StreamProvider.autoDispose<List<Business>>(
  (ref) => ref.watch(businessRepositoryProvider).watchPendingBusinesses(),
);

final isAdminProvider = Provider<bool>((ref) {
  final userDoc = ref.watch(currentUserDocProvider).value;
  final role = userDoc?.data()?['role'] as String?;
  return role == 'admin';
});
