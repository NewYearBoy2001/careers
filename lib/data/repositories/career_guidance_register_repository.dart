import 'package:careers/data/api/career_guidance_register_api_service.dart';

class CareerGuidanceRegisterRepository {
  final CareerGuidanceRegisterApiService _api;

  CareerGuidanceRegisterRepository(this._api);

  Future<String> register({
    required String bannerId,
    required String name,
    required String email,
    required String phone,
  }) =>
      _api.register(
        bannerId: bannerId,
        name: name,
        email: email,
        phone: phone,
      );
}