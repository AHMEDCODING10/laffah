import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laffah/core/error/failures.dart';
import 'package:laffah/core/services/pusher_service.dart';
import 'package:laffah/core/services/routing_service.dart';
import 'package:laffah/features/captain/domain/entities/captain_notification_entity.dart';
import 'package:laffah/features/captain/domain/entities/captain_status_entity.dart';
import 'package:laffah/features/captain/domain/entities/captain_trip_entity.dart';
import 'package:laffah/features/captain/domain/entities/captain_trip_request_entity.dart';
import 'package:laffah/features/captain/domain/entities/captain_wallet_entity.dart';
import 'package:laffah/features/captain/domain/repositories/captain_repository.dart';
import 'package:laffah/features/captain/domain/usecases/fetch_bonus_data_usecase.dart';
import 'package:laffah/features/captain/domain/usecases/request_payout_usecase.dart';
import 'package:laffah/features/captain/domain/usecases/respond_to_trip_usecase.dart';
import 'package:laffah/features/captain/domain/usecases/toggle_captain_status_usecase.dart';
import 'package:laffah/features/captain/domain/usecases/update_location_usecase.dart';
import 'package:laffah/features/captain/domain/usecases/update_trip_status_usecase.dart';
import 'package:laffah/features/captain/presentation/bloc/core/captain_bloc.dart';
import 'package:laffah/features/captain/presentation/bloc/core/captain_event.dart';
import 'package:laffah/features/captain/presentation/bloc/core/captain_state.dart';

class FakeCaptainRepo implements CaptainRepository {
  @override
  Future<Either<Failure, CaptainStatusEntity>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    return Right(CaptainStatusEntity(
      id: 'captain-1',
      isOnline: isOnline,
      currentLat: lat,
      currentLng: lng,
      statusMessage: isOnline ? 'متصل' : 'غير متصل',
    ));
  }

  @override
  Future<Either<Failure, void>> updateTripStatus({
    required String tripId,
    required String status,
  }) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> updateLocation({
    required String captainId,
    required double lat,
    required double lng,
    required double heading,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> requestPayout(
      double amount, String method, String accountNumber) async => const Right(null);

  @override
  Future<Either<Failure, Map<String, dynamic>>> fetchBonusData() async {
    return const Right({
      'completed_trips': 5,
      'target_trips': 10,
      'bonus_amount': 2500,
    });
  }

  @override
  Future<Either<Failure, List<CaptainTripEntity>>> getCaptainTrips({
    required int page,
    String statusFilter = 'الكل',
  }) async => const Right([]);

  @override
  Future<Either<Failure, CaptainWalletEntity>> getWalletDetails() async {
    return const Right(CaptainWalletEntity(
      availableBalance: 15000,
      todayEarnings: 4500,
      weeklyEarnings: 28000,
      completedTripsToday: 6,
      dailyTarget: 5000,
      previousWeekEarnings: 25000,
      recentTransactions: [],
    ));
  }

  @override
  Future<Either<Failure, List<CaptainNotificationEntity>>> getNotifications() async => const Right([]);

  @override
  Future<Either<Failure, List<CaptainTripRequestEntity>>> getNearbyRequests() async => const Right([]);

  @override
  Future<Either<Failure, Map<String, dynamic>>> uploadDocument(File file, String type) async => const Right({});
}

void main() {
  late CaptainBloc bloc;
  late FakeCaptainRepo repo;

  setUp(() {
    repo = FakeCaptainRepo();
    bloc = CaptainBloc(
      toggleCaptainStatusUseCase: ToggleCaptainStatusUseCase(repo),
      respondToTripUseCase: RespondToTripUseCase(repo),
      updateTripStatusUseCase: UpdateTripStatusUseCase(repo),
      requestPayoutUseCase: RequestPayoutUseCase(repo),
      fetchBonusDataUseCase: FetchBonusDataUseCase(repo),
      updateLocationUseCase: UpdateLocationUseCase(repo),
      routingService: RoutingService(),
      pusherService: PusherService(),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is CaptainOffline', () {
    expect(bloc.state, isA<CaptainOffline>());
  });

  test('FetchBonusData emits [CaptainLoading, CaptainBonusDataLoaded]', () async {
    final expectedStates = [
      isA<CaptainLoading>(),
      isA<CaptainBonusDataLoaded>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const FetchBonusData());
  });
}
