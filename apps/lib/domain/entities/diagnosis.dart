/// Diagnosis entity
class Diagnosis {
  final String diagnosisId;
  final String recordId;
  final String? icdCode;
  final String diagnosisName;
  final bool primaryFlag;
  final DateTime createdAt;
  
  const Diagnosis({
    required this.diagnosisId,
    required this.recordId,
    this.icdCode,
    required this.diagnosisName,
    required this.primaryFlag,
    required this.createdAt,
  });
}

