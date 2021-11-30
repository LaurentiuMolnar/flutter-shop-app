import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart' show Orders;
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(
          context,
          listen: false,
        ).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          return dataSnapshot.connectionState == ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : Consumer<Orders>(
                  builder: (ctx, ordersProvider, child) => ListView.builder(
                    itemCount: ordersProvider.orders.length,
                    itemBuilder: (ctx, idx) => OrderItem(
                      order: ordersProvider.orders[idx],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
