import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/career_home_repository.dart';
import 'career_home_event.dart';
import 'career_home_state.dart';

class CareerHomeBloc extends Bloc<CareerHomeEvent, CareerHomeState> {
  final CareerHomeRepository _repository;

  CareerHomeBloc(this._repository) : super(CareerHomeInitial()) {
    on<FetchCareerNodes>(_onFetchCareerNodes);
  }

  Future<void> _onFetchCareerNodes(
      FetchCareerNodes event,
      Emitter<CareerHomeState> emit,
      ) async {
    emit(CareerHomeLoading());
    try {
      final nodes = await _repository.getCareerNodes();
      emit(CareerHomeLoaded(nodes));
    } catch (e) {
      emit(CareerHomeError(e.toString()));
    }
  }
}