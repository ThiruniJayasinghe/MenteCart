import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();
  @override List<Object?> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<dynamic> items;
  final double total;
  final int itemCount;
  const CartLoaded({required this.items, required this.total, required this.itemCount});
  @override List<Object?> get props => [items, total, itemCount];
}

class CartFailure extends CartState {
  final String message;
  const CartFailure(this.message);
  @override List<Object?> get props => [message];
}