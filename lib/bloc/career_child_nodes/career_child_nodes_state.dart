import '../../data/models/career_node_model.dart';

abstract class CareerChildNodesState {}

class CareerChildNodesInitial extends CareerChildNodesState {}

class CareerChildNodesLoading extends CareerChildNodesState {}

/// Emitted for every successful fetch (first page or appended pages)
class CareerChildNodesLoaded extends CareerChildNodesState {
  final List<CareerNode> nodes;
  final int currentPage;
  final int lastPage;
  final bool isFetchingMore;
  final bool hasReachedMax;
  final String? activeKeyword;    // ADD THIS

  CareerChildNodesLoaded({
    required this.nodes,
    required this.currentPage,
    required this.lastPage,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
    this.activeKeyword,           // ADD THIS
  });

  CareerChildNodesLoaded copyWith({
    List<CareerNode>? nodes,
    int? currentPage,
    int? lastPage,
    bool? isFetchingMore,
    bool? hasReachedMax,
    String? activeKeyword,        // ADD THIS
    bool clearKeyword = false,    // ADD THIS: to explicitly set null
  }) {
    return CareerChildNodesLoaded(
      nodes: nodes ?? this.nodes,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      activeKeyword: clearKeyword ? null : (activeKeyword ?? this.activeKeyword), // ADD THIS
    );
  }
}

class CareerChildNodesError extends CareerChildNodesState {
  final String message;
  CareerChildNodesError(this.message);
}