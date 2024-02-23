import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sales/Providers/auth.dart';
import 'package:sales/screens/home.dart';
import 'package:sales/screens/login.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authService).authStateChanges();
});

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (state) {
        switch (state) {
          case AuthState.authenticated:
            return const HomeScreen();
          case AuthState.unauthenticated:
            return const LoginScreen();
          case AuthState.loading:
            return const Material(
                child: Center(child: CircularProgressIndicator()));
        }
      },
      error: (error, stackTrace) =>
          const Text("Error occured.Please try again"),
      loading: () => const CircularProgressIndicator(),
    );
  }
}
