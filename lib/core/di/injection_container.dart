import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';
import '../network/websocket_client.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_otp_usecase.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/ride/domain/repositories/ride_repository.dart';
import '../../features/ride/domain/usecases/request_ride_usecase.dart';
import '../../features/ride/domain/usecases/cancel_ride_usecase.dart';
import '../../features/ride/data/datasources/ride_remote_data_source.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';

import '../../features/captain/domain/repositories/captain_repository.dart';
import '../../features/captain/domain/usecases/toggle_captain_status_usecase.dart';
import '../../features/captain/data/datasources/captain_remote_data_source.dart';
import '../../features/captain/data/repositories/captain_repository_impl.dart';
import '../../features/captain/presentation/bloc/captain_bloc.dart';

import '../../features/parcel/domain/repositories/parcel_repository.dart';
import '../../features/parcel/domain/usecases/submit_parcel_order_usecase.dart';
import '../../features/parcel/data/datasources/parcel_remote_data_source.dart';
import '../../features/parcel/data/repositories/parcel_repository_impl.dart';

import '../../features/passenger/domain/repositories/wallet_repository.dart';
import '../../features/passenger/domain/usecases/get_wallet_balance_usecase.dart';
import '../../features/passenger/data/datasources/wallet_remote_data_source.dart';
import '../../features/passenger/data/repositories/wallet_repository_impl.dart';

import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==========================
  // Core / Network / Storage
  // ==========================
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // Web-safe options for FlutterSecureStorage to prevent browser hanging
  sl.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      webOptions: WebOptions(dbName: 'laffah_secure_store', publicKey: 'laffah_app'),
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
  sl.registerLazySingleton(() => SendOtpUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));

  sl.registerFactory(
        () => AuthBloc(
      sendOtpUseCase: sl(),
      verifyOtpUseCase: sl(),
    ),
  );

  // ==========================
  // Ride Feature
  // ==========================
  sl.registerLazySingleton<RideRemoteDataSource>(
        () => RideRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<RideRepository>(
        () => RideRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => RequestRideUseCase(sl()));
  sl.registerLazySingleton(() => CancelRideUseCase(sl()));

  sl.registerFactory(
        () => RideBloc(
      requestRideUseCase: sl(),
      cancelRideUseCase: sl(),
      submitParcelOrderUseCase: sl(),
    ),
  );

  // ==========================
  // Captain Feature
  // ==========================
  sl.registerLazySingleton<CaptainRemoteDataSource>(
        () => CaptainRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<CaptainRepository>(
        () => CaptainRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => ToggleCaptainStatusUseCase(sl()));

  sl.registerFactory(
        () => CaptainBloc(
      toggleCaptainStatusUseCase: sl(),
    ),
  );

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
}