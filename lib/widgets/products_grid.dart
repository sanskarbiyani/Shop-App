import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../models/products.dart';
import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavOnly;

  const ProductsGrid(this.showFavOnly, {super.key});

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        showFavOnly ? productsData.favouriteItems : productsData.items;

    // products.forEach((element) {
    //   print(element.title);
    // });

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
      // the '.value' approach is to be used where we have the provider package
      // and we are providing the data to single list/grid items
      // where recycling happens instead of recreating the item.
      itemBuilder: (ctx, ind) {
        // print('Inside : ${products[ind].title}');
        return ChangeNotifierProvider.value(
          value: products[ind],
          child: const ProductItem(),
        );
      },
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
      ),
    );
  }
}
