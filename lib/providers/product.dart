import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const baseUrl = String.fromEnvironment('FIREBASE_BASE_URL', defaultValue: '');

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.isFavorite = false,
  });

  Product.from(
    Product source, {
    String? id,
    String? imageUrl,
    String? title,
    String? description,
    double? price,
    bool? isFavorite,
  }) : this(
          id: id ?? source.id,
          imageUrl: imageUrl ?? source.imageUrl,
          title: title ?? source.title,
          price: price ?? source.price,
          description: description ?? source.description,
          isFavorite: isFavorite ?? source.isFavorite,
        );

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url =
        Uri.parse('$baseUrl/userFavorites/$userId/$id.json?auth=$token');

    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );

      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (e) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
