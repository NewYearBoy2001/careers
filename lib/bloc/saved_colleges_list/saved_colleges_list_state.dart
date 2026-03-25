import '../../data/models/college_model.dart';

abstract class SavedCollegesListState {}

class SavedCollegesListInitial extends SavedCollegesListState {}

class SavedCollegesListLoading extends SavedCollegesListState {}

class SavedCollegesListLoaded extends SavedCollegesListState {
  final List<CollegeModel> colleges;
  final int currentPage;
  final int lastPage;
  final bool isFetchingMore;

  SavedCollegesListLoaded({
    required this.colleges,
    required this.currentPage,
    required this.lastPage,
    this.isFetchingMore = false,
  });

  bool get hasMore => currentPage < lastPage;

  SavedCollegesListLoaded copyWith({
    List<CollegeModel>? colleges,
    int? currentPage,
    int? lastPage,
    bool? isFetchingMore,
  }) {
    return SavedCollegesListLoaded(
      colleges: colleges ?? this.colleges,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}

class SavedCollegesListEmpty extends SavedCollegesListState {
  final String message;
  SavedCollegesListEmpty(this.message);
}

class SavedCollegesListError extends SavedCollegesListState {
  final String message;
  SavedCollegesListError(this.message);
}