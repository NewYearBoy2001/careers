abstract class LocationEvent {
  const LocationEvent();
}

class FetchStates extends LocationEvent {
  const FetchStates();
}

class FetchDistricts extends LocationEvent {
  final int stateId;
  const FetchDistricts(this.stateId);
}