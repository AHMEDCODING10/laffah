import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object> get props => [profile];
}

class SavedPlacesLoaded extends ProfileState {
  final List<SavedPlaceEntity> places;

  const SavedPlacesLoaded(this.places);

  @override
  List<Object> get props => [places];
}

class SavedPlaceAdded extends ProfileState {
  final SavedPlaceEntity place;

  const SavedPlaceAdded(this.place);

  @override
  List<Object> get props => [place];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object> get props => [message];
}
