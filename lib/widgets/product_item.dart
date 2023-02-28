import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imgUrl;

  const ProductItem({
    super.key,
    // required this.id,
    // required this.title,
    // required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final scaffold = ScaffoldMessenger.of(context);
    // final cart = Provider.of<Cart>(context, listen: false);
    // Creates a listener to the provider so that it can listen to changes
    // and rebuild the widget when the value changes.

    // Provider.of() causes the entire widget to be rebuilt.
    // By wrapping a specific section/part of the widget inside the consumer
    // will cause only that part/section of the widget to be rebuilt.
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            ProductDetailScreen.route,
            arguments: product.id,
          );
        },
        child: GridTile(
          footer: GridTileBar(
            leading: Consumer<Product>(
              builder: (ctx, prod, _) => IconButton(
                icon: Icon(
                    prod.isFavorite ? Icons.favorite : Icons.favorite_border),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () async {
                  try {
                    await product.toggleFavoriteStatus();
                    scaffold.showSnackBar(
                      SnackBar(
                        content: Text(
                            "Favourite Status updated to ${prod.isFavorite}"),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  } catch (_) {
                    scaffold.showSnackBar(
                      const SnackBar(
                        content: Text("Cannot update favourite status."),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ),
            title: Text(product.title, textAlign: TextAlign.center),
            backgroundColor: Colors.black54,
            trailing: Consumer<Cart>(
              builder: (cont, c, _) => IconButton(
                icon: Icon(c.isPresent(product.id)
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  c.addItem(product.id, product.price, product.title);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Item Added to cart'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          c.removeSingleItem(product.id);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
