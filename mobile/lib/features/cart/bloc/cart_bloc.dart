import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../data/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repo;

  CartBloc(this._repo) : super(CartInitial()) {
    on<CartFetchRequested>(_onFetch);
    on<CartItemAdded>(_onAdd);
    on<CartItemRemoved>(_onRemove);
    on<CartItemUpdated>(_onUpdate);
  }

  Future<void> _onFetch(CartFetchRequested event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final data = await _repo.getCart();
      emit(CartLoaded(
        items: data['items'] as List? ?? [],
        total: (data['total'] as num?)?.toDouble() ?? 0,
        itemCount: data['itemCount'] as int? ?? 0,
      ));
    } on AppFailure catch (f) {
      emit(CartFailure(f.message));
    } catch (_) {
      emit(const CartFailure('Failed to load cart'));
    }
  }

  Future<void> _onAdd(CartItemAdded event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final data = await _repo.addItem(
        serviceId: event.serviceId,
        date: event.date,
        time: event.time,
        quantity: event.quantity,
      );
      final items = data['items'] as List? ?? [];
      final total = items.fold<double>(0, (sum, i) => sum + ((i['price'] as num) * (i['quantity'] as int)));
      emit(CartLoaded(items: items, total: total, itemCount: items.length));
    } on AppFailure catch (f) {
      emit(CartFailure(f.message));
    } catch (_) {
      emit(const CartFailure('Failed to add item'));
    }
  }

  Future<void> _onRemove(CartItemRemoved event, Emitter<CartState> emit) async {
    try {
      await _repo.removeItem(event.itemId);
      add(CartFetchRequested());
    } on AppFailure catch (f) {
      emit(CartFailure(f.message));
    }
  }

  Future<void> _onUpdate(CartItemUpdated event, Emitter<CartState> emit) async {
    try {
      await _repo.updateItem(event.itemId, event.data);
      add(CartFetchRequested());
    } on AppFailure catch (f) {
      emit(CartFailure(f.message));
    }
  }
}