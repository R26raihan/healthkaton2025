import 'package:apps/core/errors/failures.dart';
import 'package:apps/data/datasources/remote/rag_chat_remote_datasource.dart';
import 'package:apps/domain/entities/rag_chat.dart';
import 'package:apps/domain/repositories/rag_chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Implementation dari RagChatRepository
class RagChatRepositoryImpl implements RagChatRepository {
  final RagChatRemoteDataSource remoteDataSource;
  
  RagChatRepositoryImpl({
    required this.remoteDataSource,
  });
  
  @override
  Future<Either<Failure, RagChatResponse>> chat(String query) async {
    try {
      final response = await remoteDataSource.chat(query);
      return Right(response);
    } on ServerFailure catch (e) {
      return Left(e);
    } on NetworkFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}

