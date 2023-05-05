import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    // Optimistically loading is used.
    // First the local state is changed and then the request is sent.
    // If the request is successfull then all is good,
    // otherwise, we change the local state again.
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/products/$id.json');

    try {
      final res =
          await http.patch(url, body: jsonEncode({'isFavourite': isFavorite}));
      if (res.statusCode >= 400) {
        throw Exception("Request Failed!");
      }
      // print(jsonDecode(res.body));
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw const HttpException("Cannot add to favourites");
    }
  }
}
