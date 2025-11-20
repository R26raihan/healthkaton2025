import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/prescription_provider.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';

/// Drug Interaction Page - Cek Interaksi / Duplikasi Obat
class DrugInteractionPage extends StatefulWidget {
  static const String routeName = AppRoutes.drugInteraction;
  
  const DrugInteractionPage({super.key});
  
  @override
  State<DrugInteractionPage> createState() => _DrugInteractionPageState();
}

class _DrugInteractionPageState extends State<DrugInteractionPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasAutoQueried = false;
  String _currentVideoPath = 'assets/images/asisten_animasi_hello.mp4';
  bool _isDateFormatInitialized = false;
  
  @override
  void initState() {
    super.initState();
    // Initialize date formatting untuk locale Indonesia
    _initializeDateFormatting();
    _initializeVideo();
    
    // Load prescriptions dan auto-query RAG
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prescriptionProvider = context.read<PrescriptionProvider>();
      
      // Load prescriptions jika belum ada
      if (prescriptionProvider.prescriptions.isEmpty && !prescriptionProvider.isLoading) {
        prescriptionProvider.loadMedications();
      }
      
      // Auto-query setelah prescriptions loaded
      _waitAndQueryRAG();
    });
  }
  
  Future<void> _initializeDateFormatting() async {
    if (!_isDateFormatInitialized) {
      await initializeDateFormatting('id_ID', null);
      setState(() {
        _isDateFormatInitialized = true;
      });
    }
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.asset(_currentVideoPath);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }
  
  Future<void> _switchToObatVideo() async {
    if (_currentVideoPath == 'assets/images/animasi_obat_obattan.mp4') return;
    
    setState(() {
      _currentVideoPath = 'assets/images/animasi_obat_obattan.mp4';
      _isVideoInitialized = false;
    });
    
    await _initializeVideo();
  }
  
  Future<void> _waitAndQueryRAG() async {
    if (_hasAutoQueried) return;
    
    final prescriptionProvider = context.read<PrescriptionProvider>();
    final ragProvider = context.read<RagChatProvider>();
    
    // Tunggu prescriptions selesai load
    if (prescriptionProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      // Retry
      _waitAndQueryRAG();
      return;
    }
    
    // Jika tidak ada prescriptions, tampilkan pesan
    if (prescriptionProvider.prescriptions.isEmpty) {
      return;
    }
    
    // Clear previous messages
    ragProvider.clearChat();
    
    // Build query dengan semua obat
    final prescriptions = prescriptionProvider.prescriptions;
    final drugList = prescriptions.map((p) {
      String info = p.drugName;
      if (p.dosage != null && p.dosage!.isNotEmpty) {
        info += ' (${p.dosage})';
      }
      if (p.frequency != null && p.frequency!.isNotEmpty) {
        info += ', ${p.frequency}';
      }
      return info;
    }).join(', ');
    
    // Auto query RAG untuk cek interaksi obat
    _hasAutoQueried = true;
    final query = 'Cek interaksi dan duplikasi obat berikut yang sedang atau pernah dikonsumsi pasien: $drugList. Analisis apakah ada potensi interaksi berbahaya, duplikasi fungsi, atau kondisi medis tertentu yang bisa dipicu oleh kombinasi obat-obat ini. Berikan peringatan jika ada risiko serius.';
    await ragProvider.sendMessage(query);
    
    // Switch video setelah dapat respon
    if (mounted && !ragProvider.isLoading) {
      await _switchToObatVideo();
    }
    
    // Listen untuk perubahan loading state
    ragProvider.addListener(_ragListener);
  }
  
  void _ragListener() {
    final ragProvider = context.read<RagChatProvider>();
    if (!ragProvider.isLoading && ragProvider.messages.isNotEmpty) {
      _switchToObatVideo();
      ragProvider.removeListener(_ragListener);
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    context.read<RagChatProvider>().removeListener(_ragListener);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Wait for date formatting to be initialized
    if (!_isDateFormatInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cek Interaksi Obat'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              _hasAutoQueried = false;
              context.read<PrescriptionProvider>().refresh();
              context.read<RagChatProvider>().clearChat();
              _waitAndQueryRAG();
            },
          ),
        ],
      ),
      body: Consumer2<PrescriptionProvider, RagChatProvider>(
        builder: (context, prescriptionProvider, ragProvider, child) {
          // Tampilkan layout vertikal: video di atas (70%), chat di bawah (30%)
          return Column(
            children: [
              // Bagian atas: Video animasi (Circle) - 70%
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                  child: Center(
                    child: _isVideoInitialized && _videoController != null
                        ? Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: AspectRatio(
                                aspectRatio: _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          )
                        : Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              
              // Bagian bawah: Chat RAG response - 30%
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.white,
                  child: _buildRAGChatView(context, ragProvider, prescriptionProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Build RAG Chat View
  Widget _buildRAGChatView(BuildContext context, RagChatProvider ragProvider, PrescriptionProvider prescriptionProvider) {
    // Jika masih loading prescriptions
    if (prescriptionProvider.isLoading) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat data obat...'),
            ],
          ),
        ),
      );
    }
    
    // Jika tidak ada prescriptions
    if (prescriptionProvider.prescriptions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medication_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Belum Ada Data Obat',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Data obat yang dikonsumsi akan muncul di sini',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card: Daftar obat yang dianalisis
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menganalisis ${prescriptionProvider.prescriptions.length} obat yang dikonsumsi',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (ragProvider.isLoading)
                      _buildLoadingMessage(),
                    
                    if (ragProvider.messages.isEmpty && !ragProvider.isLoading)
                      _buildEmptyState(context),
                    
                    // Hanya tampilkan messages dari AI (bukan dari user)
                    ...ragProvider.messages
                        .where((message) => !message.isUser)
                        .map((message) => _buildChatBubble(message)),
                    
                    if (ragProvider.errorMessage != null)
                      _buildErrorMessage(ragProvider.errorMessage!),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Menganalisis interaksi obat...',
              style: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
              color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Menunggu Analisis...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Assistant sedang menganalisis interaksi dan duplikasi obat',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatBubble(message) {
    final isUser = message.isUser;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primaryGreen.withOpacity(0.15)
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppTheme.primaryGreen.withOpacity(0.4)
                      : Colors.grey[300]!,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('HH:mm', 'id_ID').format(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),
              child: Icon(
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
  
  Widget _buildErrorMessage(String error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
