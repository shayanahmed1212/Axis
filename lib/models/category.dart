// User-defined category for grouping tasks. Each category stores an icon
// name, a hex color, and derives computed [backgroundColor] (pastel tint
// for badge fills) and [foregroundColor] (darkened variant for text/icon
// contrast). The [categoryIconProvider] makes the icon list available
// across the app without re-instantiating it.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String iconName,
    required String colorHex,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Category;

  const Category._();

  static final Category empty = Category(
    id: '',
    name: '',
    iconName: 'category',
    colorHex: '#6C63FF',
    userId: '',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  static const List<String> availableIcons = [
    'work',
    'home',
    'shopping',
    'health',
    'education',
    'travel',
    'finance',
    'personal',
    'fitness',
    'food',
    'music',
    'art',
    'tech',
    'sport',
    'book',
    'game',
  ];

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
      'user_id': userId,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  factory Category.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Category(
      id: doc.id,
      name: data['name'] as String,
      iconName: data['icon_name'] as String,
      colorHex: data['color_hex'] as String,
      userId: data['user_id'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  Color get backgroundColor => Color.fromARGB(255,
    (color.red + 255 * 2) ~/ 3,
    (color.green + 255 * 2) ~/ 3,
    (color.blue + 255 * 2) ~/ 3,
  );

  Color get foregroundColor => Color.fromARGB(255,
    (color.red * 0.2).round().clamp(0, 255),
    (color.green * 0.2).round().clamp(0, 255),
    (color.blue * 0.2).round().clamp(0, 255),
  );

  IconData get iconData {
    switch (iconName) {
      case 'work': return Icons.work_rounded;
      case 'home': return Icons.home_rounded;
      case 'shopping': return Icons.shopping_cart_rounded;
      case 'health': return Icons.favorite_rounded;
      case 'education': return Icons.school_rounded;
      case 'travel': return Icons.flight_rounded;
      case 'finance': return Icons.account_balance_rounded;
      case 'personal': return Icons.person_rounded;
      case 'fitness': return Icons.fitness_center_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'music': return Icons.music_note_rounded;
      case 'art': return Icons.palette_rounded;
      case 'tech': return Icons.developer_mode_rounded;
      case 'sport': return Icons.sports_rounded;
      case 'book': return Icons.book_rounded;
      case 'game': return Icons.videogame_asset_rounded;
      default: return Icons.category_rounded;
    }
  }
}

// Provider for category icons
final categoryIconProvider = Provider<List<String>>((ref) => Category.availableIcons);
