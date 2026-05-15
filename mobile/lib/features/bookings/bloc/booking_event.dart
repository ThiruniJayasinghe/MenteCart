import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class BookingCheckoutRequested extends BookingEvent {
  final String paymentMethod;
  final String phone;
  final String address;
  final String city;

  const BookingCheckoutRequested(
    this.paymentMethod, {
    required this.phone,
    required this.address,
    required this.city,
  });

  @override
  List<Object?> get props => [paymentMethod, phone, address, city];
}

class BookingsFetchRequested extends BookingEvent {}

class BookingDetailRequested extends BookingEvent {
  final String id;
  const BookingDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class BookingCancelRequested extends BookingEvent {
  final String id;
  const BookingCancelRequested(this.id);
  @override
  List<Object?> get props => [id];
}