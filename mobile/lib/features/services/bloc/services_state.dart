import 'package:equatable/equatable.dart';

abstract class ServicesState extends Equatable {
  const ServicesState();
  @override List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {}
class ServicesLoading extends ServicesState {}

class ServicesLoaded extends ServicesState {
  final List<dynamic> services;
  final bool hasMore;
  final int total;
  const ServicesLoaded({required this.services, required this.hasMore, required this.total});
  @override List<Object?> get props => [services, hasMore, total];
}

class ServiceDetailLoaded extends ServicesState {
  final Map<String, dynamic> service;
  const ServiceDetailLoaded(this.service);
  @override List<Object?> get props => [service];
}

class ServicesFailure extends ServicesState {
  final String message;
  const ServicesFailure(this.message);
  @override List<Object?> get props => [message];
}