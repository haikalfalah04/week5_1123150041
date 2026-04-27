import 'package:flutter/material.dart';

import '../../../dashboard/data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';

/// CartProvider — State management keranjang belanja
/// Menggunakan ChangeNotifier + notifyListeners() (WAJIB Provider pattern)
class CartProvider extends ChangeNotifier {
  // Map productId → CartItemModel untuk akses cepat
  final Map<int, CartItemModel> _items = {};

  // ─── Getters ───
  List<CartItemModel> get items => _items.values.toList();
  int get itemCount => _items.length;
  bool get isEmpty => _items.isEmpty;

  double get totalPrice {
    double total = 0;
    for (final item in _items.values) {
      total += item.subtotal;
    }
    return total;
  }

  int get totalQuantity {
    int total = 0;
    for (final item in _items.values) {
      total += item.quantity;
    }
    return total;
  }

  // ─── Tambah barang ke keranjang ───
  void addToCart(ProductModel product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItemModel(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  // ─── Hapus barang dari keranjang ───
  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // ─── Tambah quantity ───
  void increaseQuantity(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  // ─── Kurangi quantity ───
  void decreaseQuantity(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  // ─── Cek apakah produk sudah ada di cart ───
  bool isInCart(int productId) => _items.containsKey(productId);

  // ─── Kosongkan keranjang ───
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
