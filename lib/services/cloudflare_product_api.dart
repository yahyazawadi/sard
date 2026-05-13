import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/admin_product_model.dart';

class CloudflareProductApi {
  final String baseUrl;

  CloudflareProductApi({
    this.baseUrl = 'https://sard-products-api.s12219814.workers.dev',
  });

  Future<List<AdminProductModel>> getProducts() async {
    final response = await http.get(
      _uri('/products'),
      headers: _headers,
    );

    final decoded = _decodeResponse(response);

    if (decoded is! List) {
      throw Exception('Invalid products response format');
    }

    return decoded
        .map(
          (item) => AdminProductModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<AdminProductModel> createProduct(AdminProductModel product) async {
    final response = await http.post(
      _uri('/products'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    final decoded = _decodeResponse(response);

    return AdminProductModel.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<AdminProductModel> updateProduct(AdminProductModel product) async {
    final response = await http.put(
      _uri('/products/${product.id}'),
      headers: _headers,
      body: jsonEncode(product.toJson()),
    );

    final decoded = _decodeResponse(response);

    return AdminProductModel.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<void> deleteProduct(String productId) async {
    final response = await http.delete(
      _uri('/products/$productId'),
      headers: _headers,
    );

    _decodeResponse(response);
  }

  Future<AdminProductModel> purchase({
    required String productId,
    required String variantId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      _uri('/purchase'),
      headers: _headers,
      body: jsonEncode({
        'productId': productId,
        'variantId': variantId,
        'quantity': quantity,
      }),
    );

    final decoded = _decodeResponse(response);

    return AdminProductModel.fromJson(Map<String, dynamic>.from(decoded as Map));
  }

  Future<String> uploadImageBytes({
    required List<int> bytes,
    required String filename,
    String folder = 'products',
    String? contentType,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      _uri('/images/upload').replace(queryParameters: {'folder': folder}),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = _decodeResponse(response);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid image upload response format');
    }

    final uploadedUrl = decoded['url'];
    if (uploadedUrl is! String || uploadedUrl.trim().isEmpty) {
      throw Exception('Image upload response did not include a valid url');
    }

    return uploadedUrl;
  }

  Uri _uri(String path) {
    final normalizedBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$normalizedBaseUrl$normalizedPath');
  }

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  dynamic _decodeResponse(http.Response response) {
    final hasBody = response.body.trim().isNotEmpty;
    final decoded = hasBody ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    String message = 'Request failed with status ${response.statusCode}';

    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      final responseMessage = decoded['message'];

      if (error is String && error.trim().isNotEmpty) {
        message = error;
      } else if (responseMessage is String && responseMessage.trim().isNotEmpty) {
        message = responseMessage;
      }
    } else if (response.body.trim().isNotEmpty) {
      message = response.body.trim();
    }

    throw Exception(message);
  }
}
