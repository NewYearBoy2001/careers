abstract class ForgotPasswordEvent {}

class ForgotPasswordSubmitted extends ForgotPasswordEvent {
  final String email;
  ForgotPasswordSubmitted({required this.email});
}

class ResetPasswordSubmitted extends ForgotPasswordEvent {
  final String email;
  final String otp;
  final String password;

  ResetPasswordSubmitted({
    required this.email,
    required this.otp,
    required this.password,
  });
}