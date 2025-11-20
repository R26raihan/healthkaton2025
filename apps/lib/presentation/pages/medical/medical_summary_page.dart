import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/medical_record_provider.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';
import 'package:apps/domain/entities/medical_record_full.dart';

/// Medical Summary Page - Ringkasan Rekam Medis (Timeline riwayat kesehatan)
class MedicalSummaryPage extends StatefulWidget {
  static const String routeName = AppRoutes.medicalSummary;
  
  const MedicalSummaryPage({super.key});
  
  @override
  State<MedicalSummaryPage> createState() => _MedicalSummaryPageState();
}

class _MedicalSummaryPageState extends State<MedicalSummaryPage> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasAutoQueried = false;
  String _currentVideoPath = 'assets/images/asisten_animasi_hello.mp4';
  bool _showVideoChatView = true; // Toggle antara video+chat view dengan timeline view
  
  @override
  void initState() {
    super.initState();
    
    // Cek argument untuk menentukan view awal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments != null && arguments is Map && arguments['showTimeline'] == true) {
        // Jika ada argument showTimeline, langsung ke timeline view (bukan AI view)
        setState(() {
          _showVideoChatView = false;
        });
      } else {
        // Default: tampilkan AI view dan initialize video
        _initializeVideo();
        _autoQueryRAG();
      }
      
      // Load medical records
      context.read<MedicalRecordProvider>().loadMedicalRecords();
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
    if (_currentVideoPath == 'assets/images/asisten_rekam_medis.mp4') return;
    
    setState(() {
      _currentVideoPath = 'assets/images/asisten_rekam_medis.mp4';
      _isVideoInitialized = false;
    });
    
    await _initializeVideo();
  }
  
  Future<void> _autoQueryRAG() async {
    if (_hasAutoQueried) return;
    
    final ragProvider = context.read<RagChatProvider>();
    final medicalProvider = context.read<MedicalRecordProvider>();
    
    // Tunggu medical records selesai load
    if (medicalProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }
    
    // Clear previous messages
    ragProvider.clearChat();
    
    // Auto query RAG
    _hasAutoQueried = true;
    await ragProvider.sendMessage('cek hasil rekam medis saya');
    
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Rekam Medis'),
        automaticallyImplyLeading: false,
        actions: [
          if (_showVideoChatView)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Tutup',
              onPressed: () {
                setState(() {
                  _showVideoChatView = false;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.smart_toy),
              tooltip: 'Analisis dengan AI',
              onPressed: () {
                setState(() {
                  _showVideoChatView = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<MedicalRecordProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer2<MedicalRecordProvider, RagChatProvider>(
        builder: (context, medicalProvider, ragProvider, child) {
          // Toggle antara video+chat view dengan timeline view
          if (_showVideoChatView) {
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
                  child: _buildRAGChatView(context, ragProvider, medicalProvider),
                ),
              ),
            ],
          );
          } else {
            // Tampilkan timeline view rekam medis (view sebelumnya)
            return _buildTimelineView(context, medicalProvider);
          }
        },
      ),
    );
  }
  
  /// Build timeline view rekam medis (view sebelumnya)
  Widget _buildTimelineView(BuildContext context, MedicalRecordProvider provider) {
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

    if (provider.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_information_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada rekam medis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Data rekam medis Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showVideoChatView = true;
                });
              },
              icon: const Icon(Icons.smart_toy),
              label: const Text('Analisis dengan AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.records.length,
        itemBuilder: (context, index) {
          final record = provider.records[index];
          return InkWell(
            onTap: () async {
              // Simpan record_id saat user tap record
              provider.saveRecordId(record.recordId);
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              // Load detail record
              await provider.loadMedicalRecordById(record.recordId);
              // Close loading dialog
              if (context.mounted) {
                Navigator.pop(context);
              }
              // Tampilkan bottom sheet dengan detail
              if (context.mounted && provider.selectedRecord != null) {
                _showRecordDetailBottomSheet(context, provider.selectedRecord!);
              } else if (context.mounted && provider.errorMessageDetail != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${provider.errorMessageDetail}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: _buildTimelineItem(context, record, index),
          );
        },
      ),
    );
  }
  
  /// Build timeline item untuk rekam medis
  Widget _buildTimelineItem(BuildContext context, record, int index) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final visitDate = record.visitDate;
    
    // Determine visit type color
    Color visitTypeColor;
    IconData visitTypeIcon;
    switch (record.visitType.toLowerCase()) {
      case 'emergency':
        visitTypeColor = Colors.red;
        visitTypeIcon = Icons.emergency;
        break;
      case 'inpatient':
        visitTypeColor = Colors.orange;
        visitTypeIcon = Icons.hotel;
        break;
      case 'outpatient':
      default:
        visitTypeColor = Colors.blue;
        visitTypeIcon = Icons.local_hospital;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan tanggal dan visit type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: visitTypeColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(visitTypeIcon, color: visitTypeColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateFormat.format(visitDate),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        timeFormat.format(visitDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: visitTypeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.visitType.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Diagnosis Summary
                if (record.diagnosisSummary != null && record.diagnosisSummary!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Diagnosa',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.diagnosisSummary!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // Notes
                if (record.notes != null && record.notes!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.note, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            'Catatan',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        record.notes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                
                // Doctor & Facility
                Row(
                  children: [
                    if (record.doctorName != null && record.doctorName!.isNotEmpty) ...[
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.doctorName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (record.facilityName != null && record.facilityName!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          record.facilityName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  /// Show bottom sheet dengan detail rekam medis lengkap
  void _showRecordDetailBottomSheet(BuildContext context, MedicalRecordFull record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Detail Rekam Medis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _buildRecordDetailContent(context, record),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build content untuk detail rekam medis
  Widget _buildRecordDetailContent(BuildContext context, MedicalRecordFull record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic Info (sama seperti timeline item)
        _buildBasicInfo(context, record),
        const SizedBox(height: 24),
        
        // Diagnoses
        if (record.diagnoses.isNotEmpty) ...[
          _buildSectionHeader('Diagnosa', Icons.medical_services, Colors.blue),
          const SizedBox(height: 12),
          ...record.diagnoses.map((diagnosis) => _buildDiagnosisCard(diagnosis)),
          const SizedBox(height: 24),
        ],
        
        // Prescriptions
        if (record.prescriptions.isNotEmpty) ...[
          _buildSectionHeader('Resep Obat', Icons.medication, Colors.green),
          const SizedBox(height: 12),
          ...record.prescriptions.map((prescription) => _buildPrescriptionCard(prescription)),
          const SizedBox(height: 24),
        ],
        
        // Lab Results
        if (record.labResults.isNotEmpty) ...[
          _buildSectionHeader('Hasil Lab', Icons.science, Colors.orange),
          const SizedBox(height: 12),
          ...record.labResults.map((labResult) => _buildLabResultCard(labResult)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildBasicInfo(BuildContext context, MedicalRecordFull record) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final visitDate = record.visitDate;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(visitDate),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (record.diagnosisSummary != null && record.diagnosisSummary!.isNotEmpty)
            Text(
              record.diagnosisSummary!,
              style: const TextStyle(fontSize: 14),
            ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              record.notes!,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 8),
          if (record.doctorName != null && record.doctorName!.isNotEmpty)
            Text(
              'Dokter: ${record.doctorName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          if (record.facilityName != null && record.facilityName!.isNotEmpty)
            Text(
              'Fasilitas: ${record.facilityName}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(dynamic diagnosis) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
              child: Text(
                  diagnosis.diagnosisName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (diagnosis.primaryFlag)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'PRIMARY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (diagnosis.icdCode != null && diagnosis.icdCode!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'ICD: ${diagnosis.icdCode}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(dynamic prescription) {
    return InkWell(
      onTap: () {
        // Navigate ke halaman penjelasan obat dengan data prescription
        Navigator.of(context).pushNamed(
          AppRoutes.medicationExplanation,
          arguments: prescription,
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prescription.drugName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  if (prescription.dosage != null && prescription.dosage!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Dosis: ${prescription.dosage}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                  if (prescription.frequency != null && prescription.frequency!.isNotEmpty) ...[
                    Text('Frekuensi: ${prescription.frequency}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                  if (prescription.durationDays != null) ...[
                    Text('Durasi: ${prescription.durationDays} hari', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                  if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      prescription.notes!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabResultCard(dynamic labResult) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labResult.testName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (labResult.resultValue != null && labResult.resultValue!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Hasil: ${labResult.resultValue}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                if (labResult.resultUnit != null && labResult.resultUnit!.isNotEmpty)
                  Text(
                    ' ${labResult.resultUnit}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
              ],
            ),
          ],
          if (labResult.normalRange != null && labResult.normalRange!.isNotEmpty) ...[
            Text(
              'Normal: ${labResult.normalRange}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
          if (labResult.interpretation != null && labResult.interpretation!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Interpretasi: ${labResult.interpretation}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build RAG Chat View (Bagian bawah)
  Widget _buildRAGChatView(BuildContext context, RagChatProvider ragProvider, MedicalRecordProvider medicalProvider) {
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
              'Menganalisis rekam medis Anda...',
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
                Icons.medical_information_outlined,
                size: 48,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Menunggu analisis...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI Assistant sedang menganalisis rekam medis Anda',
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
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
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
                    DateFormat('HH:mm').format(message.timestamp),
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
                color: AppTheme.primaryGreen.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.primaryGreen,
                size: 20,
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