import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/rag_chat.dart';
import 'package:apps/domain/repositories/rag_chat_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case untuk RAG chat
class ChatUsecase {
  final RagChatRepository repository;
  
  ChatUsecase(this.repository);
  
  Future<Either<Failure, RagChatResponse>> call(String query) {
    return repository.chat(query);
  }
}

