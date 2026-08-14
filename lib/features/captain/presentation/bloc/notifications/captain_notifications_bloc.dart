import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_captain_notifications_usecase.dart';
import '../../../domain/usecases/get_captain_nearby_requests_usecase.dart';
import 'captain_notifications_event.dart';
import 'captain_notifications_state.dart';

class CaptainNotificationsBloc
    extends Bloc<CaptainNotificationsEvent, CaptainNotificationsState> {
  final GetCaptainNotificationsUseCase getNotifications;
  final GetCaptainNearbyRequestsUseCase getNearbyRequests;

  CaptainNotificationsBloc({
    required this.getNotifications,
    required this.getNearbyRequests,
  }) : super(CaptainNotificationsInitial()) {
    on<FetchNotificationsAndRequests>(_onFetchAll);
    on<RefreshNotificationsAndRequests>(_onRefreshAll);
  }

  Future<void> _onFetchAll(FetchNotificationsAndRequests event,
      Emitter<CaptainNotificationsState> emit) async {
    emit(CaptainNotificationsLoading());

    // Fetch in parallel
    final results = await Future.wait([
      getNotifications(),
      getNearbyRequests(),
    ]);

    final notificationsResult = results[0];
    final requestsResult = results[1];

    if (notificationsResult.isLeft() && requestsResult.isLeft()) {
      emit(const CaptainNotificationsError(
        message: 'حدث خطأ أثناء جلب التنبيهات والطلبات.',
      ));
      return;
    }

    final notifications = notificationsResult.fold((l) => [], (r) => r);
    final requests = requestsResult.fold((l) => [], (r) => r);

    emit(CaptainNotificationsLoaded(
      notifications: notifications.cast(),
      nearbyRequests: requests.cast(),
    ));
  }

  Future<void> _onRefreshAll(RefreshNotificationsAndRequests event,
      Emitter<CaptainNotificationsState> emit) async {
    // Just run fetch all again, the UI can show its own refresh indicator instead of replacing the state with Loading
    final results = await Future.wait([
      getNotifications(),
      getNearbyRequests(),
    ]);

    final notificationsResult = results[0];
    final requestsResult = results[1];

    if (notificationsResult.isLeft() && requestsResult.isLeft()) {
      // If refresh fails, keep current state or show snackbar (handled in UI)
      return;
    }

    final notifications = notificationsResult.fold((l) => [], (r) => r);
    final requests = requestsResult.fold((l) => [], (r) => r);

    emit(CaptainNotificationsLoaded(
      notifications: notifications.cast(),
      nearbyRequests: requests.cast(),
    ));
  }
}
