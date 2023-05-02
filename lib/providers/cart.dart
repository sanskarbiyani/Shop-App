import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });
}

class Cart with ChangeNotifier {
  // ignore: prefer_final_fields
  Map<String, CartItem> _items = {};
  // Here, the map has the product id as the "key" and the cart-item as the values.
  // It is done so, because we want to uniquely identify any item in the cart, hence the product id as ky
  // and the value contains the item details, such as the quantity and product details.

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  bool isPresent(String id) {
    return _items.containsKey(id);
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  Future<void> removeItem(String productId) async {
    final uri = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/cart/$productId.json');
    try {
      final _ = await http.delete(uri);
      // print("Status Code: ${res.statusCode}");
      // final body = jsonDecode(res.body);
      // print("Error: $body");
    } catch (err) {
      rethrow;
    }
    _items.remove(productId);
    notifyListeners();
  }

  Future<void> addItem(String productId, double price, String title) async {
    final uri = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/cart/$productId.json');

    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartItem(
            id: value.id,
            price: value.price,
            title: value.title,
            quantity: value.quantity + 1),
      );
      try {
        final _ = await http.patch(uri,
            body: jsonEncode({'quantity': _items[productId]?.quantity}));
        // print("Response Status Code: ${res.statusCode}");
      } catch (err) {
        rethrow;
      }
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
      try {
        final body = {
          "id": DateTime.now().toString(),
          "title": title,
          "quantity": 1,
          "price": price,
        };
        final _ = await http.put(
          uri,
          body: jsonEncode(body),
        );
        // print("Response status code: ${res.statusCode}");
      } catch (err) {
        rethrow;
      }
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  Future<void> removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) {
      return;
    }

    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/cart/$productId.json');
    if ((_items[productId] as CartItem).quantity > 1) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          price: value.price,
          quantity: value.quantity - 1,
        ),
      );
      try {
        final _ = await http.patch(url,
            body: jsonEncode({'quantity': _items[productId]?.quantity}));
        // print("Status Code: ${res.statusCode}");
      } catch (err) {
        rethrow;
      }
    } else {
      _items.remove(productId);
      try {
        final _ = await http.delete(url);
        // print("Status Code: ${res.statusCode}");
      } catch (err) {
        rethrow;
      }
    }
    notifyListeners();
  }
}
