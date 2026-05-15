import '../../../core/network/api_client.dart';

class BookingRepository {
  final ApiClient _api;
  BookingRepository(this._api);

  Future<Map<String, dynamic>> checkout(
    String paymentMethod, {
    String phone = '0771234567',
    String address = 'N/A',
    String city = 'Colombo',
  }) =>
      _api.post('/bookings/checkout', data: {
        'paymentMethod': paymentMethod,
        'phone': phone,
        'address': address,
        'city': city,
      });

  Future<Map<String, dynamic>> getBookings({int page = 1, int limit = 20}) =>
      _api.get('/bookings', params: {'page': page, 'limit': limit});

  Future<Map<String, dynamic>> getBooking(String id) => _api.get('/bookings/$id');

  Future<Map<String, dynamic>> cancelBooking(String id) => _api.post('/bookings/$id/cancel');

  Future<void> confirmPayment(String bookingId, String paymentId) =>
      _api.post('/bookings/$bookingId/confirm-payment', data: {
        'paymentId': paymentId,
      });
}