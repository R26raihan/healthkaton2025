import 'package:apps/domain/entities/rag_chat.dart';

/// RAG Chat Response Model untuk JSON serialization
class RagChatResponseModel extends RagChatResponse {
  const RagChatResponseModel({
    required super.answer,
    required super.query,
    required super.success,
    super.processingTime,
    super.suggestions,
  });
  
  factory RagChatResponseModel.fromJson(Map<String, dynamic> json) {
    return RagChatResponseModel(
      answer: json['answer']?.toString() ?? '',
      query: json['query']?.toString() ?? '',
      success: json['success'] ?? false,
      processingTime: json['processing_time'] is num 
          ? (json['processing_time'] as num).toDouble()
          : null,
      suggestions: json['suggestions'] != null
          ? (json['suggestions'] as List<dynamic>)
              .map((s) => s.toString())
              .toList()
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'query': query,
      'success': success,
      'processing_time': processingTime,
      'suggestions': suggestions,
    };
  }
}

