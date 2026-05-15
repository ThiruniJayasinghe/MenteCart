import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../data/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _repo;

  BookingBloc(this._repo) : super(BookingInitial()) {
    on<BookingCheckoutRequested>(_onCheckout);
    on<BookingsFetchRequested>(_onFetch);
    on<BookingDetailRequested>(_onDetail);
    on<BookingCancelRequested>(_onCancel);
    on<BookingPaymentConfirmed>(_onPaymentConfirmed);
  }

  Future<void> _onCheckout(BookingCheckoutRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final data = await _repo.checkout(
        event.paymentMethod,
        phone: event.phone,
        address: event.address,
        city: event.city,
      );
      emit(BookingCheckoutSuccess(
        booking: data['booking'] as Map<String, dynamic>,
        checkoutData: data['checkoutData'] as Map<String, dynamic>?,
      ));
    } on AppFailure catch (f) {
      emit(BookingFailure(f.message));
    } catch (e) {
      emit(const BookingFailure('Checkout failed'));
    }
  }

  Future<void> _onFetch(BookingsFetchRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final data = await _repo.getBookings();
      emit(BookingsLoaded(
        bookings: data['bookings'] as List? ?? [],
        hasMore: data['hasMore'] as bool? ?? false,
      ));
    } on AppFailure catch (f) {
      emit(BookingFailure(f.message));
    } catch (_) {
      emit(const BookingFailure('Failed to load bookings'));
    }
  }

  Future<void> _onDetail(BookingDetailRequested event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final booking = await _repo.getBooking(event.id);
      emit(BookingDetailLoaded(booking));
    } on AppFailure catch (f) {
      emit(BookingFailure(f.message));
    } catch (_) {
      emit(const BookingFailure('Failed to load booking'));
    }
  }

  Future<void> _onCancel(BookingCancelRequested event, Emitter<BookingState> emit) async {
    try {
      await _repo.cancelBooking(event.id);
      add(BookingsFetchRequested());
    } on AppFailure catch (f) {
      emit(BookingFailure(f.message));
    }
  }

  Future<void> _onPaymentConfirmed(BookingPaymentConfirmed event, Emitter<BookingState> emit) async {
    try {
      await _repo.confirmPayment(event.bookingId, event.paymentId);
      emit(BookingPaymentConfirmSuccess());
    } on AppFailure catch (f) {
      emit(BookingFailure(f.message));
    } catch (_) {
      emit(const BookingFailure('Failed to confirm payment'));
    }
  }
}