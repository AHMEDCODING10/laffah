import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/submit_parcel_order_usecase.dart';
import 'parcel_event.dart';
import 'parcel_state.dart';

class ParcelBloc extends Bloc<ParcelEvent, ParcelState> {
  final SubmitParcelOrderUseCase submitParcelOrder;

  ParcelBloc({required this.submitParcelOrder}) : super(ParcelInitial()) {
    on<SubmitParcelEvent>(_onSubmitParcel);
  }

  Future<void> _onSubmitParcel(SubmitParcelEvent event, Emitter<ParcelState> emit) async {
    emit(ParcelLoading());

    final result = await submitParcelOrder(
      senderName: event.senderName,
      senderPhone: event.senderPhone,
      receiverName: event.receiverName,
      receiverPhone: event.receiverPhone,
      parcelType: event.parcelType,
      size: event.size,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(ParcelError(failure.message)),
      (parcel) => emit(ParcelSubmittedSuccess(parcel)),
    );
  }
}
