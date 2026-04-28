import 'package:equatable/equatable.dart';

abstract class CollegeEvent extends Equatable {
  const CollegeEvent();

  @override
  List<Object?> get props => [];
}

class SearchColleges extends CollegeEvent {
  final String? keyword;
  final String? location;
  final int page;
  final int perPage;

  const SearchColleges({
    this.keyword,
    this.location,
    this.page = 1,
    this.perPage = 10,
  });

  @override
  List<Object?> get props => [keyword, location, page, perPage];
}

class FetchCollegeDetails extends CollegeEvent {
  final String collegeId;
  final String phone;

  const FetchCollegeDetails(this.collegeId, this.phone);

  @override
  List<Object?> get props => [collegeId, phone];
}

class ClearCollegeDetails extends CollegeEvent {
  const ClearCollegeDetails();
}