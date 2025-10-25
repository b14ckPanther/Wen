import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthErrorText extends StatelessWidget {
  const AuthErrorText({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return const SizedBox.shrink();
    }

    String message;
    if (error is FirebaseAuthException) {
      final authError = error as FirebaseAuthException;
      message = authError.message ?? authError.code;
    } else {
      message = error.toString();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
