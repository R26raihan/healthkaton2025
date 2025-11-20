import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/prescription.dart';
import 'package:apps/domain/usecases/prescription/get_my_medications_usecase.dart';

class PrescriptionProvider extends ChangeNotifier {
  final GetMyMedicationsUsecase getMyMedicationsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<Prescription> _prescriptions = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Prescription> get prescriptions => _prescriptions;

  PrescriptionProvider(this.getMyMedicationsUsecase);

  Future<void> loadMedications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getMyMedicationsUsecase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _prescriptions = [];
      },
      (prescriptions) {
        _prescriptions = prescriptions;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadMedications();
  }
}

