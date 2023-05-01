// ignore_for_file: prefer_final_fields
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  // var _showFavouritesOnly = false;
  Future<void> fetchAllProducts() async {
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/products.json');

    try {
      final response = await http.get(url);
      // print(jsonDecode(response.body));
      final res = jsonDecode(response.body);
      if (res == null) {
        throw "No Products found";
      }
      final body = (res ?? {}) as Map<String, dynamic>;
      if (response.statusCode == 401) {
        throw Exception(response.statusCode);
      }
      final List<Product> loadedProds = [];
      body.forEach((key, value) {
        loadedProds.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite: value['isFavourite'],
          ),
        );
      });
      _items = loadedProds;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<Product> get favouriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  List<Product> get items {
    // if (_showFavouritesOnly == true) {
    //   return _items.where((element) => element.isFavorite).toList();
    // }
    return [..._items];
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> addProduct(Product prod) async {
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/products.json');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'title': prod.title,
            'description': prod.description,
            'imageUrl': prod.imageUrl,
            'price': prod.price,
            'isFavourite': prod.isFavorite,
          },
        ),
      );
      final newProd = Product(
        id: jsonDecode(response.body)['name'],
        title: prod.title,
        description: prod.description,
        imageUrl: prod.imageUrl,
        price: prod.price,
        isFavorite: prod.isFavorite,
      );
      _items.add(newProd);
      notifyListeners();
    } catch (error) {
      // ignore: avoid_print
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    var ind = _items.indexWhere((element) => element.id == id);
    if (ind >= 0) {
      final url = Uri.parse(
          'https://my-shop-demo-28821-default-rtdb.firebaseio.com/products/$id.json');
      print("url: ${url.toString()}");
      final body = {
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      };
      try {
        await http.patch(url, body: jsonEncode(body));
      } catch (error) {
        rethrow;
      }
      _items[ind] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://my-shop-demo-28821-default-rtdb.firebaseio.com/products/$id.json');
    final existingProdInd = _items.indexWhere((element) => element.id == id);
    Product? exisitingProd = _items[existingProdInd];

    _items.removeAt(existingProdInd);
    notifyListeners();

    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.insert(existingProdInd, exisitingProd);
      notifyListeners();
      throw const HttpException("Could not delete product");
    }
    exisitingProd = null;
  }
}
