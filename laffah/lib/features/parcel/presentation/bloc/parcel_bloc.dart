import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_parcel_order_usecase.dart';
import '../../domain/usecases/track_parcel_usecase.dart';
import 'parcel_event.dart';
import 'parcel_state.dart';

class ParcelBloc extends Bloc<ParcelEvent, ParcelState> {
  final SubmitParcelOrderUseCase submitParcelOrder;
  final TrackParcelUseCase trackParcelUseCase;

  ParcelBloc({
    required this.submitParcelOrder,
    required this.trackParcelUseCase,
  }) : super(ParcelInitial()) {
    on<SubmitParcelEvent>(_onSubmitParcel);
    on<TrackParcelEvent>(_onTrackParcel);
  }

  Future<void> _onSubmitParcel(
      SubmitParcelEvent event, Emitter<ParcelState> emit) async {
    emit(ParcelLoading());

    final result = await submitParcelOrder(
      senderName: event.senderName,
      senderPhone: event.senderPhone,
      receiverName: event.receiverName,
      receiverPhone: event.receiverPhone,
      pickupAddress: event.pickupAddress,
      pickupLatitude: event.pickupLatitude,
      pickupLongitude: event.pickupLongitude,
      dropoffAddress: event.dropoffAddress,
      dropoffLatitude: event.dropoffLatitude,
      dropoffLongitude: event.dropoffLongitude,
      parcelType: event.parcelType,
      size: event.size,
      notes: event.notes,
      price: event.price,
      distance: event.distance,
    );

    result.fold(
      (failure) => emit(ParcelError(failure.message)),
      (parcel) => emit(ParcelSubmittedSuccess(parcel)),
    );
  }

  Future<void> _onTrackParcel(
      TrackParcelEvent event, Emitter<ParcelState> emit) async {
    if (state is! ParcelTrackingLoaded) {
      emit(ParcelLoading());
    }

    final result = await trackParcelUseCase(event.identifier);

    result.fold(
      (failure) {
        if (state is! ParcelTrackingLoaded) {
          emit(ParcelError(failure.message));
        }
      },
      (parcel) => emit(ParcelTrackingLoaded(parcel)),
    );
  }
}


