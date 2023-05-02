import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class ShoppingCartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  const ShoppingCartItem({
    required this.id,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Delete?'),
            content: Text('Do you want to remove $title from the cart?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      background: Container(
        color: Theme.of(context).colorScheme.error,
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 15,
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: FittedBox(
                  child: Text(
                '\$$price',
                style: TextStyle(
                  color: Theme.of(context).primaryTextTheme.titleMedium?.color,
                ),
              )),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Provider.of<Cart>(context, listen: false)
                        .addItem(productId, price, title);
                  },
                  icon: Icon(
                    Icons.add,
                    size: 30,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  '$quantity',
                  style: const TextStyle(fontSize: 30, color: Colors.black54),
                ),
                IconButton(
                    onPressed: () {
                      Provider.of<Cart>(context, listen: false)
                          .removeSingleItem(productId);
                    },
                    icon: Icon(
                      Icons.remove,
                      size: 30,
                      color: Theme.of(context).colorScheme.primary,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
