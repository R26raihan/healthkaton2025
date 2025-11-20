import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:video_player/video_player.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/domain/entities/prescription.dart';
import 'package:apps/presentation/providers/prescription_provider.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';

/// Medication Explanation Page - Penjelasan Obat
class MedicationExplanationPage extends StatefulWidget {
  static const String routeName = AppRoutes.medicationExplanation;
  
  const MedicationExplanationPage({super.key});
  
  @override
  State<MedicationExplanationPage> createState() => _MedicationExplanationPageState();
}

class _MedicationExplanationPageState extends State<MedicationExplanationPage> {
  bool _isDateFormatInitialized = false;
  Prescription? _selectedPrescription;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasAutoQueried = false;
  String _currentVideoPath = 'assets/images/asisten_animasi_hello.mp4';
  
  @override
  void initState() {
    super.initState();
    // Initialize date formatting untuk locale Indonesia
    _initializeDateFormatting();
    
    // Ambil argument prescription dari route jika ada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prescription = ModalRoute.of(context)?.settings.arguments;
      if (prescription != null && prescription is Prescription) {
        setState(() {
          _selectedPrescription = prescription;
        });
        // Initialize video dan auto-query RAG untuk detail obat
        _initializeVideo();
        _autoQueryRAG(prescription);
      }
      // Jika tidak ada argument, tidak load medications
      // Obat hanya ditampilkan dari rekam medis yang dipilih
    });
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
  
  Future<void> _switchToRekamMedisVideo() async {
    if (_currentVideoPath == 'assets/images/animasi_obat_obattan.mp4') return;
    
    setState(() {
      _currentVideoPath = 'assets/images/animasi_obat_obattan.mp4';
      _isVideoInitialized = false;
    });
    
    await _initializeVideo();
  }
  
  Future<void> _autoQueryRAG(Prescription prescription) async {
    if (_hasAutoQueried) return;
    
    final ragProvider = context.read<RagChatProvider>();
    
    // Clear previous messages
    ragProvider.clearChat();
    
    // Auto query RAG dengan informasi obat
    _hasAutoQueried = true;
    final query = 'jelaskan obat ${prescription.drugName} untuk saya. ${prescription.dosage != null ? "Dosis: ${prescription.dosage}. " : ""}${prescription.frequency != null ? "Frekuensi: ${prescription.frequency}. " : ""}${prescription.durationDays != null ? "Durasi: ${prescription.durationDays} hari. " : ""}';
    await ragProvider.sendMessage(query);
    
    // Switch video setelah dapat respon
    if (mounted && !ragProvider.isLoading) {
      await _switchToRekamMedisVideo();
    }
    
    // Listen untuk perubahan loading state
    ragProvider.addListener(_ragListener);
  }
  
  void _ragListener() {
    final ragProvider = context.read<RagChatProvider>();
    if (!ragProvider.isLoading && ragProvider.messages.isNotEmpty) {
      _switchToRekamMedisVideo();
      ragProvider.removeListener(_ragListener);
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    context.read<RagChatProvider>().removeListener(_ragListener);
    super.dispose();
  }
  
  Future<void> _initializeDateFormatting() async {
    if (!_isDateFormatInitialized) {
      await initializeDateFormatting('id_ID', null);
      setState(() {
        _isDateFormatInitialized = true;
      });
    }
  }
  
  void _backToList() {
    // Dispose video controller
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
    _hasAutoQueried = false;
    _currentVideoPath = 'assets/images/asisten_animasi_hello.mp4';
    
    // Clear RAG chat
    context.read<RagChatProvider>().clearChat();
    context.read<RagChatProvider>().removeListener(_ragListener);
    
    setState(() {
      _selectedPrescription = null;
    });
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
    
    // Jika ada prescription yang dipilih (dari argument atau klik dari list), tampilkan detail
    if (_selectedPrescription != null) {
      return _buildPrescriptionDetail(_selectedPrescription!);
    }
    
    // Jika tidak ada prescription yang dipilih, tampilkan list semua medications
    return _buildMedicationsList();
  }
  
  /// Build list semua medications
  Widget _buildMedicationsList() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjelasan Obat'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<PrescriptionProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<PrescriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.refresh();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Tampilkan empty state dengan instruksi untuk membuka rekam medis
          // Obat hanya ditampilkan dari rekam medis yang dipilih, bukan semua obat
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medication_outlined,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Pilih Obat dari Rekam Medis',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Untuk melihat penjelasan obat, silakan buka halaman Rekam Medis dan pilih obat yang ingin Anda ketahui lebih lanjut.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate ke rekam medis dengan argument untuk langsung ke timeline view (bukan AI view)
                    Navigator.of(context).pushNamed(
                      AppRoutes.medicalSummary,
                      arguments: {'showTimeline': true},
                    );
                  },
                  icon: const Icon(Icons.medical_information),
                  label: const Text('Buka Rekam Medis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// Build detail prescription
  Widget _buildPrescriptionDetail(Prescription prescription) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Obat'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backToList,
        ),
      ),
      body: Consumer<RagChatProvider>(
        builder: (context, ragProvider, child) {
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
                  child: _buildRAGChatView(context, ragProvider),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Build RAG Chat View (sama seperti di medical_summary_page)
  Widget _buildRAGChatView(BuildContext context, RagChatProvider ragProvider) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    
                    ...ragProvider.messages.map((message) => _buildChatBubble(message)),
                    
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
              'Menganalisis informasi obat...',
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
                color: AppTheme.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.medication_outlined,
                size: 48,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Menunggu penjelasan...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Assistant sedang menganalisis informasi obat',
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
