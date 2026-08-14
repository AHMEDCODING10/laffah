import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/captain_repository.dart';

class UploadDocumentUseCase {
  final CaptainRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
      File file, String type) async {
    return await repository.uploadDocument(file, type);
  }
}
