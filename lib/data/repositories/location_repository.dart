import '../api/location_api_service.dart';
import '../models/location_model.dart';

class LocationRepository {
  final LocationApiService _api;
  LocationRepository(this._api);

  Future<List<StateModel>> fetchStates() => _api.fetchStates();
  Future<List<DistrictModel>> fetchDistricts(int stateId) => _api.fetchDistricts(stateId);
}