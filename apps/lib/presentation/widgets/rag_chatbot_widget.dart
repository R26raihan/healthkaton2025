import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';
import 'package:apps/core/services/tts_service.dart';
import 'package:apps/core/theme/app_theme.dart';


class RagChatbotWidget extends StatefulWidget {
  final String? pageContext; // Context halaman untuk greeting message
  
  const RagChatbotWidget({
    super.key,
    this.pageContext,
  });
  
  @override
  State<RagChatbotWidget> createState() => _RagChatbotWidgetState();
}

class _RagChatbotWidgetState extends State<RagChatbotWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _hasAnimated = false;
  bool _hasSpoken = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Scale animation untuk pulse effect (lebih subtle dan smooth)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Initialize TTS
    TtsService.initialize();
    
    // Initialize video player
    _initializeVideo();
    
    _showGreetingIfNeeded();
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/images/video_rag1.mp4',
      );
      
      // Add listener untuk update state saat video siap
      _videoController!.addListener(() {
        if (_videoController!.value.isInitialized && mounted) {
          if (!_isVideoInitialized) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }
      });
      
      await _videoController!.initialize();
      
      // Set video to loop
      _videoController!.setLooping(true);
      
      // Play video
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = _videoController!.value.isInitialized;
        });
      }
      
      debugPrint('✅ Video initialized: ${_videoController!.value.isInitialized}, duration: ${_videoController!.value.duration}');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing video: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(RagChatbotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika pageContext berubah, reset dan show greeting baru
    if (oldWidget.pageContext != widget.pageContext) {
      _hasAnimated = false;
      _hasSpoken = false;
      _showGreetingIfNeeded();
    }
  }
  
  void _showGreetingIfNeeded() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RagChatProvider>();
      final currentContext = widget.pageContext;
      
      // Set page context
      if (provider.currentPageContext != currentContext) {
        provider.setPageContext(currentContext);
      }
      
      // Skip greeting card untuk halaman tertentu (dashboard dan medical-summary)
      final skipGreetingPages = ['dashboard', 'medical-summary'];
      final shouldSkipGreeting = currentContext != null && 
          skipGreetingPages.contains(currentContext);
      
      // Trigger animation dan TTS setelah delay kecil (hanya sekali per halaman)
      if (currentContext != null && mounted && !_hasAnimated) {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && widget.pageContext == currentContext && !_hasAnimated) {
            if (shouldSkipGreeting) {
              // Skip greeting card, langsung start pulse animation
              _startPulseAnimation();
            } else {
              // Show greeting card seperti biasa
              _triggerGreetingAnimation(provider);
            }
            _hasAnimated = true;
          }
        });
      }
    });
  }
  
  void _triggerGreetingAnimation(RagChatProvider provider) {
    // Show greeting dialog
    if (!_hasSpoken) {
      final greetingMessage = provider.getGreetingMessage();
      
      // Show dialog dengan text greeting
      _showGreetingCard(context, greetingMessage);
      
      // Mark as spoken untuk prevent multiple dialogs
      _hasSpoken = true;
    } else {
      // Jika sudah pernah show, langsung start animation saja
      _startPulseAnimation();
    }
  }
  
  void _showGreetingCard(BuildContext context, String greetingMessage) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _GreetingCardDialog(
        greetingMessage: greetingMessage,
        onTap: () {
          // Stop TTS jika sedang berbicara
          TtsService.stop();
          Navigator.pop(context);
          final provider = context.read<RagChatProvider>();
          provider.openChat();
          provider.addWelcomeMessage();
          _showChatDialog(context);
        },
        onDismiss: () {
          // Stop TTS jika user tutup dialog
          TtsService.stop();
        },
      ),
    ).then((_) {
      // Setelah dialog ditutup, start pulse animation
      if (mounted && _animationController.isAnimating == false) {
        _startPulseAnimation();
      }
    });
    // TTS akan dipanggil di initState dialog, jadi tidak perlu di sini
  }
  
  void _startPulseAnimation() {
    if (!mounted) return;
    
    // Simple repeat reverse animation (lebih smooth)
    _animationController.repeat(reverse: true);
    
    // Stop animation setelah beberapa detik (sekitar 3-4 detik)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
      }
    });
  }
  
  void _showChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChatDialog(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RagChatProvider>(
      builder: (context, provider, child) {
        // Animated Floating Action Button dengan pulse effect
        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animationController.isAnimating 
                  ? _scaleAnimation.value 
                  : 1.0,
              child: FloatingActionButton(
                onPressed: () {
                  // Stop TTS jika sedang berbicara
                  TtsService.stop();
                  // Stop animation
                  if (_animationController.isAnimating) {
                    _animationController.stop();
                    _animationController.reset();
                  }
                  // Jika greeting dialog masih open, tutup dulu
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  // Open chat
                  provider.openChat();
                  provider.addWelcomeMessage();
                  _showChatDialog(context);
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isVideoInitialized && 
                         _videoController != null && 
                         _videoController!.value.isInitialized
                      ? ClipOval(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Greeting Card Dialog
/// Menampilkan greeting message dan membacakannya dengan TTS
class _GreetingCardDialog extends StatefulWidget {
  final String greetingMessage;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  
  const _GreetingCardDialog({
    required this.greetingMessage,
    required this.onTap,
    required this.onDismiss,
  });
  
  @override
  State<_GreetingCardDialog> createState() => _GreetingCardDialogState();
}

class _GreetingCardDialogState extends State<_GreetingCardDialog> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize video player
    _initializeVideo();
    
    // TTS-kan text greeting setelah dialog muncul (text dari dialog)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          // TTS-kan text yang ada di dialog (greetingMessage)
          TtsService.speak(widget.greetingMessage);
        }
      });
    });
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/images/video_rag1.mp4',
      );
      
      // Add listener untuk update state saat video siap
      _videoController!.addListener(() {
        if (_videoController!.value.isInitialized && mounted) {
          if (!_isVideoInitialized) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }
      });
      
      await _videoController!.initialize();
      
      // Set video to loop
      _videoController!.setLooping(true);
      
      // Play video
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = _videoController!.value.isInitialized;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing video in greeting dialog: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    // Stop TTS saat dialog di-dispose
    TtsService.stop();
    _videoController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI Assistant Video
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _isVideoInitialized && 
                     _videoController != null && 
                     _videoController!.value.isInitialized
                  ? ClipOval(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : const SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            // Greeting Message (text yang akan di-TTS-kan)
            Text(
              widget.greetingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // Action Button
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Stop TTS
                      TtsService.stop();
                      widget.onDismiss();
                      Navigator.pop(context);
                    },
                    child: const Text('Nanti'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Stop TTS
                      TtsService.stop();
                      widget.onTap();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tanya'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat Dialog
class _ChatDialog extends StatefulWidget {
  const _ChatDialog();
  
  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/images/video_rag1.mp4',
      );
      
      // Add listener untuk update state saat video siap
      _videoController!.addListener(() {
        if (_videoController!.value.isInitialized && mounted) {
          if (!_isVideoInitialized) {
            setState(() {
              _isVideoInitialized = true;
            });
          }
        }
      });
      
      await _videoController!.initialize();
      
      // Set video to loop
      _videoController!.setLooping(true);
      
      // Play video
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = _videoController!.value.isInitialized;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing video in chat dialog: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _videoController?.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final safeAreaTop = mediaQuery.padding.top;
    final safeAreaBottom = mediaQuery.padding.bottom;
    
    return SafeArea(
      top: false,
      child: Container(
        height: screenHeight * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16 + safeAreaTop,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isVideoInitialized && 
                         _videoController != null && 
                         _videoController!.value.isInitialized
                      ? ClipOval(
                          child: AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                        )
                      : const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Asisten Kesehatan AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<RagChatProvider>().closeChat();
                  },
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: Consumer<RagChatProvider>(
              builder: (context, provider, child) {
                // Scroll to bottom when new message added
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                
                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Mulai percakapan dengan mengetik pesan...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isLastMessage = index == provider.messages.length - 1;
                    final showSuggestions = isLastMessage && 
                        !message.isUser && 
                        provider.lastSuggestions != null && 
                        provider.lastSuggestions!.isNotEmpty;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMessageBubble(message),
                        if (showSuggestions) 
                          _buildSuggestions(context, provider.lastSuggestions!),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          // Loading indicator
          Consumer<RagChatProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Mengetik...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + safeAreaBottom,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        _sendMessage(context, value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<RagChatProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      onPressed: provider.isLoading
                          ? null
                          : () {
                              if (_messageController.text.trim().isNotEmpty) {
                                _sendMessage(context, _messageController.text);
                              }
                            },
                      icon: const Icon(Icons.send),
                      color: AppTheme.primaryGreen,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
  
  Widget _buildMessageBubble(message) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _isVideoInitialized && 
                     _videoController != null && 
                     _videoController!.value.isInitialized
                  ? ClipOval(
                      child: AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppTheme.primaryGreen 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: isUser ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  void _sendMessage(BuildContext context, String message) {
    final provider = context.read<RagChatProvider>();
    _messageController.clear();
    provider.sendMessage(message);
  }
  
  Widget _buildSuggestions(BuildContext context, List<String> suggestions) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pertanyaan yang mungkin kamu tanyakan:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return InkWell(
                onTap: () {
                  _sendMessage(context, suggestion);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.1),
                        AppTheme.primaryPurple.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

