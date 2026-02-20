import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/career_child_nodes_repository.dart';
import 'career_child_nodes_event.dart';
import 'career_child_nodes_state.dart';

class CareerChildNodesBloc extends Bloc<CareerChildNodesEvent, CareerChildNodesState> {
  final CareerChildNodesRepository _repository;

  CareerChildNodesBloc(this._repository) : super(CareerChildNodesInitial()) {
    on<FetchCareerChildNodes>(_onFetchCareerChildNodes);
  }

  Future<void> _onFetchCareerChildNodes(
      FetchCareerChildNodes event,
      Emitter<CareerChildNodesState> emit,
      ) async {
    emit(CareerChildNodesLoading());
    try {
      final nodes = await _repository.getChildNodes(event.parentId);
      emit(CareerChildNodesLoaded(nodes));
    } catch (e) {
      emit(CareerChildNodesError(e.toString()));
    }
  }
}