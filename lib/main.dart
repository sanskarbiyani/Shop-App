import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/order_screen.dart';
import './providers/orders.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // It is better to not use '.value' in the main file or everywhere
    // where we are creating (new object)/instantiating a class to improve efficiency
    //
    // And better to use the '.create' approach
    // everywhere where we are re-using the already created objects
    // so that we can deal with the errors arising due to recycling of objects.

    // On navigating to a complete new screen, we have to clear all the data of the providers
    // otherwise it will occupy unnecessary memory and lead to memory leak
    // The changeNotifierProvider automatically does this for us.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Products(),
        ),
        ChangeNotifierProvider(
          create: (_) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (_) => Orders(),
        ),
      ],
      child: MaterialApp(
        title: 'MyShop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
            accentColor: Colors.deepOrange,
          ),
          fontFamily: 'Lato',
          textTheme: const TextTheme(
              // bodyLarge: TextStyle(
              //   fontSize: 20,
              //   fontFamily: 'Anton',
              // ),
              ),
        ),
        home: const ProductsOverviewScreen(),
        routes: {
          ProductDetailScreen.route: (ctx) => const ProductDetailScreen(),
          CartScreen.route: (ctx) => const CartScreen(),
          OrderScreen.route: (ctx) => const OrderScreen(),
        },
      ),
    );
  }
}
