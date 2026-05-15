import '../../../core/network/api_client.dart';

class ServiceRepository {
  final ApiClient _api;
  ServiceRepository(this._api);

  Future<Map<String, dynamic>> getServices({
    int page = 1,
    int limit = 20,
    String? category,
    String? search,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (category != null) params['category'] = category;
    if (search != null && search.isNotEmpty) params['search'] = search;
    return _api.get('/services', params: params);
  }

  Future<Map<String, dynamic>> getService(String id) async {
    return _api.get('/services/$id');
  }
}