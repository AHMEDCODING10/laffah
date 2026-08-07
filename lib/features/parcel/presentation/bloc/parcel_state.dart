import 'package:equatable/equatable.dart';
import '../../domain/entities/parcel_entity.dart';

abstract class ParcelState extends Equatable {
  const ParcelState();

  @override
  List<Object> get props => [];
}

class ParcelInitial extends ParcelState {}

class ParcelLoading extends ParcelState {}

class ParcelSubmittedSuccess extends ParcelState {
  final ParcelEntity parcel;

  const ParcelSubmittedSuccess(this.parcel);

  @override
  List<Object> get props => [parcel];
}

class ParcelError extends ParcelState {
  final String message;

  const ParcelError(this.message);

  @override
  List<Object> get props => [message];
}
