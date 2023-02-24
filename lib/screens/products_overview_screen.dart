import 'package:flutter/material.dart';
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

  @override
  void initState() {
    _isLoading = true;
    Provider.of<Products>(context, listen: false).fetchAllProducts().then(
      (value) {
        setState(() {
          _isLoading = false;
        });
      },
    );
    // WORKAROUND-1: For fetching initial data when widget not built completly
    // Future.delayed(Duration.zero).then((_) {
    //   Provider.of<Products>(context).fetchAllProducts();
    // });
    super.initState();
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
                : ProductsGrid(_showOnlyFavourites),
          ),
        ],
      ),
    );
  }
}
