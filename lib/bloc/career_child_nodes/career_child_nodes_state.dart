import '../../data/models/career_node_model.dart';

abstract class CareerChildNodesState {}

class CareerChildNodesInitial extends CareerChildNodesState {}

class CareerChildNodesLoading extends CareerChildNodesState {}

class CareerChildNodesLoaded extends CareerChildNodesState {
  final List<CareerNode> nodes;

  CareerChildNodesLoaded(this.nodes);
}

class CareerChildNodesError extends CareerChildNodesState {
  final String message;

  CareerChildNodesError(this.message);
}