import 'package:careers/data/models/career_node_model.dart';

abstract class CareerSearchState {}

class CareerSearchInitial extends CareerSearchState {}
class CareerSearchLoading extends CareerSearchState {}

class CareerSearchLoaded extends CareerSearchState {
  final List<CareerNode> careers;
  final int totalCount;
  final int currentPage;
  final int lastPage;
  final bool isLoadingMore;   // true while fetching next page

  CareerSearchLoaded({
    required this.careers,
    required this.totalCount,
    required this.currentPage,
    required this.lastPage,
    this.isLoadingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  CareerSearchLoaded copyWith({
    List<CareerNode>? careers,
    int? totalCount,
    int? currentPage,
    int? lastPage,
    bool? isLoadingMore,
  }) {
    return CareerSearchLoaded(
      careers: careers ?? this.careers,
      totalCount: totalCount ?? this.totalCount,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CareerSearchError extends CareerSearchState {
  final String message;
  CareerSearchError(this.message);
}

// Keep these unchanged
class CareerDetailsLoading extends CareerSearchState {}
class CareerDetailsLoaded extends CareerSearchState {
  final CareerNodeDetails careerDetails;
  CareerDetailsLoaded(this.careerDetails);
}
class CareerDetailsError extends CareerSearchState {
  final String message;
  CareerDetailsError(this.message);
}