import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_notification_entity.dart';
import '../repositories/captain_repository.dart';

class GetCaptainNotificationsUseCase {
  final CaptainRepository repository;

  GetCaptainNotificationsUseCase(this.repository);

  Future<Either<Failure, List<CaptainNotificationEntity>>> call() async {
    return await repository.getNotifications();
  }
}
