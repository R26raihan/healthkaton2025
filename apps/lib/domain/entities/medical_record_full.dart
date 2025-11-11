import 'package:apps/domain/entities/medical_record.dart';
import 'package:apps/domain/entities/diagnosis.dart';
import 'package:apps/domain/entities/prescription.dart';
import 'package:apps/domain/entities/lab_result.dart';

/// Medical Record Full entity dengan semua data terkait
class MedicalRecordFull extends MedicalRecord {
  final List<Diagnosis> diagnoses;
  final List<Prescription> prescriptions;
  final List<LabResult> labResults;
  
  const MedicalRecordFull({
    required super.recordId,
    required super.patientId,
    required super.visitDate,
    required super.visitType,
    super.diagnosisSummary,
    super.notes,
    super.doctorName,
    super.facilityName,
    required super.createdAt,
    this.diagnoses = const [],
    this.prescriptions = const [],
    this.labResults = const [],
  });
}

