/// Health Calculation Entity
class HealthCalculation {
  final int calculationId;
  final int userId;
  final String calculationType;
  final Map<String, dynamic> result;
  final DateTime calculatedAt;

  const HealthCalculation({
    required this.calculationId,
    required this.userId,
    required this.calculationType,
    required this.result,
    required this.calculatedAt,
  });
}

