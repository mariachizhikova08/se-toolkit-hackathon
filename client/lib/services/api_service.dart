import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/dessert.dart';

class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = AppConstants.baseUrl});

  Future<List<Dessert>> getDesserts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.dessertsEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Dessert.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load desserts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching desserts: $e');
      rethrow;
    }
  }

  Future<List<Dessert>> searchDesserts(String query) async {
    if (query.trim().isEmpty) return getDesserts();
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.searchEndpoint}?q=${Uri.encodeComponent(query)}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Dessert.fromJson(json)).toList();
      } else {
        // Fallback: filter locally
        final all = await getDesserts();
        final q = query.toLowerCase();
        return all.where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.description.toLowerCase().contains(q) ||
            d.ingredients.any((i) => i.toString().toLowerCase().contains(q))).toList();
      }
    } catch (e) {
      print('Error searching desserts: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required String customerName,
    required String phone,
    String? address,
    String? comment,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final body = {
        'customer_name': customerName,
        'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        'items': items,
      };
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.ordersEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getOrder(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.ordersEndpoint}$orderId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.ordersEndpoint}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error listing orders: $e');
      rethrow;
    }
  }
}
