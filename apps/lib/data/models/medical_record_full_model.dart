import 'package:apps/domain/entities/medical_record_full.dart';
import 'package:apps/data/models/medical_record_model.dart';
import 'package:apps/data/models/diagnosis_model.dart';
import 'package:apps/data/models/prescription_model.dart';
import 'package:apps/data/models/lab_result_model.dart';

/// Medical Record Full Model untuk JSON serialization
class MedicalRecordFullModel extends MedicalRecordFull {
  const MedicalRecordFullModel({
    required super.recordId,
    required super.patientId,
    required super.visitDate,
    required super.visitType,
    super.diagnosisSummary,
    super.notes,
    super.doctorName,
    super.facilityName,
    required super.createdAt,
    super.diagnoses,
    super.prescriptions,
    super.labResults,
  });
  
  factory MedicalRecordFullModel.fromJson(Map<String, dynamic> json) {
    // Parse base medical record data
    final baseRecord = MedicalRecordModel.fromJson(json);
    
    // Parse diagnoses
    final diagnoses = (json['diagnoses'] as List<dynamic>? ?? [])
        .map((d) => DiagnosisModel.fromJson(d as Map<String, dynamic>))
        .toList();
    
    // Parse prescriptions
    final prescriptions = (json['prescriptions'] as List<dynamic>? ?? [])
        .map((p) => PrescriptionModel.fromJson(p as Map<String, dynamic>))
        .toList();
    
    // Parse lab results
    final labResults = (json['lab_results'] as List<dynamic>? ?? [])
        .map((l) => LabResultModel.fromJson(l as Map<String, dynamic>))
        .toList();
    
    return MedicalRecordFullModel(
      recordId: baseRecord.recordId,
      patientId: baseRecord.patientId,
      visitDate: baseRecord.visitDate,
      visitType: baseRecord.visitType,
      diagnosisSummary: baseRecord.diagnosisSummary,
      notes: baseRecord.notes,
      doctorName: baseRecord.doctorName,
      facilityName: baseRecord.facilityName,
      createdAt: baseRecord.createdAt,
      diagnoses: diagnoses,
      prescriptions: prescriptions,
      labResults: labResults,
    );
  }
  
  Map<String, dynamic> toJson() {
    final baseJson = MedicalRecordModel(
      recordId: recordId,
      patientId: patientId,
      visitDate: visitDate,
      visitType: visitType,
      diagnosisSummary: diagnosisSummary,
      notes: notes,
      doctorName: doctorName,
      facilityName: facilityName,
      createdAt: createdAt,
    ).toJson();
    
    baseJson['diagnoses'] = diagnoses
        .map((d) => (d is DiagnosisModel ? d : DiagnosisModel(
          diagnosisId: d.diagnosisId,
          recordId: d.recordId,
          icdCode: d.icdCode,
          diagnosisName: d.diagnosisName,
          primaryFlag: d.primaryFlag,
          createdAt: d.createdAt,
        )).toJson())
        .toList();
    
    baseJson['prescriptions'] = prescriptions
        .map((p) => (p is PrescriptionModel ? p : PrescriptionModel(
          prescriptionId: p.prescriptionId,
          recordId: p.recordId,
          drugName: p.drugName,
          drugCode: p.drugCode,
          dosage: p.dosage,
          frequency: p.frequency,
          durationDays: p.durationDays,
          notes: p.notes,
          createdAt: p.createdAt,
        )).toJson())
        .toList();
    
    baseJson['lab_results'] = labResults
        .map((l) => (l is LabResultModel ? l : LabResultModel(
          labId: l.labId,
          recordId: l.recordId,
          testName: l.testName,
          resultValue: l.resultValue,
          resultUnit: l.resultUnit,
          normalRange: l.normalRange,
          interpretation: l.interpretation,
          attachmentUrl: l.attachmentUrl,
          createdAt: l.createdAt,
        )).toJson())
        .toList();
    
    return baseJson;
  }
}

