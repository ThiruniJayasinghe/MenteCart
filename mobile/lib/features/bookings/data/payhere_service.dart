import 'dart:async';
import 'package:payhere_mobilesdk_flutter/payhere_mobilesdk_flutter.dart';

class PayHereService {
  static Future<String?> startPayment(Map<String, dynamic> checkoutData) async {
    final completer = Completer<String?>();

    final paymentObject = {
      "sandbox": true,
      "merchant_id": checkoutData['merchant_id']?.toString(),
      "merchant_secret": checkoutData['merchant_secret']?.toString(), // ← keep this, PayHere SDK needs it
      "notify_url": checkoutData['notify_url']?.toString(),
      "order_id": checkoutData['order_id']?.toString(),
      "items": checkoutData['items']?.toString(),
      "amount": checkoutData['amount']?.toString(),
      "currency": checkoutData['currency']?.toString() ?? 'LKR',
      "first_name": checkoutData['first_name']?.toString(),
      "last_name": checkoutData['last_name']?.toString(),
      "email": checkoutData['email']?.toString(),
      "phone": checkoutData['phone']?.toString(),
      "address": checkoutData['address']?.toString(),
      "city": checkoutData['city']?.toString(),
      "country": checkoutData['country']?.toString(),
    };

    PayHere.startPayment(
      paymentObject,
      (paymentId) => completer.complete(paymentId),
      (error) => completer.completeError(error),
      () => completer.complete(null),
    );

    return completer.future;
  }
}