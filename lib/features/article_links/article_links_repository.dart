import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/config.dart';

final articleLinksRepositoryProvider = Provider<ArticleLinksRepository>((ref) {
  return ArticleLinksRepository(ref.read(dioProvider));
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
      type: (json['type'] as String?) ?? 'product',
      id: json['id'] as String,
      title: (json['title'] as String?) ?? '',
      coverImageUrl: json['coverImageUrl'] as String?,
      priceCents: (json['priceCents'] as num?)?.toInt() ?? 0,
      compareAtPriceCents: (json['compareAtPriceCents'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toSetLinkJson({required int sortOrder}) {
    return {'toType': type, 'toId': id, 'sortOrder': sortOrder};
  }
}

class ArticleLinksRepository {
  ArticleLinksRepository(this._dio);

  final Dio _dio;

  Future<List<({String toType, String toId, int sortOrder})>> adminListRaw({
    required String fromType,
    required String fromId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/article-links/admin',
      queryParameters: {'fromType': fromType, 'fromId': fromId},
    );

    final data = res.data ?? const [];
    final out = <({String toType, String toId, int sortOrder})>[];
    for (final v in data) {
      if (v is! Map<String, dynamic>) continue;
      final toType = v['toType'];
      final toId = v['toId'];
      if (toType is! String || toId is! String) continue;
      out.add((
        toType: toType,
        toId: toId,
        sortOrder: (v['sortOrder'] as num?)?.toInt() ?? 0,
      ));
    }
    out.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return out;
  }

  Future<List<LinkedArticleSummary>> list({
    required String fromType,
    required String fromId,
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '/article-links',
      queryParameters: {
        'fromType': fromType,
        'fromId': fromId,
        if (AppConfig.tenantId.isNotEmpty) 'tenantId': AppConfig.tenantId,
      },
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(LinkedArticleSummary.fromJson)
        .toList(growable: false);
  }

  Future<void> setLinks({
    required String fromType,
    required String fromId,
    required List<LinkedArticleSummary> linked,
  }) async {
    await _dio.patch<void>(
      '/article-links/admin/$fromType/$fromId',
      data: {
        'links': [
          for (var i = 0; i < linked.length; i++)
            linked[i].toSetLinkJson(sortOrder: i),
        ],
      },
    );
  }
}
