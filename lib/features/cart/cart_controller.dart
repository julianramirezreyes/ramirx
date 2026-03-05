import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cartKey = 'ramirx_cart_v1';

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);

enum CartItemType { product, course }

class CartItem {
  CartItem({
    required this.type,
    required this.id,
    required this.title,
    required this.priceCents,
    required this.quantity,
  });

  final CartItemType type;
  final String id;
  final String title;
  final int priceCents;
  final int quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      type: type,
      id: id,
      title: title,
      priceCents: priceCents,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'id': id,
      'title': title,
      'priceCents': priceCents,
      'quantity': quantity,
    };
  }

  static CartItem fromJson(Map<String, dynamic> json) {
    final typeRaw = json['type'] as String;
    final type = CartItemType.values.firstWhere(
      (t) => t.name == typeRaw,
      orElse: () => CartItemType.product,
    );

    return CartItem(
      type: type,
      id: json['id'] as String,
      title: json['title'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class CartState {
  const CartState({required this.items});

  final List<CartItem> items;

  int get totalCents => items.fold(0, (sum, i) => sum + i.priceCents * i.quantity);

  int get totalQty => items.fold(0, (sum, i) => sum + i.quantity);

  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);

  static const empty = CartState(items: []);
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    _load();
    return CartState.empty;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! List) return;

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(CartItem.fromJson)
        .toList(growable: false);

    state = state.copyWith(items: items);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.items.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_cartKey, raw);
  }

  Future<void> add({
    required CartItemType type,
    required String id,
    required String title,
    required int priceCents,
  }) async {
    final existingIndex = state.items.indexWhere((i) => i.type == type && i.id == id);

    List<CartItem> next;
    if (existingIndex >= 0) {
      final existing = state.items[existingIndex];
      next = [...state.items];
      next[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      next = [
        ...state.items,
        CartItem(type: type, id: id, title: title, priceCents: priceCents, quantity: 1),
      ];
    }

    state = state.copyWith(items: next);
    await _persist();
  }

  Future<void> setQty(CartItem item, int qty) async {
    final nextQty = qty < 1 ? 1 : qty;
    final next = state.items
        .map((i) => i.type == item.type && i.id == item.id ? i.copyWith(quantity: nextQty) : i)
        .toList(growable: false);

    state = state.copyWith(items: next);
    await _persist();
  }

  Future<void> remove(CartItem item) async {
    state = state.copyWith(
      items: state.items.where((i) => !(i.type == item.type && i.id == item.id)).toList(growable: false),
    );
    await _persist();
  }

  Future<void> clear() async {
    state = CartState.empty;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
