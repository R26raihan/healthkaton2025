import 'package:flutter/foundation.dart';
import 'package:apps/domain/entities/medical_record.dart';
import 'package:apps/domain/entities/medical_record_full.dart';
import 'package:apps/domain/usecases/medical_record/get_medical_records_usecase.dart';
import 'package:apps/domain/usecases/medical_record/get_medical_record_by_id_usecase.dart';
import 'package:apps/data/datasources/local/medical_record_local_datasource.dart';

/// Provider untuk state management medical records
class MedicalRecordProvider extends ChangeNotifier {
  final GetMedicalRecordsUsecase getMedicalRecordsUsecase;
  final GetMedicalRecordByIdUsecase getMedicalRecordByIdUsecase;
  final MedicalRecordLocalDataSource localDataSource;
  
  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _errorMessage;
  String? _errorMessageDetail;
  List<MedicalRecord> _records = [];
  MedicalRecordFull? _selectedRecord;
  String? _savedRecordId;
  
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get errorMessage => _errorMessage;
  String? get errorMessageDetail => _errorMessageDetail;
  List<MedicalRecord> get records => _records;
  MedicalRecordFull? get selectedRecord => _selectedRecord;
  String? get savedRecordId => _savedRecordId;
  
  MedicalRecordProvider(
    this.getMedicalRecordsUsecase,
    this.getMedicalRecordByIdUsecase, {
    MedicalRecordLocalDataSource? localDataSource,
  }) : localDataSource = localDataSource ?? MedicalRecordLocalDataSourceImpl() {
    // Load saved record_id saat provider di-initialize
    _loadSavedRecordId();
  }
  
  /// Load saved record_id dari secure storage
  Future<void> _loadSavedRecordId() async {
    _savedRecordId = await localDataSource.getRecordId();
    notifyListeners();
  }
  
  /// Load medical records
  Future<void> loadMedicalRecords({int skip = 0, int limit = 100}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await getMedicalRecordsUsecase(
      skip: skip,
      limit: limit,
    );
    
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _records = [];
        _isLoading = false;
        notifyListeners();
      },
      (records) {
        _records = records;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        
        // Simpan record_id dari record pertama (terbaru) ke secure storage
        if (records.isNotEmpty) {
          final latestRecordId = records.first.recordId;
          saveRecordId(latestRecordId);
        }
      },
    );
  }
  
  /// Save record_id ke secure storage
  Future<void> saveRecordId(String recordId) async {
    await localDataSource.saveRecordId(recordId);
    _savedRecordId = recordId;
    notifyListeners();
  }
  
  /// Get saved record_id dari secure storage
  Future<String?> getSavedRecordId() async {
    _savedRecordId = await localDataSource.getRecordId();
    notifyListeners();
    return _savedRecordId;
  }
  
  /// Delete record_id dari secure storage
  Future<void> deleteRecordId() async {
    await localDataSource.deleteRecordId();
    _savedRecordId = null;
    notifyListeners();
  }
  
  /// Load medical record by ID dengan semua data terkait
  Future<void> loadMedicalRecordById(String recordId) async {
    _isLoadingDetail = true;
    _errorMessageDetail = null;
    _selectedRecord = null;
    notifyListeners();
    
    final result = await getMedicalRecordByIdUsecase(recordId);
    
    result.fold(
      (failure) {
        _errorMessageDetail = failure.message;
        _selectedRecord = null;
        _isLoadingDetail = false;
        notifyListeners();
      },
      (record) {
        _selectedRecord = record;
        _errorMessageDetail = null;
        _isLoadingDetail = false;
        notifyListeners();
      },
    );
  }
  
  /// Clear selected record
  void clearSelectedRecord() {
    _selectedRecord = null;
    _errorMessageDetail = null;
    notifyListeners();
  }
  
  /// Refresh medical records
  Future<void> refresh() async {
    await loadMedicalRecords();
  }
}

