abstract class ProfileEvent {}

class FetchProfile extends ProfileEvent {}

class UpdateProfile extends ProfileEvent {
  final Map<String, dynamic> profileData;

  UpdateProfile(this.profileData);
}

class CreateGuestUser extends ProfileEvent {
  final Map<String, dynamic> profileData;
  CreateGuestUser(this.profileData);
}