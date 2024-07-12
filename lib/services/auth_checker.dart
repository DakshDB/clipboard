import 'package:clipboard/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../screens/login.dart';

class AuthChecker extends ConsumerWidget {
  static const String id = 'Auth_checker';

  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (value) {
        if (value != null) {
          return const MyHomePage();
        }
        return const LoginScreen();
      },
      loading: () {
        return const Scaffold(
          body: CircularProgressIndicator(),
        );
      },
      error: (e, _s) {
        return const LoginScreen();
      },
    );
  }
}
