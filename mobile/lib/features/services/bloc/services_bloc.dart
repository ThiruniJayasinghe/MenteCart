import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../data/service_repository.dart';
import 'services_event.dart';
import 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServiceRepository _repo;

  ServicesBloc(this._repo) : super(ServicesInitial()) {
    on<ServicesFetchRequested>(_onFetch);
    on<ServiceDetailRequested>(_onDetail);
  }

  Future<void> _onFetch(ServicesFetchRequested event, Emitter<ServicesState> emit) async {
    emit(ServicesLoading());
    try {
      final data = await _repo.getServices(category: event.category, search: event.search);
      emit(ServicesLoaded(
        services: data['services'] as List,
        hasMore: data['hasMore'] as bool,
        total: data['total'] as int,
      ));
    } on AppFailure catch (f) {
      emit(ServicesFailure(f.message));
    } catch (_) {
      emit(const ServicesFailure('Failed to load services'));
    }
  }

  Future<void> _onDetail(ServiceDetailRequested event, Emitter<ServicesState> emit) async {
    emit(ServicesLoading());
    try {
      final service = await _repo.getService(event.id);
      emit(ServiceDetailLoaded(service));
    } on AppFailure catch (f) {
      emit(ServicesFailure(f.message));
    } catch (_) {
      emit(const ServicesFailure('Failed to load service'));
    }
  }
}