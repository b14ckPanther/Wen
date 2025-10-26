import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:state_notifier/state_notifier.dart';

import '../data/auth_repository.dart';
import 'auth_providers.dart';

final signUpControllerProvider =
    legacy.StateNotifierProvider<SignUpController, AsyncValue<void>>(
      (ref) => SignUpController(ref.watch(authRepositoryProvider)),
    );

class SignUpController extends StateNotifier<AsyncValue<void>> {
  SignUpController(this._repository) : super(const AsyncValue.data(null));

  final AuthRepository _repository;

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    bool asOwner = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signUp(
        name: name,
        email: email,
        password: password,
        asOwner: asOwner,
      );
      if (!mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
