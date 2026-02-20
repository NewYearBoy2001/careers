import '../../data/models/career_node_home_model.dart';

abstract class CareerHomeState {}

class CareerHomeInitial extends CareerHomeState {}

class CareerHomeLoading extends CareerHomeState {}

class CareerHomeLoaded extends CareerHomeState {
  final List<CareerNodeHomeModel> nodes;

  CareerHomeLoaded(this.nodes);
}

class CareerHomeError extends CareerHomeState {
  final String message;

  CareerHomeError(this.message);
}