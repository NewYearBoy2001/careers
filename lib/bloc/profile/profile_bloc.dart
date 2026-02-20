import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
      FetchProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      final profile = await _repository.getProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfile(
      UpdateProfile event,
      Emitter<ProfileState> emit,
      ) async {
    emit(ProfileLoading());
    try {
      final updatedProfile = await _repository.updateProfile(event.profileData);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}