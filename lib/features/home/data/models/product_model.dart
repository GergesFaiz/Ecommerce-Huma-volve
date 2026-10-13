import 'dart:ui' show Color;

import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.colors,
    required super.sizes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List;
    return ProductModel(
      id: json['id'].toString(),
      name: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imageUrl: images.isNotEmpty ? images.first : '',
      // colors and sizes are not in the API
      colors: const [Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFF9E9E9E)],
      sizes: const ['S', 'M', 'L', 'XL'],
    );
  }
}
