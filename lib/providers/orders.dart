// ignore_for_file: avoid_print
import 'dart:convert';

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
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAllOrders() async {
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/orders.json');
    try {
      final res = await http.get(url);
      final List<OrderItem> loadedOrders = [];
      if (jsonDecode(res.body) == null || res.statusCode >= 400) {
        throw Exception("Request Failed.");
      }
      final extractedData = jsonDecode(res.body) as Map<String, dynamic>;
      extractedData.forEach(
        (orderId, orderData) {
          loadedOrders.add(
            OrderItem(
              id: orderId,
              amount: orderData['amount'],
              orderDate: DateTime.parse(orderData['orderDate']),
              products: (orderData['products'] as List<dynamic>)
                  .map(
                    (e) => CartItem(
                      id: e['id'],
                      title: e['title'],
                      quantity: e['quantity'],
                      price: e['price'],
                    ),
                  )
                  .toList(),
            ),
          );
        },
      );
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final orderDate = DateTime.now();
    String orderId = "";
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/orders.json');

    final requestBody = {
      "amount": total,
      "orderDate": orderDate.toIso8601String(),
      "products": cartProducts
          .map((e) => {
                "id": e.id,
                "title": e.title,
                "quantity": e.quantity,
                "price": e.price,
              })
          .toList(),
    };
    try {
      final res = await http.post(url, body: jsonEncode(requestBody));
      if (res.statusCode >= 400) {
        throw Exception("Request Failed!");
      }
      orderId = jsonDecode(res.body)['name'];
    } catch (err) {
      rethrow;
    }
    _orders.insert(
      0,
      OrderItem(
        id: orderId,
        amount: total,
        products: cartProducts,
        orderDate: orderDate,
      ),
    );
    notifyListeners();
  }
}
