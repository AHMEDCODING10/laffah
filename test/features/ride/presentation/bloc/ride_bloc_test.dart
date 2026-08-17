import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laffah/core/error/failures.dart';
import 'package:laffah/features/parcel/domain/entities/parcel_entity.dart';
import 'package:laffah/features/parcel/domain/repositories/parcel_repository.dart';
import 'package:laffah/features/parcel/domain/usecases/submit_parcel_order_usecase.dart';
import 'package:laffah/features/ride/domain/entities/ride_entity.dart';
import 'package:laffah/features/ride/domain/repositories/ride_repository.dart';
import 'package:laffah/features/ride/domain/usecases/cancel_ride_usecase.dart';
import 'package:laffah/features/ride/domain/usecases/get_trip_history_usecase.dart';
import 'package:laffah/features/ride/domain/usecases/request_ride_usecase.dart';
import 'package:laffah/features/ride/domain/usecases/rate_trip_use_case.dart';
import 'package:laffah/features/ride/presentation/bloc/ride_bloc.dart';

import 'package:laffah/core/services/captain_trip_alert_sound_service.dart';
import 'package:laffah/features/ride/domain/usecases/track_ride_usecase.dart';

class FakeRideRepository implements RideRepository {
  @override
  Future<Either<Failure, RideEntity>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String rideType,
    required double expectedPrice,
    List<Map<String, dynamic>>? stops,
    int? promoCodeId,
  }) async {
    return Right(RideEntity(
      id: 'trip-100',
      status: 'pending',
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      price: expectedPrice,
    ));
  }

  @override
  Future<Either<Failure, RideEntity>> trackRide(String rideId) async {
    return const Right(RideEntity(
      id: 'trip-100',
      status: 'accepted',
      pickupLocation: 'التحرير',
      dropoffLocation: 'حدة',
      price: 1500,
    ));
  }

  @override
  Future<Either<Failure, void>> cancelRide(String rideId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> rateTrip({
    required String tripId,
    required double rating,
    String? review,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory() async {
    return const Right([]);
  }

  @override
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId) {
    return Stream.value(const Right(RideEntity(
      id: 'trip-100',
      status: 'accepted',
      pickupLocation: 'التحرير',
      dropoffLocation: 'حدة',
      price: 1500,
    )));
  }
}

class FakeParcelRepo implements ParcelRepository {
  @override
  Future<Either<Failure, ParcelEntity>> submitParcelOrder({
    required String senderName,
    required String senderPhone,
    required String receiverName,
    required String receiverPhone,
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String? dropoffAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String parcelType,
    required String size,
    required String notes,
    double? price,
  }) async {
    return Right(ParcelEntity(
      id: 'parcel-1',
      senderName: senderName,
      senderPhone: senderPhone,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      pickupAddress: pickupAddress ?? '',
      dropoffAddress: dropoffAddress ?? '',
      parcelType: parcelType,
      size: size,
      notes: notes,
      status: 'pending',
      price: price ?? 0.0,
    ));
  }

  @override
  Future<Either<Failure, ParcelEntity>> trackParcel(String identifier) async {
    return const Right(ParcelEntity(
      id: '1',
      senderName: '',
      senderPhone: '',
      receiverName: '',
      receiverPhone: '',
      pickupAddress: '',
      dropoffAddress: '',
      parcelType: '',
      size: '',
      notes: '',
      status: 'pending',
      price: 0,
    ));
  }
}

void main() {
  late RideBloc bloc;
  late FakeRideRepository rideRepo;
  late FakeParcelRepo parcelRepo;

  setUp(() {
    rideRepo = FakeRideRepository();
    parcelRepo = FakeParcelRepo();
    bloc = RideBloc(
      requestRideUseCase: RequestRideUseCase(rideRepo),
      cancelRideUseCase: CancelRideUseCase(rideRepo),
      trackRideUseCase: TrackRideUseCase(rideRepo),
      submitParcelOrderUseCase: SubmitParcelOrderUseCase(parcelRepo),
      getTripHistoryUseCase: GetTripHistoryUseCase(rideRepo),
      rateTripUseCase: RateTripUseCase(rideRepo),
      alertSoundService: CaptainTripAlertSoundService(),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is RideInitial', () {
    expect(bloc.state, isA<RideInitial>());
  });

  test('CalculateSingleTripFare computes fare and emits RideOptionsLoaded', () async {
    final expectedStates = [
      isA<RideOptionsLoaded>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const CalculateSingleTripFare(
      pickup: 'ميدان التحرير، صنعاء',
      dropoff: 'شارع الزبيري، صنعاء',
    ));
  });

  test('ConfirmUnifiedBooking emits [RideLoading, RideBookingConfirmed] on valid ride request', () async {
    final expectedStates = [
      isA<RideLoading>(),
      isA<RideBookingConfirmed>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const ConfirmUnifiedBooking(
      pickup: 'التحرير',
      dropoff: 'حدة',
      pickupLatitude: 15.3694,
      pickupLongitude: 44.1910,
      dropoffLatitude: 15.3521,
      dropoffLongitude: 44.2014,
      fare: 1500,
      distance: 3.5,
      duration: 12,
    ));
  });
}
