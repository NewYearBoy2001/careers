abstract class CareerChildNodesEvent {}

class FetchCareerChildNodes extends CareerChildNodesEvent {
  final String parentId;
  FetchCareerChildNodes(this.parentId);
}

// New: triggered by scroll
class FetchMoreCareerChildNodes extends CareerChildNodesEvent {}