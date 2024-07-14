import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Product.dart';

class CalendarService {
  Future<Map<int, List<Product>>> fetchProducts(int userId, String? token) async {
    final Uri uri = Uri.parse('http://102.219.179.156:8082/products/getproductsbypatient/$userId');
    final Map<String, String> headers = {'Authorization': '$token'};

    final http.Client client = http.Client();
    try {
      final response = await client.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = List.from(json.decode(response.body));
        Map<int, List<Product>> groupedProducts = {};

        for (var productData in data) {
          Product product = Product.fromJson(productData);
          int cureId = product.idCure;

          groupedProducts[cureId] = groupedProducts[cureId] ?? [];
          groupedProducts[cureId]!.add(product);
        }

        return groupedProducts;
      } else {
        throw Exception('Failed to load products');
      }
    } finally {
      client.close();
    }
  }
}
