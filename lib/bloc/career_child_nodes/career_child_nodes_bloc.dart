import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/career_child_nodes_repository.dart';
import 'career_child_nodes_event.dart';
import 'career_child_nodes_state.dart';

class CareerChildNodesBloc
    extends Bloc<CareerChildNodesEvent, CareerChildNodesState> {
  final CareerChildNodesRepository _repository;

  static const int _perPage = 10;

  // Remember which parent we're paginating for
  String _currentParentId = '';

  CareerChildNodesBloc(this._repository) : super(CareerChildNodesInitial()) {
    on<FetchCareerChildNodes>(_onFetch);
    on<FetchMoreCareerChildNodes>(_onFetchMore);
  }

  Future<void> _onFetch(
      FetchCareerChildNodes event,
      Emitter<CareerChildNodesState> emit,
      ) async {
    _currentParentId = event.parentId;
    emit(CareerChildNodesLoading());
    try {
      final result = await _repository.getChildNodes(
        event.parentId,
        page: 1,
        perPage: _perPage,
      );
      emit(CareerChildNodesLoaded(
        nodes: result.childNodes,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        hasReachedMax: result.currentPage >= result.lastPage,
      ));
    } catch (e) {
      emit(CareerChildNodesError(e.toString()));
    }
  }

  Future<void> _onFetchMore(
      FetchMoreCareerChildNodes event,
      Emitter<CareerChildNodesState> emit,
      ) async {
    final current = state;
    if (current is! CareerChildNodesLoaded) return;
    if (current.hasReachedMax || current.isFetchingMore) return;

    emit(current.copyWith(isFetchingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final result = await _repository.getChildNodes(
        _currentParentId,
        page: nextPage,
        perPage: _perPage,
      );
      emit(current.copyWith(
        nodes: [...current.nodes, ...result.childNodes],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        isFetchingMore: false,
        hasReachedMax: result.currentPage >= result.lastPage,
      ));
    } catch (e) {
      // Roll back the "loading more" spinner on error, keep existing nodes
      emit(current.copyWith(isFetchingMore: false));
    }
  }
}