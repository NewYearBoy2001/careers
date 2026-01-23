abstract class SignupEvent {}

class SignupSubmitted extends SignupEvent {
  final Map<String, dynamic> body;

  SignupSubmitted(this.body);
}
