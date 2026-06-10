import '../api/notification_api_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final NotificationApiService _api;

  NotificationRepository(this._api);

  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    final data = await _api.getNotifications(page: page, perPage: perPage);
    final List list = data['data']['notifications'] as List;
    final int currentPage = data['data']['current_page'] ?? 1;
    final int lastPage = data['data']['last_page'] ?? 1;
    return {
      'notifications': list.map((e) => NotificationModel.fromJson(e)).toList(),
      'hasMore': currentPage < lastPage,
      'currentPage': currentPage,
    };
  }
}