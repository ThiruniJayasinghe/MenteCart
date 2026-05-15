import '../../../core/network/api_client.dart';

class CartRepository {
  final ApiClient _api;
  CartRepository(this._api);

  Future<Map<String, dynamic>> getCart() => _api.get('/cart');

  Future<Map<String, dynamic>> addItem({
    required String serviceId,
    required String date,
    required String time,
    required int quantity,
  }) => _api.post('/cart/items', data: {
    'serviceId': serviceId,
    'date': date,
    'time': time,
    'quantity': quantity,
  });

  Future<Map<String, dynamic>> updateItem(String itemId, Map<String, dynamic> data) =>
      _api.patch('/cart/items/$itemId', data: data);

  Future<void> removeItem(String itemId) => _api.delete('/cart/items/$itemId');
}