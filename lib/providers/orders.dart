// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime orderDate;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.orderDate,
  });
}

class Orders with ChangeNotifier {
  // ignore: prefer_final_fields
  Map<String, OrderItem> _orders = {};

  List<OrderItem> get orders {
    return _orders.values.toList();
  }

  Future<void> fetchAllOrders() async {
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/orders.json');
    try {
      final res = await http.get(url);
      final responseBody = jsonDecode(res.body);
      final Map<String, OrderItem> orders = {};
      // left to do.
    } catch (err) {
      rethrow;
    }
  }

  Future<void> addOrder(List<String> productIds, List<CartItem> cartProducts,
      double total) async {
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/orders.json');

    List<dynamic> orderProducts = [];
    for (final pairs in IterableZip([productIds, cartProducts])) {
      final orderProduct = {
        "id": pairs[0],
        "title": (pairs[1] as CartItem).title,
        "quantity": (pairs[1] as CartItem).quantity,
        "price": (pairs[1] as CartItem).price,
      };
      orderProducts.add(orderProduct);
    }

    final requestBody = {
      "id": DateTime.now().toString(),
      "amount": total,
      "products": orderProducts,
      "orderDate": DateTime.now().toString(),
    };

    String orderId;
    try {
      final res = await http.post(url, body: jsonEncode(requestBody));
      final responseBody = jsonDecode(res.body);
      orderId = responseBody['name'];
    } catch (err) {
      rethrow;
    }
    _orders.putIfAbsent(
      orderId,
      () => OrderItem(
        id: DateTime.now().toString(),
        amount: total,
        products: cartProducts,
        orderDate: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
