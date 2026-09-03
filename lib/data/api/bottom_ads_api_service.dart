import 'package:dio/dio.dart';
import 'package:careers/constants/api_constants.dart';
import 'package:careers/utils/network/base_dio_client.dart'; // ⚠️ confirm this path

class BottomAdsApiService {
  late final Dio _dio;

  BottomAdsApiService() {
    _dio = BaseDioClient().dio;
  }

  Future<List<Map<String, dynamic>>> fetchBottomAds() async {
    final response = await _dio.get(ApiConstants.bottomAds);
    final data = response.data;
    if ((data['status'] == '1' || data['status_code'] == '200') &&
        data['data'] != null &&
        data['data']['list'] != null) {
      return List<Map<String, dynamic>>.from(data['data']['list']);
    }
    return [];
  }
}