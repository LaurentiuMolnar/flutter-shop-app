import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Products>(
          context,
          listen: false,
        ).fetchAndSetProducts(filterByUser: true),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? const Center(child: CircularProgressIndicator.adaptive())
            : RefreshIndicator(
                onRefresh: () async {
                  await Provider.of<Products>(
                    context,
                    listen: false,
                  ).fetchAndSetProducts(filterByUser: true);
                },
                child: Consumer<Products>(
                  builder: (ctx, productsProvider, child) => ListView.separated(
                    itemCount: productsProvider.items.length,
                    itemBuilder: (ctx, i) {
                      final product = productsProvider.items[i];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          8.0,
                          i == 0 ? 8 : 4,
                          8,
                          i == productsProvider.items.length - 1 ? 8 : 4,
                        ),
                        child: UserProductItem(
                          productId: product.id,
                          title: product.title,
                          imageUrl: product.imageUrl,
                        ),
                      );
                    },
                    separatorBuilder: (ctx, i) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Divider(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
