import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/features/auth/domain/app_user.dart';
import 'package:axis/features/auth/data/auth_repository.dart';
import 'package:axis/core/errors/app_exception.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges();
});

final authControllerProvider = Provider<AuthController>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthController(repository);
});

class AuthController {
  final AuthRepository _repository;

  AuthController(this._repository);

  Future<AppUser?> signIn(String email, String password) async {
    try {
      return await _repository.signInWithEmailAndPassword(email, password);
    } on AppException {
      rethrow;
    }
  }

  Future<AppUser?> register(String email, String password, {String? displayName}) async {
    try {
      return await _repository.registerWithEmailAndPassword(
        email,
        password,
        displayName: displayName,
      );
    } on AppException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _repository.signOut();
    } on AppException {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _repository.resetPassword(email);
    } on AppException {
      rethrow;
    }
  }
}
