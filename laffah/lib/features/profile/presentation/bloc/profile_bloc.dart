import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileEntity? _cachedProfile;
  List<SavedPlaceEntity> _cachedSavedPlaces = [];

  ProfileEntity? get cachedProfile => _cachedProfile;
  List<SavedPlaceEntity> get cachedSavedPlaces => _cachedSavedPlaces;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    on<GetProfileEvent>(_onGetProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<GetSavedPlacesEvent>(_onGetSavedPlaces);
    on<AddSavedPlaceEvent>(_onAddSavedPlace);
  }

  Future<void> _onGetProfile(
      GetProfileEvent event, Emitter<ProfileState> emit) async {
    // Only show full loading if we have never loaded a profile before
    if (_cachedProfile == null) {
      emit(ProfileLoading());
    }

    final result = await repository.getProfile();
    result.fold(
      (failure) {
        // If we have a cached profile, keep displaying it rather than blanking out!
        if (_cachedProfile != null) {
          emit(ProfileLoaded(_cachedProfile!));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (profile) {
        _cachedProfile = profile;
        emit(ProfileLoaded(profile));
      },
    );
  }

  Future<void> _onUpdateProfile(
      UpdateProfileEvent event, Emitter<ProfileState> emit) async {
    // Optimistic local update so UI reflects immediately
    if (_cachedProfile != null) {
      _cachedProfile = _cachedProfile!.copyWith(
        name: event.name,
        phone: event.phone ?? _cachedProfile!.phone,
        email: event.email ?? _cachedProfile!.email,
      );
      emit(ProfileLoaded(_cachedProfile!));
    } else {
      emit(ProfileLoading());
    }

    final result = await repository.updateProfile(
        name: event.name, phone: event.phone, email: event.email);
    result.fold(
      (failure) {
        if (_cachedProfile != null) {
          emit(ProfileLoaded(_cachedProfile!));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (profile) {
        _cachedProfile = profile;
        emit(ProfileLoaded(profile));
      },
    );
  }

  Future<void> _onGetSavedPlaces(
      GetSavedPlacesEvent event, Emitter<ProfileState> emit) async {
    final result = await repository.getSavedPlaces();
    result.fold(
      (failure) => null, // Preserve state quietly without nuking active profile
      (places) {
        _cachedSavedPlaces = places;
        emit(SavedPlacesLoaded(places, profile: _cachedProfile));
      },
    );
  }

  Future<void> _onAddSavedPlace(
      AddSavedPlaceEvent event, Emitter<ProfileState> emit) async {
    final result = await repository.addSavedPlace(event.place);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (place) {
        _cachedSavedPlaces.add(place);
        emit(SavedPlaceAdded(place));
        emit(SavedPlacesLoaded(_cachedSavedPlaces, profile: _cachedProfile));
      },
    );
  }
}
