import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/local_products.dart';
import '../models/product_model.dart';

class ApiProvider {
  static Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('https://fakestoreapi.com/products'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final remoteProducts = data
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();

        return _mergeProducts(remoteProducts, localProducts);
      }
    } catch (_) {
      // Fall back to the local catalog below.
    }

    return localProducts;
  }

  static List<ProductModel> _mergeProducts(
    List<ProductModel> remoteProducts,
    List<ProductModel> extraProducts,
  ) {
    final mergedById = <int, ProductModel>{
      for (final product in remoteProducts) product.id: product,
      for (final product in extraProducts) product.id: product,
    };

    final mergedProducts = mergedById.values.toList();
    mergedProducts.sort((first, second) => first.id.compareTo(second.id));
    return mergedProducts;
  }
}
