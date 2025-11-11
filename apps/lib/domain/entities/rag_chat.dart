/// RAG Chat Response entity
class RagChatResponse {
  final String answer;
  final String query;
  final bool success;
  final double? processingTime;
  final List<String>? suggestions;
  
  const RagChatResponse({
    required this.answer,
    required this.query,
    required this.success,
    this.processingTime,
    this.suggestions,
  });
}

/// RAG Chat Message entity (untuk chat history)
class RagChatMessage {
  final String id;
  final String message;
  final bool isUser;
  final DateTime timestamp;
  
  const RagChatMessage({
    required this.id,
    required this.message,
    required this.isUser,
    required this.timestamp,
  });
}

