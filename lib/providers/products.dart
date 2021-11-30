import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop/models/http_exception.dart';
import 'package:shop/providers/product.dart';
import 'package:http/http.dart' as http;

const baseUrl = String.fromEnvironment('FIREBASE_BASE_URL', defaultValue: '');

class Products with ChangeNotifier {
  List<Product> _items = [];

  String? authToken;
  String? userId;

  Products({
    this.authToken,
    this.userId,
    required List<Product> initialData,
  }) : _items = initialData;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('$baseUrl/products.json?auth=$authToken');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          },
        ),
      );

      final newProduct = Product.from(
        product,
        id: json.decode(response.body)['name'],
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final idx = _items.indexWhere((element) => element.id == id);

    if (idx >= 0) {
      final url = Uri.parse('$baseUrl/products/$id.json?auth=$authToken');

      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );

      _items[idx] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('$baseUrl/products/$id.json?auth=$authToken');

    final productIndex = _items.indexWhere((element) => element.id == id);
    Product? product = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();

    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      _items.insert(productIndex, product);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    product = null;
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/products.json?auth=$authToken$filterString'));
      final extractedData = json.decode(response.body) as Map<String, dynamic>?;
      final List<Product> loadedProducts = [];

      if (extractedData == null) {
        return;
      }

      final favoriteStatusResponse = await http.get(
          Uri.parse('$baseUrl/userFavorites/$userId.json?auth=$authToken'));
      final favoriteData = json.decode(favoriteStatusResponse.body);

      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          price: productData['price'],
          isFavorite: (favoriteData ?? const {})[productId] ?? false,
        ));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
