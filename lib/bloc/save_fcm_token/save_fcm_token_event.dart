abstract class SaveFcmTokenEvent {}
class SaveFcmTokenRequested extends SaveFcmTokenEvent {
  final String fcmKey;
  SaveFcmTokenRequested(this.fcmKey);
}