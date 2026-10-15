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
    final images = _extractValidImageUrls(json['images'] as List? ?? const []);
    return ProductModel(
      id: json['id'].toString(),
      name: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      // empty when the API sent no usable link; the UI shows a placeholder
      imageUrl: images.isNotEmpty ? images.first : '',
      // colors and sizes are not in the API
      colors: const [Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFF9E9E9E)],
      sizes: const ['S', 'M', 'L', 'XL'],
    );
  }

  static final _urlRegex = RegExp(r'https?://[^\s"\[\]\\]+');

  // The API sometimes returns broken entries like '["https://..."]',
  // so pull out every real http(s) link instead of trusting the raw string.
  static List<String> _extractValidImageUrls(List rawImages) {
    final validUrls = <String>[];
    for (final raw in rawImages) {
      if (raw is! String) continue;
      for (final match in _urlRegex.allMatches(raw)) {
        final url = match.group(0)!.replaceAll(RegExp(r'[,.]+$'), '');
        final uri = Uri.tryParse(url);
        if (uri != null && uri.host.isNotEmpty) validUrls.add(url);
      }
    }
    return validUrls;
  }
}
