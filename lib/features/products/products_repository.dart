import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/config.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref.read(dioProvider));
});

class Product {
  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.compareAtPriceCents,
    required this.stockQty,
    required this.coverImageUrl,
    required this.imagesUrls,
    required this.descriptionHtml,
    required this.sectionsJson,
  });

  final String id;
  final String name;
  final String? description;
  final int priceCents;
  final int? compareAtPriceCents;
  final int stockQty;
  final String? coverImageUrl;
  final List<String> imagesUrls;
  final String? descriptionHtml;
  final dynamic sectionsJson;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imagesUrls'];
    final images = <String>[];
    if (rawImages is List) {
      for (final v in rawImages) {
        if (v is String && v.trim().isNotEmpty) images.add(v);
      }
    }

    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceCents: (json['priceCents'] as num).toInt(),
      compareAtPriceCents: (json['compareAtPriceCents'] as num?)?.toInt(),
      stockQty: (json['stockQty'] as num?)?.toInt() ?? 0,
      coverImageUrl: json['coverImageUrl'] as String?,
      imagesUrls: images,
      descriptionHtml: json['descriptionHtml'] as String?,
      sectionsJson: json['sectionsJson'],
    );
  }
}

class ProductsRepository {
  ProductsRepository(this._dio);

  final Dio _dio;

  Future<List<Product>> list() async {
    final res = await _dio.get<List<dynamic>>(
      '/products',
      queryParameters: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }

  Future<Product> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/products/$id',
      queryParameters: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid product detail response');
    }
    return Product.fromJson(data);
  }

  Future<Product> create({
    required String name,
    required int priceCents,
    int? compareAtPriceCents,
    required int stockQty,
    String? description,
    String? coverImageUrl,
    List<String>? imagesUrls,
    String? descriptionHtml,
    dynamic sectionsJson,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/products',
      data: {
        'name': name,
        'description': (description ?? '').trim().isEmpty ? null : description,
        'coverImageUrl': (coverImageUrl ?? '').trim().isNotEmpty
            ? coverImageUrl
            : null,
        'imagesUrls': imagesUrls,
        'descriptionHtml': (descriptionHtml ?? '').trim().isEmpty
            ? null
            : descriptionHtml,
        'sectionsJson': sectionsJson,
        'priceCents': priceCents,
        'compareAtPriceCents': compareAtPriceCents,
        'stockQty': stockQty,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid create product response');
    }
    return Product.fromJson(data);
  }

  Future<Product> update({
    required String id,
    String? name,
    String? description,
    int? priceCents,
    int? compareAtPriceCents,
    int? stockQty,
    String? coverImageUrl,
    List<String>? imagesUrls,
    String? descriptionHtml,
    dynamic sectionsJson,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/products/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null)
          'description': description.trim().isEmpty ? null : description,
        if (priceCents != null) 'priceCents': priceCents,
        if (compareAtPriceCents != null)
          'compareAtPriceCents': compareAtPriceCents,
        if (stockQty != null) 'stockQty': stockQty,
        if (coverImageUrl != null)
          'coverImageUrl': coverImageUrl.trim().isNotEmpty
              ? coverImageUrl
              : null,
        if (imagesUrls != null) 'imagesUrls': imagesUrls,
        if (descriptionHtml != null)
          'descriptionHtml': descriptionHtml.trim().isEmpty
              ? null
              : descriptionHtml,
        if (sectionsJson != null) 'sectionsJson': sectionsJson,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid update product response');
    }
    return Product.fromJson(data);
  }

  Future<void> delete({required String id}) async {
    await _dio.delete<void>('/products/$id');
  }
}
