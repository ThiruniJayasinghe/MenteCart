import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override List<Object?> get props => [];
}

class CartFetchRequested extends CartEvent {}

class CartItemAdded extends CartEvent {
  final String serviceId;
  final String date;
  final String time;
  final int quantity;
  const CartItemAdded({required this.serviceId, required this.date, required this.time, required this.quantity});
  @override List<Object?> get props => [serviceId, date, time, quantity];
}

class CartItemRemoved extends CartEvent {
  final String itemId;
  const CartItemRemoved(this.itemId);
  @override List<Object?> get props => [itemId];
}

class CartItemUpdated extends CartEvent {
  final String itemId;
  final Map<String, dynamic> data;
  const CartItemUpdated({required this.itemId, required this.data});
  @override List<Object?> get props => [itemId, data];
}