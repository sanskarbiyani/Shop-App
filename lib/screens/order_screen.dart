import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatelessWidget {
  static const route = '/orders';
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    orderData.fetchAllOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders.'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemBuilder: (ctx, ind) => OrderItem(orderData.orders[ind]),
        itemCount: orderData.orders.length,
      ),
    );
  }
}
