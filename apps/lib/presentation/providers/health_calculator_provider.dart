import 'package:flutter/foundation.dart';
import 'package:apps/core/errors/failures.dart';
import 'package:apps/domain/entities/health_calculation.dart';
import 'package:apps/domain/entities/health_metric.dart';
import 'package:apps/domain/usecases/health_calculator/get_calculation_history_usecase.dart';
import 'package:apps/domain/usecases/health_calculator/save_calculation_usecase.dart';
import 'package:apps/domain/usecases/health_calculator/get_metrics_usecase.dart';

/// Provider untuk Health Calculator
class HealthCalculatorProvider extends ChangeNotifier {
  final GetCalculationHistoryUseCase getCalculationHistoryUseCase;
  final SaveCalculationUseCase saveCalculationUseCase;
  final GetMetricsUseCase getMetricsUseCase;
  
  HealthCalculatorProvider(
    this.getCalculationHistoryUseCase,
    this.saveCalculationUseCase,
    this.getMetricsUseCase,
  );
  
  // State
  List<HealthCalculation> _calculations = [];
  List<HealthMetric> _metrics = [];
  bool _isLoading = false;
  String? _errorMessage;
  Failure? _failure;
  
  // Getters
  List<HealthCalculation> get calculations => _calculations;
  List<HealthMetric> get metrics => _metrics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Failure? get failure => _failure;
  bool get hasError => _errorMessage != null;
  
  /// Get calculation history
  Future<void> getCalculationHistory({
    String? calculationType,
    int? limit,
    int? offset,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _failure = null;
    notifyListeners();
    
    final result = await getCalculationHistoryUseCase(
      calculationType: calculationType,
      limit: limit,
      offset: offset,
    );
    
    result.fold(
      (failure) {
        _failure = failure;
        _errorMessage = _getErrorMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (calculations) {
        _calculations = calculations;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }
  
  /// Clear error
  void clearError() {
    _errorMessage = null;
    _failure = null;
    notifyListeners();
  }
  
  /// Save calculation
  Future<bool> saveCalculation({
    required String calculationType,
    required Map<String, dynamic> inputData,
    required Map<String, dynamic> resultData,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _failure = null;
    notifyListeners();
    
    final result = await saveCalculationUseCase(
      calculationType: calculationType,
      inputData: inputData,
      resultData: resultData,
    );
    
    return result.fold(
      (failure) {
        _failure = failure;
        _errorMessage = _getErrorMessage(failure);
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (data) {
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
        // Refresh history after saving
        getCalculationHistory();
        return true;
      },
    );
  }
  
  /// Get metrics
  Future<void> getMetrics({
    String? metricType,
    int? limit,
    int? offset,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _failure = null;
    notifyListeners();
    
    final result = await getMetricsUseCase(
      metricType: metricType,
      limit: limit,
      offset: offset,
    );
    
    result.fold(
      (failure) {
        _failure = failure;
        _errorMessage = _getErrorMessage(failure);
        _isLoading = false;
        notifyListeners();
      },
      (metrics) {
        _metrics = metrics;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }
  
  /// Get error message from failure
  String _getErrorMessage(Failure failure) {
    if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is AuthFailure) {
      return failure.message;
    } else {
      return 'Terjadi kesalahan yang tidak diketahui';
    }
  }
}

