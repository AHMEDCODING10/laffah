import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<GetSavedPlacesEvent>(_onGetSavedPlaces);
    on<AddSavedPlaceEvent>(_onAddSavedPlace);
  }

  Future<void> _onGetProfile(
      GetProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await repository.getProfile();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result =
        await repository.updateProfile(name: event.name, email: event.email);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onGetSavedPlaces(
      GetSavedPlacesEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await repository.getSavedPlaces();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (places) => emit(SavedPlacesLoaded(places)),
    );
  }

  Future<void> _onAddSavedPlace(
      AddSavedPlaceEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    final result = await repository.addSavedPlace(event.place);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (place) => emit(SavedPlaceAdded(place)),
    );
  }
}
