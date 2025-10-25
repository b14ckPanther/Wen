import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/l10n/app_localizations.dart';

import '../../application/sign_up_controller.dart';
import 'auth_error_text.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key});

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _asOwner = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(signUpControllerProvider.notifier)
        .signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          asOwner: _asOwner,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final signUpState = ref.watch(signUpControllerProvider);
    final isLoading = signUpState.isLoading;
    final error = signUpState.asError?.error;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.authFullNameLabel),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.authNameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.authEmailLabel),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.authEmailRequired;
              }
              if (!value.contains('@')) {
                return l10n.authEmailInvalid;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: l10n.authPasswordLabel),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.authPasswordRequired;
              }
              if (value.length < 8) {
                return l10n.authPasswordLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: l10n.authConfirmPasswordLabel,
            ),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.authConfirmPasswordRequired;
              }
              if (value != _passwordController.text) {
                return l10n.authPasswordsDoNotMatch;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            value: _asOwner,
            onChanged: isLoading
                ? null
                : (value) => setState(() {
                    _asOwner = value;
                  }),
            title: Text(l10n.authOwnerSwitchTitle),
            subtitle: Text(l10n.authOwnerSwitchSubtitle),
          ),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.authCreateAccountButton),
          ),
          AuthErrorText(error: error),
        ],
      ),
    );
  }
}
