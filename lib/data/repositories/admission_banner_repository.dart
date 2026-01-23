import 'package:careers/data/models/admission_banner.dart';
import 'package:careers/data/api/admission_banner_api.dart';

class AdmissionRepository {
  final AdmissionApi api;

  AdmissionRepository(this.api);

  Future<List<AdmissionBanner>> getBanners() {
    return api.fetchBanners();
  }
}
