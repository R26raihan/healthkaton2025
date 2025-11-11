# Setup API Integration untuk Flutter App

## Overview
Aplikasi Flutter sudah terintegrasi dengan backend API local untuk fitur authentication (login & register).

## Konfigurasi

### 1. Base URL
File: `apps/lib/core/constants/app_constants.dart`

```dart
static const String baseUrl = 'http://localhost:8000';
```

**Penting**: Sesuaikan base URL berdasarkan platform:

- **iOS Simulator**: `http://localhost:8000`
- **Android Emulator**: `http://10.0.2.2:8000`
- **Device Fisik**: `http://[IP_KOMPUTER_ANDA]:8000`
  - Contoh: `http://192.168.1.100:8000`
  - Cek IP komputer dengan: `ifconfig` (Mac/Linux) atau `ipconfig` (Windows)

### 2. Dependencies
File: `apps/pubspec.yaml`

Sudah ditambahkan:
- `dio: ^5.4.0` - HTTP client
- `flutter_secure_storage: ^9.0.0` - Secure storage untuk token

Jalankan:
```bash
cd apps
flutter pub get
```

## Fitur yang Sudah Diintegrasikan

### 1. Login
- Endpoint: `POST /login`
- Format: OAuth2 form data
- Response: `{ "access_token": "...", "token_type": "bearer" }`
- Token disimpan di **Flutter Secure Storage** (aman)

### 2. Get Current User
- Endpoint: `GET /me`
- Headers: `Authorization: Bearer <token>`
- Response: User info (id, name, email, phoneNumber)

### 3. Register
- Endpoint: `POST /register`
- Format: JSON
- Response: User info

## Flow Login

1. User input email & password
2. App mengirim POST request ke `/login`
3. Backend mengembalikan `access_token`
4. Token disimpan di **Secure Storage**
5. App memanggil `/me` dengan token untuk mendapatkan user info
6. User info disimpan di **SharedPreferences**
7. User diarahkan ke dashboard

## Testing

### 1. Pastikan Backend Berjalan
```bash
cd backend
python running.py --service auth
# atau
./run.sh --service auth
```

Backend harus berjalan di: `http://localhost:8000`

### 2. Test di Flutter App

#### iOS Simulator:
```dart
baseUrl = 'http://localhost:8000'
```

#### Android Emulator:
```dart
baseUrl = 'http://10.0.2.2:8000'
```

#### Device Fisik:
1. Cek IP komputer:
   ```bash
   # Mac/Linux
   ifconfig | grep "inet "
   
   # Windows
   ipconfig
   ```

2. Update baseUrl:
   ```dart
   baseUrl = 'http://192.168.1.100:8000' // Ganti dengan IP Anda
   ```

3. Pastikan device dan komputer dalam jaringan WiFi yang sama

### 3. Test Login
1. Buka aplikasi Flutter
2. Masuk ke halaman login
3. Input email & password
4. Klik login
5. Jika berhasil, akan diarahkan ke dashboard
6. Token tersimpan di secure storage

## Troubleshooting

### Error: "Tidak dapat terhubung ke server"
**Solusi**:
1. Pastikan backend berjalan: `http://localhost:8000`
2. Cek baseUrl di `app_constants.dart`
3. Untuk device fisik, pastikan IP benar dan dalam jaringan yang sama
4. Untuk Android emulator, gunakan `10.0.2.2` bukan `localhost`

### Error: "Connection refused"
**Solusi**:
1. Pastikan backend berjalan di port 8000
2. Cek firewall tidak memblokir port 8000
3. Untuk device fisik, pastikan backend listen di `0.0.0.0:8000` bukan `localhost:8000`

### Error: "401 Unauthorized"
**Solusi**:
1. Cek email dan password benar
2. Pastikan user sudah terdaftar di database
3. Cek response error dari backend

### Token tidak tersimpan
**Solusi**:
1. Pastikan `flutter_secure_storage` sudah diinstall
2. Cek permission untuk secure storage (iOS/Android)
3. Untuk Android, pastikan `minSdkVersion >= 18`

## File yang Diubah

1. `apps/pubspec.yaml` - Menambahkan `flutter_secure_storage`
2. `apps/lib/core/constants/app_constants.dart` - Update base URL
3. `apps/lib/core/network/auth_dio_client.dart` - Dio client untuk auth
4. `apps/lib/core/storage/secure_storage_service.dart` - Secure storage service
5. `apps/lib/data/datasources/remote/auth_remote_datasource.dart` - API integration
6. `apps/lib/data/datasources/local/auth_local_datasource.dart` - Update untuk secure storage
7. `apps/lib/data/repositories/auth_repository_impl.dart` - Update login flow

## Next Steps

1. **Add Token Interceptor**: Auto-inject token ke setiap request
2. **Refresh Token**: Implementasi refresh token jika token expired
3. **Auto Logout**: Logout otomatis jika token expired
4. **Error Handling**: Improve error messages untuk user
5. **Loading States**: Better loading indicators

## API Endpoints

### Authentication
- `POST /login` - Login dengan email & password
- `POST /register` - Register user baru
- `GET /me` - Get current user info (requires token)

### Response Format

#### Login Response:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

#### User Response:
```json
{
  "id": 1,
  "name": "User Name",
  "email": "user@example.com",
  "phoneNumber": "+628123456789",
  "is_active": true,
  "created_at": "2024-01-01T00:00:00",
  "updated_at": "2024-01-01T00:00:00"
}
```

## Security Notes

1. **Token Storage**: Token disimpan di Flutter Secure Storage (encrypted)
2. **HTTPS**: Untuk production, gunakan HTTPS bukan HTTP
3. **Token Expiration**: Token memiliki expiration time (cek di backend config)
4. **Auto Refresh**: Consider implementasi auto refresh token

