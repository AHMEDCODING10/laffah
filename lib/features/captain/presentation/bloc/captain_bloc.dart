import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'captain_event.dart';
import 'captain_state.dart';
import '../../domain/usecases/toggle_captain_status_usecase.dart';

class CaptainBloc extends Bloc<CaptainEvent, CaptainState> {
  final ToggleCaptainStatusUseCase toggleCaptainStatusUseCase;
  Timer? _mockRequestTimer;

  Map<String, dynamic> _currentTripData = {
    'tripId': 'LF-88293',
    'passengerName': 'سارة العامري',
    'passengerPhone': '+967 777 123 456',
    'passengerRating': 4.9,
    'pickup': 'حي حدة، صنعاء',
    'dropoff': 'شارع الستين، أمام مستشفى آزال',
    'fare': 1800.0,
    'distance': '4.5 كم',
    'duration': '12 دقيقة',
  };

  CaptainBloc({required this.toggleCaptainStatusUseCase}) : super(const CaptainOffline()) {
    on<ToggleOnlineStatus>(_onToggleOnlineStatus);
    on<TriggerMockRequest>(_onTriggerMockRequest);
    on<AcceptTrip>(_onAcceptTrip);
    on<RejectTrip>(_onRejectTrip);
    on<UpdateTripProgressState>(_onUpdateTripProgressState);
  }

  Future<void> _onToggleOnlineStatus(ToggleOnlineStatus event, EmitFn emit) async {
    _mockRequestTimer?.cancel();
    
    // Call UseCase
    final result = await toggleCaptainStatusUseCase(
      isOnline: event.isOnline,
      lat: 15.3694, // Mock GPS
      lng: 44.1910,
    );

    result.fold(
      (failure) {
        // Fallback to offline on error, or you could emit an error state
        emit(const CaptainOffline());
      },
      (status) {
        if (status.isOnline) {
          emit(const CaptainOnline());
          _mockRequestTimer = Timer(const Duration(seconds: 3), () {
            add(const TriggerMockRequest());
          });
        } else {
          emit(const CaptainOffline());
        }
      },
    );
  }

  void _onTriggerMockRequest(TriggerMockRequest event, EmitFn emit) {
    if (state is CaptainOnline) {
      emit(IncomingTripRequest(
        tripId: _currentTripData['tripId'],
        passengerName: _currentTripData['passengerName'],
        passengerPhone: _currentTripData['passengerPhone'],
        passengerRating: _currentTripData['passengerRating'],
        pickup: _currentTripData['pickup'],
        dropoff: _currentTripData['dropoff'],
        fare: _currentTripData['fare'],
        distance: _currentTripData['distance'],
        duration: _currentTripData['duration'],
      ));
    }
  }

  void _onAcceptTrip(AcceptTrip event, EmitFn emit) {
    if (state is IncomingTripRequest) {
      emit(TripAccepted(
        tripId: _currentTripData['tripId'],
        passengerName: _currentTripData['passengerName'],
        passengerPhone: _currentTripData['passengerPhone'],
        passengerRating: _currentTripData['passengerRating'],
        pickup: _currentTripData['pickup'],
        dropoff: _currentTripData['dropoff'],
        fare: _currentTripData['fare'],
        distance: _currentTripData['distance'],
        duration: _currentTripData['duration'],
        tripProgress: 'accepted',
      ));
    }
  }

  void _onRejectTrip(RejectTrip event, EmitFn emit) {
    if (state is IncomingTripRequest) {
      emit(const CaptainOnline());
      
      _mockRequestTimer?.cancel();
      _mockRequestTimer = Timer(const Duration(seconds: 6), () {
        _currentTripData = {
          'tripId': 'LF-88290',
          'passengerName': 'أحمد منصور',
          'passengerPhone': '+967 771 999 888',
          'passengerRating': 4.8,
          'pickup': 'بوابة جامعة صنعاء الرئيسية',
          'dropoff': 'صنعاء مول، شارع حدة',
          'fare': 2500.0,
          'distance': '6.2 كم',
          'duration': '15 دقيقة',
        };
        add(const TriggerMockRequest());
      });
    }
  }

  void _onUpdateTripProgressState(UpdateTripProgressState event, EmitFn emit) {
    final currentState = state;
    
    if (event.nextStatus == 'arrived' && currentState is TripAccepted) {
      emit(currentState.copyWith(tripProgress: 'arrived'));
    } 
    else if (event.nextStatus == 'started' && currentState is TripAccepted) {
      emit(TripInProgress(
        tripId: currentState.tripId,
        passengerName: currentState.passengerName,
        passengerPhone: currentState.passengerPhone,
        passengerRating: currentState.passengerRating,
        pickup: currentState.pickup,
        dropoff: currentState.dropoff,
        fare: currentState.fare,
        remainingDistance: '3.4 كم',
        remainingDuration: '10 دقائق',
      ));
    } 
    else if (event.nextStatus == 'completed' && currentState is TripInProgress) {
      emit(TripCompleted(
        tripId: currentState.tripId,
        passengerName: currentState.passengerName,
        pickup: currentState.pickup,
        dropoff: currentState.dropoff,
        fare: currentState.fare,
        totalDistance: '8.4 كم',
        totalDuration: '24 دقيقة',
        paymentMethod: 'نقداً (Cash)',
      ));
    }
  }

  @override
  Future<void> close() {
    _mockRequestTimer?.cancel();
    return super.close();
  }
}

typedef EmitFn = Emitter<CaptainState>;
