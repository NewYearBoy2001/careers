import 'package:equatable/equatable.dart';
import '../../data/models/college_model.dart';

abstract class CollegeState extends Equatable {
  const CollegeState();

  @override
  List<Object?> get props => [];
}

class CollegeInitial extends CollegeState {}

class CollegeSearchLoading extends CollegeState {}

class CollegeSearchLoaded extends CollegeState {
  final List<CollegeModel> colleges;
  final int currentPage;
  final int lastPage;
  final int totalColleges;

  const CollegeSearchLoaded(
      this.colleges, {
        this.currentPage = 1,
        this.lastPage = 1,
        this.totalColleges = 0,
      });

  bool get hasMore => currentPage < lastPage;

  @override
  List<Object?> get props => [colleges, currentPage, lastPage, totalColleges];
}

class CollegeDetailsLoading extends CollegeState {
  final List<CollegeModel> colleges; // ✅ ADD: Preserve search results

  const CollegeDetailsLoading(this.colleges);

  @override
  List<Object?> get props => [colleges];
}

class CollegeDetailsLoaded extends CollegeState {
  final CollegeModel college;
  final List<CollegeModel> colleges; // ✅ ADD: Preserve search results

  const CollegeDetailsLoaded(this.college, this.colleges);

  @override
  List<Object?> get props => [college, colleges];
}

class CollegeError extends CollegeState {
  final String message;
  final List<CollegeModel>? colleges; // ✅ ADD: Preserve search results on error

  const CollegeError(this.message, {this.colleges});

  @override
  List<Object?> get props => [message, colleges];
}