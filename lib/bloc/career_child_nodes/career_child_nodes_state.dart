import '../../data/models/career_node_model.dart';

abstract class CareerChildNodesState {}

class CareerChildNodesInitial extends CareerChildNodesState {}

class CareerChildNodesLoading extends CareerChildNodesState {}

/// Emitted for every successful fetch (first page or appended pages)
class CareerChildNodesLoaded extends CareerChildNodesState {
  final List<CareerNode> nodes;
  final int currentPage;
  final int lastPage;
  final bool isFetchingMore;   // true while loading the next page
  final bool hasReachedMax;    // true when currentPage == lastPage

  CareerChildNodesLoaded({
    required this.nodes,
    required this.currentPage,
    required this.lastPage,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
  });

  CareerChildNodesLoaded copyWith({
    List<CareerNode>? nodes,
    int? currentPage,
    int? lastPage,
    bool? isFetchingMore,
    bool? hasReachedMax,
  }) {
    return CareerChildNodesLoaded(
      nodes: nodes ?? this.nodes,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class CareerChildNodesError extends CareerChildNodesState {
  final String message;
  CareerChildNodesError(this.message);
}