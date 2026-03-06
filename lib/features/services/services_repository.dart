import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/config.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return ServicesRepository(ref.read(dioProvider));
});

class LinkedArticleSummary {
  LinkedArticleSummary({
    required this.type,
    required this.id,
    required this.title,
    required this.coverImageUrl,
    required this.priceCents,
    required this.compareAtPriceCents,
  });

  final String type;
  final String id;
  final String title;
  final String? coverImageUrl;
  final int priceCents;
  final int? compareAtPriceCents;

  factory LinkedArticleSummary.fromJson(Map<String, dynamic> json) {
    return LinkedArticleSummary(
      type: (json['type'] as String?) ?? 'service',
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
      compareAtPriceCents: (json['compareAtPriceCents'] as num?)?.toInt(),
    );
  }
}

class Service {
  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.compareAtPriceCents,
    required this.visibility,
    required this.assignedUserId,
    required this.assignedUserEmail,
    required this.coverImageUrl,
    required this.imagesUrls,
    required this.descriptionHtml,
    required this.sectionsJson,
    required this.linkedArticles,
  });

  final String id;
  final String name;
  final String? description;
  final int priceCents;
  final int? compareAtPriceCents;
  final String visibility;
  final String? assignedUserId;
  final String? assignedUserEmail;
  final String? coverImageUrl;
  final List<String> imagesUrls;
  final String? descriptionHtml;
  final dynamic sectionsJson;
  final List<LinkedArticleSummary> linkedArticles;

  factory Service.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imagesUrls'];
    final images = <String>[];
    if (rawImages is List) {
      for (final v in rawImages) {
        if (v is String && v.trim().isNotEmpty) images.add(v);
      }
    }

    final linked = <LinkedArticleSummary>[];
    final rawLinked = json['linkedArticles'];
    if (rawLinked is List) {
      for (final v in rawLinked) {
        if (v is Map<String, dynamic>) {
          linked.add(LinkedArticleSummary.fromJson(v));
        }
      }
    }

    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
      compareAtPriceCents: (json['compareAtPriceCents'] as num?)?.toInt(),
      visibility: (json['visibility'] as String?) ?? 'public',
      assignedUserId: json['assignedUserId'] as String?,
      assignedUserEmail: json['assignedUserEmail'] as String?,
      coverImageUrl: json['coverImageUrl'] as String?,
      imagesUrls: images,
      descriptionHtml: json['descriptionHtml'] as String?,
      sectionsJson: json['sectionsJson'],
      linkedArticles: linked,
    );
  }
}

class ServicesRepository {
  ServicesRepository(this._dio);

  final Dio _dio;

  Future<List<Service>> list() async {
    final res = await _dio.get<List<dynamic>>(
      '/services',
      queryParameters: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Service.fromJson)
        .toList(growable: false);
  }

  Future<Service> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/services/$id',
      queryParameters: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid service detail response');
    }
    return Service.fromJson(data);
  }

  Future<Service> create({
    required String name,
    String? description,
    int? priceCents,
    int? compareAtPriceCents,
    String? visibility,
    String? assignedUserId,
    String? assignedUserEmail,
    String? coverImageUrl,
    List<String>? imagesUrls,
    String? descriptionHtml,
    dynamic sectionsJson,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/services',
      data: {
        'name': name,
        'description': (description ?? '').trim().isEmpty ? null : description,
        if (priceCents != null) 'priceCents': priceCents,
        if (compareAtPriceCents != null)
          'compareAtPriceCents': compareAtPriceCents,
        if (visibility != null) 'visibility': visibility,
        if (assignedUserId != null) 'assignedUserId': assignedUserId,
        if (assignedUserEmail != null) 'assignedUserEmail': assignedUserEmail,
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
      throw Exception('Invalid create service response');
    }
    return Service.fromJson(data);
  }

  Future<Service> update({
    required String id,
    String? name,
    String? description,
    int? priceCents,
    int? compareAtPriceCents,
    String? visibility,
    String? assignedUserId,
    String? assignedUserEmail,
    String? coverImageUrl,
    List<String>? imagesUrls,
    String? descriptionHtml,
    dynamic sectionsJson,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/services/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null)
          'description': description.trim().isEmpty ? null : description,
        if (priceCents != null) 'priceCents': priceCents,
        if (compareAtPriceCents != null)
          'compareAtPriceCents': compareAtPriceCents,
        if (visibility != null) 'visibility': visibility,
        if (assignedUserId != null) 'assignedUserId': assignedUserId,
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
      throw Exception('Invalid update service response');
    }
    return Service.fromJson(data);
  }

  Future<void> delete({required String id}) async {
    await _dio.delete<void>('/services/$id');
  }

  Future<void> adminReorder(List<Service> ordered) async {
    await _dio.patch<void>(
      '/services/reorder',
      data: {
        'order': [
          for (var i = 0; i < ordered.length; i++)
            {'id': ordered[i].id, 'sortOrder': i},
        ],
      },
    );
  }
}
