import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/allergy.dart';
import 'package:apps/domain/usecases/allergy/get_allergies_usecase.dart';

/// Provider untuk state management allergies
class AllergyProvider extends ChangeNotifier {
  final GetAllergiesUsecase getAllergiesUsecase;
  
  bool _isLoading = false;
  String? _errorMessage;
  List<Allergy> _allergies = [];
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Allergy> get allergies => _allergies;
  
  AllergyProvider(this.getAllergiesUsecase);
  
  /// Load allergies
  Future<void> loadAllergies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await getAllergiesUsecase();
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _allergies = [];
        _isLoading = false;
        notifyListeners();
      },
      (allergies) {
        _allergies = allergies;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  
  /// Refresh allergies
  Future<void> refresh() async {
    await loadAllergies();
  }
}

