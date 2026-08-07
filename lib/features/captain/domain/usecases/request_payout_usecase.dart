import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/captain_repository.dart';

class RequestPayoutUseCase {
  final CaptainRepository repository;

  RequestPayoutUseCase(this.repository);

  Future<Either<Failure, void>> call(double amount, String method, String accountNumber) async {
    if (amount <= 0 || accountNumber.isEmpty) {
      return const Left(ValidationFailure('بيانات السحب غير صحيحة'));
    }
    return await repository.requestPayout(amount, method, accountNumber);
  }
}
