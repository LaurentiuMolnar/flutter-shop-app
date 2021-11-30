import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shop/providers/cart.dart';
import 'package:http/http.dart' as http;

const baseUrl = String.fromEnvironment('FIREBASE_BASE_URL', defaultValue: '');

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  const OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders({
    this.authToken,
    this.userId,
    required List<OrderItem> initialData,
  }) : _orders = initialData;

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse('$baseUrl/orders/$userId.json?auth=$authToken');

    final now = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'amount': total,
          'dateTime': now.toIso8601String(),
          'products': cartProducts
              .map(
                (item) => {
                  'id': item.id,
                  'title': item.title,
                  'quantity': item.quantity,
                  'price': item.price,
                  'productId': item.productId,
                },
              )
              .toList(),
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: now,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse('$baseUrl/orders/$userId.json?auth=$authToken');

    final response = await http.get(url);

    final List<OrderItem> loadedItems = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, data) {
      loadedItems.add(OrderItem(
          id: orderId,
          amount: data['amount'],
          dateTime: DateTime.parse(data['dateTime']),
          products: (data['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                  productId: item['productId'],
                ),
              )
              .toList()));
    });

    _orders = [...loadedItems.reversed.toList()];
    notifyListeners();
  }
}
