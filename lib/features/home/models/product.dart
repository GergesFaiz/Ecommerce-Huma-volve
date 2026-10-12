import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<Color> colors;
  final List<String> sizes;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.colors,
    required this.sizes,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List;
    return Product(
      id: json['id'].toString(),
      name: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: images.isNotEmpty ? images.first : '',
      // colors and sizes are not in the API
      colors: [Colors.black, Colors.white, Colors.grey],
      sizes: ['S', 'M', 'L', 'XL'],
    );
  }
}
