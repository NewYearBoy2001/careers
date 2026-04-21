abstract class SavedCollegesListEvent {}

class FetchSavedCollegesList extends SavedCollegesListEvent {}

class FetchNextSavedCollegesPage extends SavedCollegesListEvent {}

class RefreshSavedCollegesList extends SavedCollegesListEvent {}

class RemoveCollegeFromSavedList extends SavedCollegesListEvent {
  final String collegeId;
  RemoveCollegeFromSavedList(this.collegeId);
}