import 'package:careers/data/api/delete_account_api_service.dart';

class DeleteAccountRepository {
  final DeleteAccountApiService _apiService;

  DeleteAccountRepository(this._apiService);

  Future<String> deleteAccount({
    required String reason,
    required String confirmation,
  }) {
    return _apiService.deleteAccount(
      reason: reason,
      confirmation: confirmation,
    );
  }
}