import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import 'package:careers/utils/network/base_dio_client.dart';
import '../models/location_model.dart';

class LocationApiService extends BaseDioClient {
  LocationApiService() : super();

  Future<List<StateModel>> fetchStates() async {
    final response = await dio.get(ApiConstants.states);
    final List data = response.data['data'];
    return data.map((e) => StateModel.fromJson(e)).toList();
  }

  Future<List<DistrictModel>> fetchDistricts(int stateId) async {
    final response = await dio.post(
      ApiConstants.districts,
      data: {'state_id': stateId},
    );
    final List data = response.data['data'];
    return data.map((e) => DistrictModel.fromJson(e)).toList();
  }
}