import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class GetProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String? phone;
  final String? email;
  final String? vehicleType;
  final String? vehicleModel;
  final String? plateNumber;
  final String? vehicleColor;

  const UpdateProfileEvent({
    required this.name,
    this.phone,
    this.email,
    this.vehicleType,
    this.vehicleModel,
    this.plateNumber,
    this.vehicleColor,
  });

  @override
  List<Object> get props => [
        name,
        phone ?? '',
        email ?? '',
        vehicleType ?? '',
        vehicleModel ?? '',
        plateNumber ?? '',
        vehicleColor ?? ''
      ];
}

class GetSavedPlacesEvent extends ProfileEvent {}

class AddSavedPlaceEvent extends ProfileEvent {
  final SavedPlaceEntity place;

  const AddSavedPlaceEvent(this.place);

  @override
  List<Object> get props => [place];
}
