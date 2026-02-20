abstract class ChangePasswordEvent {}

class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String currentPassword;
  final String newPassword;

  ChangePasswordSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });
}