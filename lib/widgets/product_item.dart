import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/screens/product_details_screen.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({
    Key? key,
  }) : super(key: key);

  IconButton buildIconButton(
    BuildContext ctx, {
    required IconData icon,
    void Function()? onPressedHandler,
  }) {
    return IconButton(
      icon: Icon(
        icon,
      ),
      color: Theme.of(ctx).colorScheme.secondary,
      onPressed: onPressedHandler ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(
      context,
      listen: false,
    );
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<Auth>(
      context,
      listen: false,
    );

    final sm = ScaffoldMessenger.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailsScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              placeholder:
                  const AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(product.imageUrl),
              fit: BoxFit.contain,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => buildIconButton(
              context,
              icon:
                  product.isFavorite ? Icons.favorite : Icons.favorite_outline,
              onPressedHandler: () async {
                try {
                  await product.toggleFavoriteStatus(
                      authProvider.token!, authProvider.userId!);
                } catch (e) {
                  sm.showSnackBar(const SnackBar(
                    content: Text(
                      'Toggle favorite failed',
                      textAlign: TextAlign.center,
                    ),
                  ));
                }
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: buildIconButton(
            context,
            icon: Icons.shopping_cart,
            onPressedHandler: () {
              cart.addItem(
                productId: product.id,
                title: product.title,
                price: product.price,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Added item to cart'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.removeSingleItem(product.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
