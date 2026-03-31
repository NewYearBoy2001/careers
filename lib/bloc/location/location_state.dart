import 'package:careers/data/models/location_model.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {}

class StatesLoading extends LocationState {}

class StatesLoaded extends LocationState {
  final List<StateModel> states;
  const StatesLoaded(this.states);
}

class DistrictsLoading extends LocationState {
  final List<StateModel> states; // keep states in memory
  const DistrictsLoading(this.states);
}

class DistrictsLoaded extends LocationState {
  final List<StateModel> states;
  final List<DistrictModel> districts;
  const DistrictsLoaded({required this.states, required this.districts});
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);
}