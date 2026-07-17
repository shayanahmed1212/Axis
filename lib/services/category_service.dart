// Exposes [Category] model and [CategoriesScreen] at the package boundary.
// The repository scopes all reads/writes to `users/{uid}/categories` so
// one user can never see another's categories.
// ignore_for_file: prefer_const_constructors

export 'package:axis/models/category.dart';
export 'package:axis/screens/categories_screen.dart';

// Category repository — Firestore CRUD for user categories
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/utils/app_utils.dart';
import 'package:axis/models/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CategoryRepository(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _userId;
    if (uid == null) {
      throw AppException(
          type: AppExceptionType.permissionDenied,
          message: 'User not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('categories');
  }

  Stream<List<Category>> watchCategories() {
    return retryStream(() {
      return _collection
          .orderBy('created_at', descending: true)
          .snapshots()
          .transform(
        StreamTransformer<
            QuerySnapshot<Map<String, dynamic>>,
            List<Category>>.fromHandlers(
          handleData: (snapshot, sink) {
            sink.add(snapshot.docs
                .map((doc) => Category.fromFirestore(doc))
                .toList());
          },
          handleError: (error, stackTrace, sink) {
            if (error is FirebaseException) {
              sink.addError(_mapError(error), stackTrace);
            } else {
              sink.addError(error, stackTrace);
            }
          },
        ),
      );
    });
  }

  Future<List<Category>> getCategories() async {
    return retryFuture(() async {
      final snapshot = await _collection
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    });
  }

  Future<Category> createCategory(Category category) async {
    final docRef = await _collection.add(category.toFirestore());
    final doc = await docRef.get();
    return Category.fromFirestore(doc);
  }

  Future<void> updateCategory(Category category) async {
    await _collection.doc(category.id).update({
      'name': category.name,
      'icon_name': category.iconName,
      'color_hex': category.colorHex,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCategory(String categoryId) async {
    await _collection.doc(categoryId).delete();
  }

  Future<Category?> getCategory(String categoryId) async {
    final doc = await _collection.doc(categoryId).get();
    if (!doc.exists) return null;
    return Category.fromFirestore(doc);
  }

  AppException _mapError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppException(
            type: AppExceptionType.permissionDenied,
            message: 'Permission denied');
      case 'not-found':
        return AppException(
            type: AppExceptionType.notFound, message: 'Resource not found');
      case 'unavailable':
        return AppException(
            type: AppExceptionType.networkError,
            message: 'Service unavailable');
      default:
        return AppException(
            type: AppExceptionType.unknown,
            message: e.message ?? 'An error occurred');
    }
  }
}

// Providers
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.watchCategories();
});

final categoriesFutureProvider = FutureProvider<List<Category>>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return repo.getCategories();
});
