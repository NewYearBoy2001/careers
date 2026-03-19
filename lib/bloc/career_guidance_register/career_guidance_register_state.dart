abstract class CareerGuidanceRegisterState {}

class CareerGuidanceRegisterInitial extends CareerGuidanceRegisterState {}

class CareerGuidanceRegisterLoading extends CareerGuidanceRegisterState {}

class CareerGuidanceRegisterSuccess extends CareerGuidanceRegisterState {
  final String registrationId;
  CareerGuidanceRegisterSuccess(this.registrationId);
}

class CareerGuidanceRegisterError extends CareerGuidanceRegisterState {
  final String message;
  CareerGuidanceRegisterError(this.message);
}