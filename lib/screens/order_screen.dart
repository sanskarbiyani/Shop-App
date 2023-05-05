import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

class OrderScreen extends StatefulWidget {
  static const route = '/orders';
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  Future? _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAllOrders();
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  // We can reduce the above overhead if our widget does not build itself again.
  // Because if the widget get built again, then the Future builder widget will run,
  // resulting in the http and other code written in the method to run which we do not want.
  // Therefore, we have to use the above overhead

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders.'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (dataSnapShot.hasError) {
              return const Center(
                child: Text(
                  'No orders available.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                  ),
                ),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemBuilder: (ctx, ind) => OrderItem(orderData.orders[ind]),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          }),
    );
  }
}
