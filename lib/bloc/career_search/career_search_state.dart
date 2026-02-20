import 'package:careers/data/models/career_node_model.dart';

abstract class CareerSearchState {}

class CareerSearchInitial extends CareerSearchState {}

class CareerSearchLoading extends CareerSearchState {}

class CareerSearchLoaded extends CareerSearchState {
  final List<CareerNode> careers;
  final int totalCount;

  CareerSearchLoaded({
    required this.careers,
    required this.totalCount,
  });
}

class CareerSearchError extends CareerSearchState {
  final String message;

  CareerSearchError(this.message);
}

class CareerDetailsLoading extends CareerSearchState {}

class CareerDetailsLoaded extends CareerSearchState {
  final CareerNodeDetails careerDetails;

  CareerDetailsLoaded(this.careerDetails);
}

class CareerDetailsError extends CareerSearchState {
  final String message;

  CareerDetailsError(this.message);
}