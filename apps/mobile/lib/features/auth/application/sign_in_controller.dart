import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import '../data/auth_repository.dart';
import 'auth_providers.dart';

final signInControllerProvider =
    legacy.StateNotifierProvider<SignInController, AsyncValue<void>>(
      (ref) => SignInController(ref.watch(authRepositoryProvider)),
    );

class SignInController extends StateNotifier<AsyncValue<void>> {
  SignInController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signIn(email: email, password: password);
      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
