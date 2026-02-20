abstract class CareerSearchEvent {}

class SearchCareersEvent extends CareerSearchEvent {
  final String keyword;

  SearchCareersEvent(this.keyword);
}

class FetchCareerDetailsEvent extends CareerSearchEvent {
  final String careerNodeId;

  FetchCareerDetailsEvent(this.careerNodeId);
}

class ClearSearchResultsEvent extends CareerSearchEvent {}