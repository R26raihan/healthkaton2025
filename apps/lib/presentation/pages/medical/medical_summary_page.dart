import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/presentation/providers/medical_record_provider.dart';
import 'package:apps/domain/entities/medical_record_full.dart';
import 'package:apps/presentation/widgets/chatbot_wrapper.dart';

/// Medical Summary Page - Ringkasan Rekam Medis (Timeline riwayat kesehatan)
class MedicalSummaryPage extends StatefulWidget {
  static const String routeName = AppRoutes.medicalSummary;
  
  const MedicalSummaryPage({super.key});
  
  @override
  State<MedicalSummaryPage> createState() => _MedicalSummaryPageState();
}

class _MedicalSummaryPageState extends State<MedicalSummaryPage> {
  @override
  void initState() {
    super.initState();
    // Load medical records saat page pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalRecordProvider>().loadMedicalRecords();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Rekam Medis'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MedicalRecordProvider>().refresh();
            },
          ),
        ],
      ),
      floatingActionButton: const ChatbotFAB(pageContext: 'medical-summary'),
      body: Consumer<MedicalRecordProvider>(
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
        },
      ),
    );
  }

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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prescription.drugName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
            ),
          ],
        ],
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
}

