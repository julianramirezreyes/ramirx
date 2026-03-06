import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/config.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository(ref.read(dioProvider));
});

class Course {
  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.priceCents,
    required this.compareAtPriceCents,
    required this.coverImageUrl,
    required this.imagesUrls,
    required this.descriptionHtml,
    required this.sectionsJson,
  });

  final String id;
  final String title;
  final String? description;
  final String level;
  final int priceCents;
  final int? compareAtPriceCents;
  final String? coverImageUrl;
  final List<String> imagesUrls;
  final String? descriptionHtml;
  final dynamic sectionsJson;

  factory Course.fromJson(Map<String, dynamic> json) {
    final rawImages = json['imagesUrls'];
    final images = <String>[];
    if (rawImages is List) {
      for (final v in rawImages) {
        if (v is String && v.trim().isNotEmpty) images.add(v);
      }
    }

    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      level: json['level'] as String,
      priceCents: (json['priceCents'] as num).toInt(),
      compareAtPriceCents: (json['compareAtPriceCents'] as num?)?.toInt(),
      coverImageUrl: json['coverImageUrl'] as String?,
      imagesUrls: images,
      descriptionHtml: json['descriptionHtml'] as String?,
      sectionsJson: json['sectionsJson'],
    );
  }
}

class CoursesRepository {
  CoursesRepository(this._dio);

  final Dio _dio;

  Future<List<Course>> list() async {
    final res = await _dio.get<List<dynamic>>(
      '/courses',
      queryParameters: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Course.fromJson)
        .toList(growable: false);
  }

  Future<Course> getById(String id) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/courses/$id',
      queryParameters: {
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid course detail response');
    }
    return Course.fromJson(data);
  }

  Future<Course> create({
    required String title,
    required String level,
    required int priceCents,
    int? compareAtPriceCents,
    String? description,
    String? coverImageUrl,
    List<String>? imagesUrls,
    String? descriptionHtml,
    dynamic sectionsJson,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/courses',
      data: {
        'title': title,
        'description': (description ?? '').trim().isEmpty ? null : description,
        'coverImageUrl': (coverImageUrl ?? '').trim().isNotEmpty
            ? coverImageUrl
            : null,
        'imagesUrls': imagesUrls,
        'descriptionHtml': (descriptionHtml ?? '').trim().isEmpty
            ? null
            : descriptionHtml,
        'sectionsJson': sectionsJson,
        'level': level,
        'priceCents': priceCents,
        'compareAtPriceCents': compareAtPriceCents,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid create course response');
    }
    return Course.fromJson(data);
  }

  Future<Course> update({
    required String id,
    String? title,
    String? description,
    String? level,
    int? priceCents,
    int? compareAtPriceCents,
    String? coverImageUrl,
    List<String>? imagesUrls,
    String? descriptionHtml,
    dynamic sectionsJson,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/courses/$id',
      data: {
        if (title != null) 'title': title,
        if (description != null)
          'description': (description.trim().isEmpty) ? null : description,
        if (level != null) 'level': level,
        if (priceCents != null) 'priceCents': priceCents,
        if (compareAtPriceCents != null)
          'compareAtPriceCents': compareAtPriceCents,
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
      throw Exception('Invalid update course response');
    }
    return Course.fromJson(data);
  }

  Future<void> delete({required String id}) async {
    await _dio.delete<void>('/courses/$id');
  }

  Future<void> adminReorder(List<Course> ordered) async {
    await _dio.patch<void>(
      '/courses/reorder',
      data: {
        'order': [
          for (var i = 0; i < ordered.length; i++)
            {'id': ordered[i].id, 'sortOrder': i},
        ],
      },
    );
  }
}
