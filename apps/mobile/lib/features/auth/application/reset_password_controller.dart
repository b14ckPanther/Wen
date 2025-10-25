import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import '../data/auth_repository.dart';
import 'auth_providers.dart';

final resetPasswordControllerProvider =
    legacy.StateNotifierProvider<ResetPasswordController, AsyncValue<void>>(
      (ref) => ResetPasswordController(ref.watch(authRepositoryProvider)),
    );

class ResetPasswordController extends StateNotifier<AsyncValue<void>> {
  ResetPasswordController(this._repository)
    : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> sendResetEmail(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.sendPasswordReset(email: email);
      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
