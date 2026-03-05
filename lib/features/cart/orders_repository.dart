import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import 'cart_controller.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.read(dioProvider));
});

class OrderSummary {
  OrderSummary({
    required this.id,
    required this.totalAmountCents,
    required this.status,
    required this.receiptUrl,
    required this.customerNote,
    required this.adminNote,
    required this.createdAt,
  });

  final String id;
  final int totalAmountCents;
  final String status;
  final String? receiptUrl;
  final String? customerNote;
  final String? adminNote;
  final DateTime createdAt;

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] as String,
      totalAmountCents: (json['totalAmountCents'] as num).toInt(),
      status: json['status'] as String,
      receiptUrl: json['receiptUrl'] as String?,
      customerNote: json['customerNote'] as String?,
      adminNote: json['adminNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OrderItem {
  OrderItem({
    required this.type,
    required this.productId,
    required this.courseId,
    required this.priceCents,
    required this.quantity,
  });

  final String type;
  final String? productId;
  final String? courseId;
  final int priceCents;
  final int quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      type: json['type'] as String,
      productId: json['productId'] as String?,
      courseId: json['courseId'] as String?,
      priceCents: (json['priceCents'] as num).toInt(),
      quantity: (json['quantity'] as num).toInt(),
    );
  }
}

class OrderDetail {
  OrderDetail({required this.order, required this.items});

  final OrderSummary order;
  final List<OrderItem> items;
}

class OrdersRepository {
  OrdersRepository(this._dio);

  final Dio _dio;

  Future<String> createOrder(
    List<CartItem> items, {
    required String customerNote,
    String? receiptUrl,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/orders',
      data: {
        'items': items
            .map(
              (i) => {
                'type': i.type.name,
                if (i.type == CartItemType.product) 'productId': i.id,
                if (i.type == CartItemType.course) 'courseId': i.id,
                'priceCents': i.priceCents,
                'quantity': i.quantity,
              },
            )
            .toList(growable: false),
        'customerNote': customerNote,
        if (receiptUrl != null) 'receiptUrl': receiptUrl,
      },
    );

    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid create order response');
    }
    final id = data['id'];
    if (id is! String || id.isEmpty) {
      throw Exception('Invalid order id');
    }
    return id;
  }

  Future<OrderSummary> adminUpdateOrder(
    String id, {
    String? status,
    String? adminNote,
  }) async {
    final res = await _dio.patch<Map<String, dynamic>>(
      '/orders/admin/$id',
      data: {
        if (status != null) 'status': status,
        if (adminNote != null) 'adminNote': adminNote,
      },
    );
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid admin update order response');
    }
    return OrderSummary.fromJson(data);
  }

  Future<void> adminDeleteOrder(String id) async {
    await _dio.delete<void>('/orders/admin/$id');
  }

  Future<List<OrderSummary>> adminListOrders() async {
    final res = await _dio.get<List<dynamic>>('/orders/admin');
    final data = res.data;
    if (data is! List) {
      throw Exception('Invalid admin orders response');
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(OrderSummary.fromJson)
        .toList(growable: false);
  }

  Future<OrderDetail> adminGetOrder(String id) async {
    final res = await _dio.get<Map<String, dynamic>>('/orders/admin/$id');
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid admin order detail response');
    }
    final orderRaw = data['order'];
    final itemsRaw = data['items'];
    if (orderRaw is! Map<String, dynamic> || itemsRaw is! List) {
      throw Exception('Invalid admin order detail payload');
    }
    final items = itemsRaw
        .whereType<Map<String, dynamic>>()
        .map(OrderItem.fromJson)
        .toList(growable: false);
    return OrderDetail(order: OrderSummary.fromJson(orderRaw), items: items);
  }
}
