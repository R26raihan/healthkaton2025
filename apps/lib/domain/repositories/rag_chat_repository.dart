import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/rag_chat.dart';
import 'package:dartz/dartz.dart';

/// Interface untuk RAG Chat Repository
abstract class RagChatRepository {
  Future<Either<Failure, RagChatResponse>> chat(String query);
}

