import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:careers/data/repositories/location_repository.dart';
import 'location_event.dart';
import 'location_state.dart';
import 'package:careers/data/models/location_model.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationRepository _repository;

  LocationBloc(this._repository) : super(LocationInitial()) {
    on<FetchStates>(_onFetchStates);
    on<FetchDistricts>(_onFetchDistricts);
  }

  Future<void> _onFetchStates(FetchStates event, Emitter<LocationState> emit) async {
    emit(StatesLoading());
    try {
      final states = await _repository.fetchStates();
      emit(StatesLoaded(states));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }

  Future<void> _onFetchDistricts(FetchDistricts event, Emitter<LocationState> emit) async {
    // Preserve the loaded states while districts load
    final currentStates = state is StatesLoaded
        ? (state as StatesLoaded).states
        : state is DistrictsLoaded
        ? (state as DistrictsLoaded).states
        : <StateModel>[];

    emit(DistrictsLoading(currentStates));
    try {
      final districts = await _repository.fetchDistricts(event.stateId);
      emit(DistrictsLoaded(states: currentStates, districts: districts));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}