import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/rag_chat.dart';
import 'package:apps/domain/usecases/rag_chat/chat_usecase.dart';
import 'package:apps/core/services/tts_service.dart';
import 'package:uuid/uuid.dart';

/// Provider untuk state management RAG chat
class RagChatProvider extends ChangeNotifier {
  final ChatUsecase chatUsecase;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<RagChatMessage> _messages = [];
  bool _isChatOpen = false;
  bool _hasShownGreeting = false;
  String? _currentPageContext; // Context halaman saat ini untuk greeting
  List<String>? _lastSuggestions; // Suggestions dari response terakhir
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RagChatMessage> get messages => _messages;
  bool get isChatOpen => _isChatOpen;
  bool get hasShownGreeting => _hasShownGreeting;
  String? get currentPageContext => _currentPageContext;
  List<String>? get lastSuggestions => _lastSuggestions;
  
  RagChatProvider(this.chatUsecase);
  
  /// Set current page context untuk greeting message
  void setPageContext(String? context) {
    _currentPageContext = context;
    _hasShownGreeting = false; // Reset greeting flag saat pindah halaman
    notifyListeners();
  }
  
  /// Mark greeting as shown
  void markGreetingShown() {
    _hasShownGreeting = true;
    notifyListeners();
  }
  
  /// Get greeting message
  String getGreetingMessage() {
    return 'Hai! 👋 Aku bisa bantu jelaskan tentang kesehatan kamu. Ada yang ingin kamu tanyakan?';
  }
  
  /// Open chat
  void openChat() {
    _isChatOpen = true;
    notifyListeners();
  }
  
  /// Close chat
  void closeChat() {
    _isChatOpen = false;
    notifyListeners();
  }
  
  /// Send message
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;
    
    // Add user message
    final userMessage = RagChatMessage(
      id: const Uuid().v4(),
      message: message.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    
    // Send to RAG API
    final result = await chatUsecase(message.trim());
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        // Clear suggestions on error
        _lastSuggestions = null;
        // Add error message as bot response
        final errorMessage = RagChatMessage(
          id: const Uuid().v4(),
          message: 'Maaf, terjadi kesalahan: ${failure.message}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
        _isLoading = false;
        notifyListeners();
      },
      (response) {
        // Add bot response
        final botMessage = RagChatMessage(
          id: const Uuid().v4(),
          message: response.answer,
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(botMessage);
        _errorMessage = null;
        // Clear previous suggestions and set new ones
        _lastSuggestions = response.suggestions != null && response.suggestions!.isNotEmpty
            ? response.suggestions
            : null;
        _isLoading = false;
        notifyListeners();
        
        // TTS-kan response dari RAG
        Future.delayed(const Duration(milliseconds: 300), () {
          TtsService.speak(response.answer);
        });
      },
    );
  }
  
  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Add welcome message saat chat pertama kali dibuka
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMessage = RagChatMessage(
        id: const Uuid().v4(),
        message: 'Halo! Saya adalah asisten kesehatan AI. Saya bisa membantu menjawab pertanyaan tentang rekam medis, diagnosa, obat-obatan, dan kesehatan Anda. Silakan tanyakan apa yang ingin Anda ketahui! 😊',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    }
  }
}

