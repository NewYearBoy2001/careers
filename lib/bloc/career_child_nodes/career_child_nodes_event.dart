abstract class CareerChildNodesEvent {}

class FetchCareerChildNodes extends CareerChildNodesEvent {
  final String parentId;

  FetchCareerChildNodes(this.parentId);
}