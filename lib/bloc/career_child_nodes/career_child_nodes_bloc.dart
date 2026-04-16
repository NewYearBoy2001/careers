import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/career_child_nodes_repository.dart';
import 'career_child_nodes_event.dart';
import 'career_child_nodes_state.dart';

class CareerChildNodesBloc
    extends Bloc<CareerChildNodesEvent, CareerChildNodesState> {
  final CareerChildNodesRepository _repository;

  static const int _perPage = 10;

  String _currentParentId = '';
  String? _currentKeyword;       // ADD: track active keyword for pagination

  CareerChildNodesBloc(this._repository) : super(CareerChildNodesInitial()) {
    on<FetchCareerChildNodes>(_onFetch);
    on<FetchMoreCareerChildNodes>(_onFetchMore);
    on<SearchCareerChildNodes>(_onSearch);    // ADD
  }

  Future<void> _onFetch(
      FetchCareerChildNodes event,
      Emitter<CareerChildNodesState> emit,
      ) async {
    _currentParentId = event.parentId;
    _currentKeyword = event.keyword;          // ADD
    emit(CareerChildNodesLoading());
    try {
      final result = await _repository.getChildNodes(
        event.parentId,
        page: 1,
        perPage: _perPage,
        keyword: event.keyword,               // ADD
      );
      emit(CareerChildNodesLoaded(
        nodes: result.childNodes,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        hasReachedMax: result.currentPage >= result.lastPage,
        activeKeyword: event.keyword,         // ADD
      ));
    } catch (e) {
      emit(CareerChildNodesError(e.toString()));
    }
  }

  // ADD: entire handler
  Future<void> _onSearch(
      SearchCareerChildNodes event,
      Emitter<CareerChildNodesState> emit,
      ) async {
    _currentKeyword = event.keyword.trim().isEmpty ? null : event.keyword.trim();
    emit(CareerChildNodesLoading());
    try {
      final result = await _repository.getChildNodes(
        _currentParentId,
        page: 1,
        perPage: _perPage,
        keyword: _currentKeyword,
      );
      emit(CareerChildNodesLoaded(
        nodes: result.childNodes,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        hasReachedMax: result.currentPage >= result.lastPage,
        activeKeyword: _currentKeyword,
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
        keyword: _currentKeyword,             // ADD: preserve keyword in pagination
      );
      emit(current.copyWith(
        nodes: [...current.nodes, ...result.childNodes],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        isFetchingMore: false,
        hasReachedMax: result.currentPage >= result.lastPage,
      ));
    } catch (e) {
      emit(current.copyWith(isFetchingMore: false));
    }
  }
}