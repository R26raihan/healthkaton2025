import 'package:flutter/material.dart';
import 'package:apps/presentation/widgets/rag_chatbot_widget.dart';

/// Helper untuk mendapatkan chatbot widget sebagai floatingActionButton
/// Gunakan ini di Scaffold.floatingActionButton
class ChatbotFAB extends StatelessWidget {
  final String? pageContext;
  
  const ChatbotFAB({
    super.key,
    this.pageContext,
  });
  
  @override
  Widget build(BuildContext context) {
    return RagChatbotWidget(pageContext: pageContext);
  }
}

