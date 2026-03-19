abstract class CareerGuidanceRegisterEvent {}

class SubmitCareerGuidanceRegistration extends CareerGuidanceRegisterEvent {
  final String bannerId;
  final String name;
  final String email;
  final String phone;

  SubmitCareerGuidanceRegistration({
    required this.bannerId,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class ResetCareerGuidanceRegistration extends CareerGuidanceRegisterEvent {}