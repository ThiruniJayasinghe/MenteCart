import 'package:equatable/equatable.dart';

abstract class ServicesEvent extends Equatable {
  const ServicesEvent();
  @override List<Object?> get props => [];
}

class ServicesFetchRequested extends ServicesEvent {
  final String? category;
  final String? search;
  final bool refresh;
  const ServicesFetchRequested({this.category, this.search, this.refresh = false});
  @override List<Object?> get props => [category, search, refresh];
}

class ServiceDetailRequested extends ServicesEvent {
  final String id;
  const ServiceDetailRequested(this.id);
  @override List<Object?> get props => [id];
}