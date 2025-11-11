import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Service untuk Text-to-Speech menggunakan flutter_tts
class TtsService {
  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;
  
  /// Initialize TTS service
  static Future<void> initialize() async {
    if (_isInitialized && _flutterTts != null) {
      return;
    }
    
    _flutterTts = FlutterTts();
    
    // Set language ke Indonesian
    await _flutterTts!.setLanguage("id-ID");
    
    // Set speech rate (0.0 to 1.0)
    await _flutterTts!.setSpeechRate(0.5);
    
    // Set volume (0.0 to 1.0)
    await _flutterTts!.setVolume(1.0);
    
    // Set pitch (0.5 to 2.0)
    await _flutterTts!.setPitch(1.0);
    
    // Set completion handler
    _flutterTts!.setCompletionHandler(() {
      if (kDebugMode) {
        debugPrint('TTS completed');
      }
    });
    
    // Set error handler
    _flutterTts!.setErrorHandler((msg) {
      if (kDebugMode) {
        debugPrint('TTS error: $msg');
      }
    });
    
    _isInitialized = true;
    
    if (kDebugMode) {
      debugPrint('✅ TTS Service initialized');
    }
  }
  
  /// Speak text
  static Future<void> speak(String text) async {
    if (!_isInitialized || _flutterTts == null) {
      await initialize();
    }
    
    if (text.isEmpty) {
      return;
    }
    
    try {
      // Stop any ongoing speech
      await _flutterTts!.stop();
      
      // Remove emoji and special characters untuk better TTS
      final cleanText = _cleanText(text);
      
      // Speak
      await _flutterTts!.speak(cleanText);
      
      if (kDebugMode) {
        debugPrint('🔊 TTS speaking: $cleanText');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ TTS error: $e');
      }
    }
  }
  
  /// Stop speaking
  static Future<void> stop() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
    }
  }
  
  /// Check if TTS is speaking
  static Future<bool> isSpeaking() async {
    if (_flutterTts != null) {
      try {
        // FlutterTts tidak punya isSpeaking, jadi kita return false
        // Atau bisa di-track secara manual dengan flag
        return false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
  
  /// Clean text untuk TTS (remove emoji, replace dengan text)
  static String _cleanText(String text) {
    // Remove emoji
    String cleaned = text;
    
    // Replace common emoji dengan text
    cleaned = cleaned.replaceAll('👋', 'hai');
    cleaned = cleaned.replaceAll('😊', '');
    cleaned = cleaned.replaceAll('💊', 'obat');
    cleaned = cleaned.replaceAll('🏥', 'rumah sakit');
    cleaned = cleaned.replaceAll('📋', '');
    cleaned = cleaned.replaceAll('💉', 'suntik');
    cleaned = cleaned.replaceAll('🔬', 'lab');
    cleaned = cleaned.replaceAll('❤️', 'hati');
    cleaned = cleaned.replaceAll('🙏', '');
    cleaned = cleaned.replaceAll('⏱️', '');
    cleaned = cleaned.replaceAll('😔', '');
    
    // Remove multiple spaces
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    
    return cleaned.trim();
  }
  
  /// Dispose TTS
  static void dispose() {
    if (_flutterTts != null) {
      _flutterTts!.stop();
      _flutterTts = null;
      _isInitialized = false;
    }
  }
}

