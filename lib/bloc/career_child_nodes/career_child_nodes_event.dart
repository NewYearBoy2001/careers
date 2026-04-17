abstract class CareerChildNodesEvent {}

class FetchCareerChildNodes extends CareerChildNodesEvent {
  final String parentId;
  final String? keyword;
  FetchCareerChildNodes(this.parentId, {this.keyword});
}

// New: triggered by scroll
class FetchMoreCareerChildNodes extends CareerChildNodesEvent {}

class SearchCareerChildNodes extends CareerChildNodesEvent {
  final String keyword;
  SearchCareerChildNodes(this.keyword);
}