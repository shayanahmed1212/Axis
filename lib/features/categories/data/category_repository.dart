// Category repository — Firestore CRUD for user categories
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:axis/core/errors/app_exception.dart';
import 'package:axis/core/errors/app_exception_types.dart';
import '../domain/category.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CategoryRepository(this._firestore, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = _userId;
    if (uid == null) {
      throw AppException(type: AppExceptionType.permissionDenied, message: 'User not authenticated');
    }
    return _firestore.collection('users').doc(uid).collection('categories');
  }

  Stream<List<Category>> watchCategories() {
    return _collection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  Future<List<Category>> getCategories() async {
    final snapshot = await _collection
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
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