import 'package:careers/data/models/newgen_course_model.dart';

abstract class NewgenCoursesState {}

class NewgenCoursesInitial extends NewgenCoursesState {}

class NewgenCoursesLoading extends NewgenCoursesState {}

class NewgenCoursesLoaded extends NewgenCoursesState {
  final List<NewgenCourse> courses;
  final int currentPage;
  final int lastPage;
  final bool isFetchingMore;
  final bool hasReachedMax;

  NewgenCoursesLoaded({
    required this.courses,
    required this.currentPage,
    required this.lastPage,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
  });

  NewgenCoursesLoaded copyWith({
    List<NewgenCourse>? courses,
    int? currentPage,
    int? lastPage,
    bool? isFetchingMore,
    bool? hasReachedMax,
  }) {
    return NewgenCoursesLoaded(
      courses: courses ?? this.courses,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class NewgenCoursesError extends NewgenCoursesState {
  final String message;
  NewgenCoursesError(this.message);
}