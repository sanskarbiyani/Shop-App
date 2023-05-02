import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/products.dart';

enum FilterOptions {
  favourites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavourites = false;
  // var _init = true;
  var _isLoading = false;
  var _noProductsAvailable = false;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    Future.delayed(Duration.zero, () async {
      await _loadProducts();
    });
    // WORKAROUND-1: For fetching initial data when widget not built completly
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAllProducts();
    // });
  }

  Future<void> _loadProducts() async {
    // Getting all the products.
    try {
      final _ = await Provider.of<Products>(context, listen: false)
          .fetchAllProducts();
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      if (err.runtimeType == int && err as int >= 400) {
        await _showAlertDialog();
      } else if (err == "No Products found") {
        setState(() {
          _noProductsAvailable = true;
        });
      }

      setState(() {
        _isLoading = false;
      });
    }

    try {
      if (context.mounted) {
        final _ =
            await Provider.of<Cart>(context, listen: false).fetchFullCart();
      }
    } catch (err) {
      // ignore: avoid_print
      print(err);
    }
  }

  Future<void> _showAlertDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Some error occured."),
        content: const Text("Please try again later."),
        actions: [
          TextButton(
            onPressed: () =>
                SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  // WORKAROUND-2: For fetching initial data when widget not built completly
  // @override
  // void didChangeDependencies() {
  //   if (_init) {
  //     Provider.of<Products>(context).fetchAllProducts();
  //     _init = false;
  //   }
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              if (value == FilterOptions.favourites) {
                // productsContainer.showFavouritesOnly();
                setState(() {
                  _showOnlyFavourites = true;
                });
              } else {
                setState(() {
                  _showOnlyFavourites = false;
                });
                // productsContainer.showAll();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: FilterOptions.favourites,
                child: Text('Only Favourites'),
              ),
              PopupMenuItem(
                value: FilterOptions.all,
                child: Text('All Items'),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => CartBadge(
              value: cartData.itemCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.route);
              },
            ),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            // margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
            child: Text(
              _showOnlyFavourites ? 'Favourite Items' : 'All Items',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _noProductsAvailable
                      ? Column(
                          children: const [
                            SizedBox(height: 50),
                            Text(
                              "No Products available for display,",
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        )
                      : ProductsGrid(_showOnlyFavourites)),
        ],
      ),
    );
  }
}
