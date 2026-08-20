import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../network/dio_client.dart';
import '../network/websocket_client.dart';
import '../network/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/locale/locale_bloc.dart';
import '../services/pusher_service.dart';
import '../services/echo_service.dart';
import '../services/routing_service.dart';
import '../services/captain_trip_alert_sound_service.dart';

import '../storage/secure_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_passenger_usecase.dart';
import '../../features/auth/domain/usecases/register_captain_usecase.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/ride/domain/repositories/ride_repository.dart';
import '../../features/ride/domain/usecases/request_ride_usecase.dart';
import '../../features/ride/domain/usecases/cancel_ride_usecase.dart';
import '../../features/ride/domain/usecases/track_ride_usecase.dart';
import '../../features/ride/domain/usecases/get_trip_history_usecase.dart';
import '../../features/ride/domain/usecases/rate_trip_use_case.dart';
import '../../features/ride/data/datasources/ride_remote_data_source.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';

import '../../features/captain/domain/repositories/captain_repository.dart';
import '../../features/captain/domain/usecases/toggle_captain_status_usecase.dart';
import '../../features/captain/domain/usecases/respond_to_trip_usecase.dart';
import '../../features/captain/domain/usecases/update_trip_status_usecase.dart';
import '../../features/captain/domain/usecases/request_payout_usecase.dart';

import '../../features/captain/domain/usecases/fetch_bonus_data_usecase.dart';
import '../../features/captain/domain/usecases/update_location_usecase.dart';
import '../../features/captain/domain/usecases/get_captain_trips_usecase.dart';
import '../../features/captain/data/datasources/captain_remote_data_source.dart';
import '../../features/captain/data/repositories/captain_repository_impl.dart';
import '../../features/captain/presentation/bloc/core/captain_bloc.dart';
import '../../features/captain/presentation/bloc/trips/captain_trips_bloc.dart';
import '../../features/captain/domain/usecases/get_captain_wallet_usecase.dart';
import '../../features/captain/domain/usecases/get_captain_notifications_usecase.dart';
import '../../features/captain/domain/usecases/get_captain_nearby_requests_usecase.dart';
import '../../features/captain/domain/usecases/upload_document_usecase.dart';
import '../../features/captain/presentation/bloc/wallet/captain_wallet_bloc.dart';
import '../../features/captain/presentation/bloc/notifications/captain_notifications_bloc.dart';


import '../../features/parcel/domain/repositories/parcel_repository.dart';
import '../../features/parcel/domain/usecases/submit_parcel_order_usecase.dart';
import '../../features/parcel/domain/usecases/track_parcel_usecase.dart';
import '../../features/parcel/data/datasources/parcel_remote_data_source.dart';
import '../../features/parcel/data/repositories/parcel_repository_impl.dart';


import '../../features/passenger/domain/repositories/wallet_repository.dart';
import '../../features/passenger/domain/usecases/get_wallet_balance_usecase.dart';
import '../../features/passenger/data/datasources/wallet_remote_data_source.dart';
import '../../features/passenger/data/repositories/wallet_repository_impl.dart';

import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

import '../../features/parcel/presentation/bloc/parcel_bloc.dart';
import '../../features/passenger/presentation/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================
  // Core / Network / Storage
  // ==========================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerFactory(() => LocaleBloc(sharedPreferences: sl()));

  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Web-safe options for FlutterSecureStorage to prevent browser hanging
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      webOptions:
          WebOptions(dbName: 'laffah_secure_store', publicKey: 'laffah_app'),
    ),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(sl()),
  );

  sl.registerLazySingleton<LaffahWebSocketClient>(
    () => LaffahWebSocketClient(
      baseWsUrl: 'wss://api.laffah.com',
      storage: sl(),
    ),
  );

  // ==========================
  // Parcel Feature (Registered early because RideBloc depends on SubmitParcelOrderUseCase)
  // ==========================
  sl.registerLazySingleton<ParcelRemoteDataSource>(
    () => ParcelRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ParcelRepository>(
    () => ParcelRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => SubmitParcelOrderUseCase(sl()));
  sl.registerLazySingleton(() => TrackParcelUseCase(sl()));


  // ==========================
  // Auth Feature
  // ==========================
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
    ),
  );
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterPassengerUseCase(sl()));
  sl.registerLazySingleton(() => RegisterCaptainUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerPassengerUseCase: sl(),
      registerCaptainUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // ==========================
  // Ride Feature
  // ==========================
  sl.registerLazySingleton<RideRemoteDataSource>(
    () => RideRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(
      remoteDataSource: sl(),
      webSocketClient: sl(),
    ),
  );
  sl.registerLazySingleton(() => RequestRideUseCase(sl()));
  sl.registerLazySingleton(() => CancelRideUseCase(sl()));
  sl.registerLazySingleton(() => TrackRideUseCase(sl()));
  sl.registerLazySingleton(() => GetTripHistoryUseCase(sl()));
  sl.registerLazySingleton(() => RateTripUseCase(sl()));

  sl.registerFactory<RideBloc>(
    () => RideBloc(
      requestRideUseCase: sl(),
      cancelRideUseCase: sl(),
      trackRideUseCase: sl(),
      submitParcelOrderUseCase: sl(),
      getTripHistoryUseCase: sl(),
      rateTripUseCase: sl(),
      alertSoundService: sl(),
      remoteDataSource: sl<RideRemoteDataSource>(), // ✅ Required for backend-driven fare estimation
    ),
  );

  // ==========================
  // Captain Feature
  // ==========================
  sl.registerLazySingleton<CaptainRemoteDataSource>(
    () => CaptainRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<CaptainRepository>(
    () => CaptainRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => RoutingService());
  sl.registerLazySingleton(() => PusherService());
  sl.registerLazySingleton(() => EchoService());
  sl.registerLazySingleton(() => ToggleCaptainStatusUseCase(sl()));
  sl.registerLazySingleton(() => RespondToTripUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTripStatusUseCase(sl()));
  sl.registerLazySingleton(() => RequestPayoutUseCase(sl()));
  sl.registerLazySingleton(() => FetchBonusDataUseCase(sl()));
  sl.registerLazySingleton(() => UpdateLocationUseCase(sl()));
  sl.registerLazySingleton(() => GetCaptainTripsUseCase(sl()));
  sl.registerLazySingleton(() => GetCaptainWalletUseCase(sl()));
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
  sl.registerLazySingleton(() => CaptainTripAlertSoundService());
  sl.registerFactory<CaptainBloc>(
    () => CaptainBloc(
      toggleCaptainStatusUseCase: sl(),
      respondToTripUseCase: sl(),
      updateTripStatusUseCase: sl(),
      requestPayoutUseCase: sl(),
      fetchBonusDataUseCase: sl(),
      updateLocationUseCase: sl(),
      getNearbyRequestsUseCase: sl(),
      routingService: sl(),
      pusherService: sl(),
      alertSoundService: sl(),
    ),
  );



  sl.registerFactory(() => CaptainTripsBloc(
        getCaptainTripsUseCase: sl(),
      ));

  sl.registerFactory(() => CaptainWalletBloc(
        getCaptainWalletUseCase: sl(),
        repository: sl(),
      ));

  sl.registerLazySingleton(() => GetCaptainNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => GetCaptainNearbyRequestsUseCase(sl()));

  sl.registerFactory(() => CaptainNotificationsBloc(
        getNotifications: sl(),
        getNearbyRequests: sl(),
      ));

  // ==========================
  // Wallet Feature
  // ==========================
  sl.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWalletBalanceUseCase(sl()));

  // ==========================
  // Profile Feature
  // ==========================
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // ==========================
  // Parcel Feature
  // ==========================
  sl.registerFactory(
    () => ParcelBloc(
      submitParcelOrder: sl(),
      trackParcelUseCase: sl(),
    ),
  );


  // ==========================
  // Passenger / Wallet Feature
  // ==========================
  sl.registerFactory(() => WalletBloc(repository: sl()));

  // ==========================
  // Profile Feature
  // ==========================
  sl.registerFactory(() => ProfileBloc(repository: sl()));
}
