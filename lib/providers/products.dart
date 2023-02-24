// ignore_for_file: prefer_final_fields
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavouritesOnly = false;
  Future<void> fetchAllProducts() async {
    final url = Uri.parse(
        'https://my-shop-app-ffcd8-default-rtdb.firebaseio.com/products.json');

    try {
      final response = await http.get(url);
      // print(jsonDecode(response.body));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProds = [];
      body.forEach((key, value) {
        loadedProds.add(
          Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imgeUrl'],
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
        'https://my-shop-app-ffcd8-default-rtdb.firebaseio.com/products.json');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(
          {
            'title': prod.title,
            'description': prod.description,
            'imgeUrl': prod.imageUrl,
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

  void updateProduct(String id, Product newProduct) {
    var ind = _items.indexWhere((element) => element.id == id);
    if (ind >= 0) {
      _items[ind] = newProduct;
      notifyListeners();
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
  }
}
