# Auto-Detect IP WiFi untuk API

## Overview
Aplikasi Flutter sekarang memiliki fitur **auto-detect IP WiFi** untuk menentukan base URL API secara otomatis. Tidak perlu lagi mengubah IP secara manual!

## Cara Kerja

### 1. Auto-Detect IP WiFi
Aplikasi akan secara otomatis mendeteksi IP address WiFi device (192.168.x.x) menggunakan `dart:io NetworkInterface`.

### 2. Platform-Specific Behavior

#### iOS Simulator
- Menggunakan `localhost:8000`
- Jika tidak ada IP lokal yang terdeteksi

#### Android Emulator
- Menggunakan `10.0.2.2:8000` (special IP untuk emulator)
- Jika tidak ada IP lokal yang terdeteksi

#### Device Fisik (iOS/Android)
- **Auto-detect IP WiFi** (192.168.x.x:8000)
- Prioritaskan IP yang dimulai dengan `192.168.` (WiFi rumah)
- Fallback ke IP lokal lainnya jika ada

## IP yang Didukung

Auto-detect akan mencari IP dengan pattern berikut:
1. **192.168.x.x** - WiFi rumah (prioritas tertinggi)
2. **10.x.x.x** - Corporate network atau hotspot (kecuali 10.0.2.2 untuk emulator)
3. **172.16.x.x - 172.31.x.x** - Private network range

## Contoh

Jika IP WiFi Anda adalah **192.168.1.11**:
- Aplikasi akan otomatis menggunakan: `http://192.168.1.11:8000`
- Tidak perlu mengubah konfigurasi manual!

## Testing

### 1. Debug Network Interfaces
Untuk melihat IP yang terdeteksi, tambahkan ini di `main.dart`:

```dart
import 'package:apps/core/utils/api_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Debug: Print semua network interfaces
  await ApiHelper.debugPrintInterfaces();
  
  // Get base URL
  final baseUrl = await ApiHelper.getBaseUrl();
  print('Using base URL: $baseUrl');
  
  runApp(MyApp());
}
```

### 2. Check IP yang Digunakan
Base URL akan ditampilkan di console ketika aplikasi start:
```
[AUTH API] Using base URL: http://192.168.1.11:8000
```

## Troubleshooting

### IP Tidak Terdeteksi
**Problem**: Aplikasi menggunakan localhost padahal device fisik

**Solusi**:
1. Pastikan device terhubung ke WiFi (bukan mobile data)
2. Pastikan device dan komputer dalam WiFi yang sama
3. Check console untuk melihat IP yang terdeteksi
4. Jika masih tidak terdeteksi, bisa set manual di `app_constants.dart`

### Android Emulator Masih Pakai 10.0.2.2
**Problem**: Android emulator menggunakan 10.0.2.2 (benar untuk emulator)

**Solusi**: 
- Ini normal untuk Android emulator
- 10.0.2.2 adalah special IP untuk mengakses localhost dari emulator
- Jika testing di device fisik Android, IP akan terdeteksi otomatis

### iOS Simulator Masih Pakai localhost
**Problem**: iOS Simulator menggunakan localhost (benar untuk simulator)

**Solusi**:
- Ini normal untuk iOS Simulator
- localhost akan bekerja karena simulator dan host machine sama
- Jika testing di device fisik iOS, IP akan terdeteksi otomatis

## Manual Override (Jika Diperlukan)

Jika auto-detect tidak bekerja, Anda bisa set manual di `app_constants.dart`:

```dart
static const String baseUrl = 'http://192.168.1.11:8000'; // Set manual
```

Tapi dengan auto-detect, biasanya tidak perlu!

## Implementation Details

### File: `apps/lib/core/utils/api_helper.dart`
- `getLocalIpAddress()` - Detect IP WiFi menggunakan NetworkInterface
- `_isLocalIp()` - Filter hanya IP lokal (192.168.x.x, 10.x.x.x, dll)
- `getBaseUrl()` - Get base URL dengan auto-detect

### File: `apps/lib/core/network/auth_dio_client.dart`
- `client` (Future) - Initialize Dio dengan auto-detect IP
- `clientSync` - Synchronous version dengan cache
- `refresh()` - Clear cache dan re-detect IP

### Caching
- IP address di-cache untuk performa
- Cache akan di-refresh jika diperlukan
- Gunakan `ApiHelper.clearCache()` untuk force refresh

## Notes

1. **WiFi Required**: Auto-detect hanya bekerja jika device terhubung ke WiFi
2. **Same Network**: Device dan komputer harus dalam WiFi yang sama
3. **Performance**: IP di-cache untuk menghindari detect berulang
4. **Fallback**: Jika tidak bisa detect, fallback ke localhost/10.0.2.2

## Future Improvements

1. **Network Change Listener**: Auto-refresh IP ketika WiFi berubah
2. **Multiple IP Support**: Pilih IP jika ada multiple interfaces
3. **User Selection**: Allow user memilih IP jika ada multiple options
4. **IP Validation**: Test koneksi ke IP sebelum digunakan

