import 'package:apps/core/storage/secure_storage_service.dart';

/// Local data source untuk menyimpan data medical record secara lokal
abstract class MedicalRecordLocalDataSource {
  Future<void> saveRecordId(String recordId);
  Future<String?> getRecordId();
  Future<void> deleteRecordId();
}

class MedicalRecordLocalDataSourceImpl implements MedicalRecordLocalDataSource {
  MedicalRecordLocalDataSourceImpl();
  
  @override
  Future<void> saveRecordId(String recordId) async {
    await SecureStorageService.saveRecordId(recordId);
  }
  
  @override
  Future<String?> getRecordId() async {
    return await SecureStorageService.getRecordId();
  }
  
  @override
  Future<void> deleteRecordId() async {
    await SecureStorageService.deleteRecordId();
  }
}

