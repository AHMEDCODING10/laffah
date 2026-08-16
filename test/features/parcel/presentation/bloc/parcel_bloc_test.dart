import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laffah/core/error/failures.dart';
import 'package:laffah/features/parcel/domain/entities/parcel_entity.dart';
import 'package:laffah/features/parcel/domain/repositories/parcel_repository.dart';
import 'package:laffah/features/parcel/domain/usecases/submit_parcel_order_usecase.dart';
import 'package:laffah/features/parcel/domain/usecases/track_parcel_usecase.dart';
import 'package:laffah/features/parcel/presentation/bloc/parcel_bloc.dart';
import 'package:laffah/features/parcel/presentation/bloc/parcel_event.dart';
import 'package:laffah/features/parcel/presentation/bloc/parcel_state.dart';

class FakeParcelRepository implements ParcelRepository {
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
      id: '1',
      trackingCode: 'LF-123456',
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
    if (identifier == 'LF-NOTFOUND') {
      return const Left(ServerFailure('الطرد غير موجود'));
    }
    return Right(ParcelEntity(
      id: '1',
      trackingCode: identifier,
      senderName: 'المرسل',
      senderPhone: '+967770000000',
      receiverName: 'المستلم',
      receiverPhone: '+967771111111',
      pickupAddress: 'صنعاء - التحرير',
      dropoffAddress: 'صنعاء - حدة',
      parcelType: 'طرد سريع',
      size: 'متوسط',
      notes: '',
      status: 'in_transit',
      price: 1500,
    ));
  }
}

void main() {
  late ParcelBloc bloc;
  late FakeParcelRepository repository;

  setUp(() {
    repository = FakeParcelRepository();
    bloc = ParcelBloc(
      submitParcelOrder: SubmitParcelOrderUseCase(repository),
      trackParcelUseCase: TrackParcelUseCase(repository),
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('initial state is ParcelInitial', () {
    expect(bloc.state, isA<ParcelInitial>());
  });

  test('SubmitParcelEvent emits [ParcelLoading, ParcelSubmittedSuccess] on success', () async {
    final expectedStates = [
      isA<ParcelLoading>(),
      isA<ParcelSubmittedSuccess>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const SubmitParcelEvent(
      senderName: 'أحمد',
      senderPhone: '+967770000000',
      receiverName: 'علي',
      receiverPhone: '+967771111111',
      pickupAddress: 'التحرير',
      pickupLatitude: 15.3694,
      pickupLongitude: 44.1910,
      dropoffAddress: 'حدة',
      dropoffLatitude: 15.3521,
      dropoffLongitude: 44.2014,
      parcelType: 'مستندات',
      size: 'صغير',
      notes: '',
      price: 1200,
    ));
  });

  test('TrackParcelEvent emits [ParcelLoading, ParcelTrackingLoaded] on successful track', () async {
    final expectedStates = [
      isA<ParcelLoading>(),
      isA<ParcelTrackingLoaded>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const TrackParcelEvent(identifier: 'LF-123456'));
  });

  test('TrackParcelEvent emits [ParcelLoading, ParcelError] on not found', () async {
    final expectedStates = [
      isA<ParcelLoading>(),
      isA<ParcelError>(),
    ];

    expectLater(bloc.stream, emitsInOrder(expectedStates));

    bloc.add(const TrackParcelEvent(identifier: 'LF-NOTFOUND'));
  });
}
