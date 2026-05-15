import 'package:equatable/equatable.dart';

abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}

class BookingCheckoutSuccess extends BookingState {
  final Map<String, dynamic> booking;
  final Map<String, dynamic>? checkoutData;
  const BookingCheckoutSuccess({required this.booking, this.checkoutData});
  @override
  List<Object?> get props => [booking, checkoutData];
}

class BookingsLoaded extends BookingState {
  final List<dynamic> bookings;
  final bool hasMore;
  const BookingsLoaded({required this.bookings, required this.hasMore});
  @override
  List<Object?> get props => [bookings, hasMore];
}

class BookingDetailLoaded extends BookingState {
  final Map<String, dynamic> booking;
  const BookingDetailLoaded(this.booking);
  @override
  List<Object?> get props => [booking];
}

class BookingFailure extends BookingState {
  final String message;
  const BookingFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class BookingPaymentConfirmSuccess extends BookingState {}