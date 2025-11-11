/// Lab Result entity
class LabResult {
  final String labId;
  final String recordId;
  final String testName;
  final String? resultValue;
  final String? resultUnit;
  final String? normalRange;
  final String? interpretation;
  final String? attachmentUrl;
  final DateTime createdAt;
  
  const LabResult({
    required this.labId,
    required this.recordId,
    required this.testName,
    this.resultValue,
    this.resultUnit,
    this.normalRange,
    this.interpretation,
    this.attachmentUrl,
    required this.createdAt,
  });
}

