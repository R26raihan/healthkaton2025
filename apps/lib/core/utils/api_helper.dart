import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:apps/core/constants/app_constants.dart';

/// Helper untuk menentukan base URL API berdasarkan platform
/// Auto-detect IP address WiFi untuk device fisik
/// Menggunakan dart:io NetworkInterface (built-in, tidak perlu package tambahan)
class ApiHelper {
  static String? _cachedLocalIp;
  static const int _defaultPort = 8000;
  
  /// Get base URL berdasarkan platform dengan auto-detect IP WiFi
  /// Sekarang menggunakan smart detection untuk find server IP di network
  /// 
  /// - iOS Simulator: localhost:8000
  /// - Android Emulator: 10.0.2.2:8000 (special IP untuk emulator)
  /// - Device Fisik: Auto-detect server IP di subnet yang sama
  static Future<String> getBaseUrl() async {
    try {
      if (kDebugMode) {
        print('🔍 [API Helper] Starting base URL detection...');
      }
      
      // Untuk Android
      if (Platform.isAndroid) {
        // Cek apakah bisa detect local IP (device fisik) atau tidak (emulator)
        final localIp = await getLocalIpAddress();
        
        if (localIp != null && localIp.isNotEmpty) {
          // Device fisik: langsung gunakan smart detection
          if (kDebugMode) {
            print('📱 [API Helper] Android device detected with IP: $localIp');
            print('🔍 [API Helper] Searching for server in same network...');
          }
          
          final serverIp = await findServerIp(timeout: const Duration(seconds: 3));
          if (serverIp != null && serverIp.isNotEmpty) {
            if (kDebugMode) {
              print('✅ [API Helper] Server found at: $serverIp');
            }
            return 'http://$serverIp:$_defaultPort';
          }
          
          // Fallback: gunakan device IP (server mungkin di device yang sama)
          if (kDebugMode) {
            print('⚠️ [API Helper] Server not found, using device IP as fallback: $localIp');
          }
          return 'http://$localIp:$_defaultPort';
        } else {
          // Emulator: test 10.0.2.2
          if (kDebugMode) {
            print('📱 [API Helper] Android emulator detected, testing 10.0.2.2...');
          }
          final emulatorUrl = 'http://10.0.2.2:$_defaultPort';
          final emulatorWorks = await testConnection(emulatorUrl, timeout: const Duration(seconds: 2));
          if (emulatorWorks) {
            if (kDebugMode) {
              print('✅ [API Helper] Emulator connection successful');
            }
            return emulatorUrl;
          }
          return emulatorUrl;
        }
      } 
      // Untuk iOS
      else if (Platform.isIOS) {
        // Cek apakah bisa detect local IP (device fisik) atau tidak (simulator)
        final localIp = await getLocalIpAddress();
        
        if (localIp != null && localIp.isNotEmpty) {
          // Device fisik: gunakan smart detection
          if (kDebugMode) {
            print('📱 [API Helper] iOS device detected with IP: $localIp');
            print('🔍 [API Helper] Searching for server in same network...');
          }
          
          final serverIp = await findServerIp(timeout: const Duration(seconds: 3));
          if (serverIp != null && serverIp.isNotEmpty) {
            if (kDebugMode) {
              print('✅ [API Helper] Server found at: $serverIp');
            }
            return 'http://$serverIp:$_defaultPort';
          }
          
          // Fallback ke device IP
          if (kDebugMode) {
            print('⚠️ [API Helper] Server not found, trying device IP: $localIp');
          }
          return 'http://$localIp:$_defaultPort';
        } else {
          // Simulator: test localhost
          if (kDebugMode) {
            print('📱 [API Helper] iOS simulator detected, testing localhost...');
          }
          final localhostUrl = 'http://localhost:$_defaultPort';
          final localhostWorks = await testConnection(localhostUrl, timeout: const Duration(seconds: 2));
          if (localhostWorks) {
            if (kDebugMode) {
              print('✅ [API Helper] Simulator connection successful');
            }
            return localhostUrl;
          }
          return localhostUrl;
        }
      }
      
      // Platform lain: gunakan smart detection
      if (kDebugMode) {
        print('🔍 [API Helper] Other platform, using smart detection...');
      }
      final serverIp = await findServerIp(timeout: const Duration(seconds: 3));
      if (serverIp != null && serverIp.isNotEmpty) {
        return 'http://$serverIp:$_defaultPort';
      }
      
      final localIp = await getLocalIpAddress();
      if (localIp != null && localIp.isNotEmpty) {
        return 'http://$localIp:$_defaultPort';
      }
      
      return 'http://localhost:$_defaultPort';
    } catch (e) {
      if (kDebugMode) {
        print('❌ [API Helper] Error in getBaseUrl: $e');
      }
      return AppConstants.baseUrl;
    }
  }
  
  /// Get base URL (synchronous version dengan cache)
  /// Gunakan ini jika sudah pernah memanggil getBaseUrl() sebelumnya
  static String getBaseUrlSync() {
    if (_cachedLocalIp != null && _cachedLocalIp!.isNotEmpty) {
      return 'http://$_cachedLocalIp:$_defaultPort';
    }
    
    // Fallback berdasarkan platform
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_defaultPort';
    } else if (Platform.isIOS) {
      return 'http://localhost:$_defaultPort';
    }
    
    return AppConstants.baseUrl;
  }
  
  /// Get local IP address (192.168.x.x)
  /// Auto-detect IP address WiFi menggunakan dart:io NetworkInterface
  static Future<String?> getLocalIpAddress() async {
    try {
      // Cache hasil untuk performa
      if (_cachedLocalIp != null) {
        return _cachedLocalIp;
      }
      
      // Get all network interfaces
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      // Priority: WiFi interfaces biasanya memiliki nama seperti 'en0', 'wlan0', 'Wi-Fi'
      // Kita akan prioritaskan interface yang bukan loopback
      final candidateIps = <String>[];
      
      for (final interface in interfaces) {
        // Skip loopback interface
        if (interface.name == 'lo' || 
            interface.name.startsWith('lo') ||
            interface.name == 'Loopback') {
          continue;
        }
        
        // Check setiap address di interface
        for (final addr in interface.addresses) {
          final ip = addr.address;
          
          // Filter hanya IP lokal (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
          if (_isLocalIp(ip)) {
            // Prioritaskan 192.168.x.x (biasanya WiFi rumah)
            if (ip.startsWith('192.168.')) {
              _cachedLocalIp = ip;
              return ip;
            }
            // Simpan candidate untuk fallback
            candidateIps.add(ip);
          }
        }
      }
      
      // Jika ada candidate, ambil yang pertama (biasanya yang aktif)
      if (candidateIps.isNotEmpty) {
        _cachedLocalIp = candidateIps.first;
        return candidateIps.first;
      }
      
      return null;
    } catch (e) {
      // Jika error, return null (akan fallback ke localhost)
      return null;
    }
  }
  
  /// Check jika IP adalah local IP (192.168.x.x, 10.x.x.x, atau 172.16-31.x.x)
  static bool _isLocalIp(String ip) {
    if (ip.isEmpty) return false;
    
    // Filter IPv6 (contains :)
    if (ip.contains(':')) return false;
    
    // Filter loopback
    if (ip == '127.0.0.1' || ip.startsWith('127.')) return false;
    
    // Check 192.168.x.x (WiFi rumah biasanya pakai ini)
    if (ip.startsWith('192.168.')) return true;
    
    // Check 10.x.x.x (corporate network atau hotspot)
    if (ip.startsWith('10.')) {
      // Skip 10.0.2.2 (Android emulator special IP)
      if (ip == '10.0.2.2') return false;
      return true;
    }
    
    // Check 172.16.x.x - 172.31.x.x (private range)
    final parts = ip.split('.');
    if (parts.length == 4) {
      final first = int.tryParse(parts[0]);
      final second = int.tryParse(parts[1]);
      if (first == 172 && second != null && second >= 16 && second <= 31) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Clear cached IP (untuk refresh)
  static void clearCache() {
    _cachedLocalIp = null;
  }
  
  /// Get base URL untuk development (dengan fallback)
  static Future<String> getDevBaseUrl() async {
    return await getBaseUrl();
  }
  
  /// Debug: Print semua network interfaces (untuk debugging)
  static Future<void> debugPrintInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      
      print('=== Network Interfaces ===');
      for (final interface in interfaces) {
        print('Interface: ${interface.name}');
        for (final addr in interface.addresses) {
          print('  - ${addr.address} (${_isLocalIp(addr.address) ? "LOCAL" : "OTHER"})');
        }
      }
      print('=========================');
    } catch (e) {
      print('Error getting interfaces: $e');
    }
  }
  
  /// Test connection ke backend
  static Future<bool> testConnection(String baseUrl, {Duration timeout = const Duration(seconds: 5)}) async {
    HttpClient? client;
    try {
      client = HttpClient();
      client.connectionTimeout = timeout;
      client.idleTimeout = timeout;
      client.autoUncompress = false;
      
      // Test endpoint health check
      final uri = Uri.parse('$baseUrl/health/');
      
      final request = await client.getUrl(uri).timeout(timeout);
      request.headers.set('Connection', 'close');
      
      final response = await request.close().timeout(timeout);
      
      // Baca response body (optional, untuk memastikan connection benar-benar established)
      await response.drain();
      
      final success = response.statusCode == 200;
      client.close();
      
      return success;
    } catch (e) {
      // Connection failed
      if (client != null) {
        try {
          client.close();
        } catch (_) {}
      }
      return false;
    }
  }
  
  /// Find server IP dengan testing beberapa IP di subnet yang sama
  /// Mengembalikan IP yang berhasil connect ke backend
  static Future<String?> findServerIp({Duration timeout = const Duration(seconds: 3)}) async {
    try {
      // Ambil IP device sendiri dulu
      final deviceIp = await getLocalIpAddress();
      if (deviceIp == null || deviceIp.isEmpty) {
        if (kDebugMode) {
          print('⚠️ [API Helper] Cannot detect device IP');
        }
        return null;
      }
      
      if (kDebugMode) {
        print('🔍 [API Helper] Device IP: $deviceIp');
      }
      
      // Extract subnet (192.168.1.x -> 192.168.1)
      final parts = deviceIp.split('.');
      if (parts.length != 4) {
        return null;
      }
      
      final subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
      final deviceLastOctet = int.tryParse(parts[3]) ?? 0;
      
      if (kDebugMode) {
        print('🔍 [API Helper] Subnet: $subnet.x, Device last octet: $deviceLastOctet');
      }
      
      // List IP yang akan di-test (prioritas: device IP sendiri dulu, lalu IP terdekat, lalu common IP)
      final ipCandidates = <int>[];
      
      // PRIORITAS TERtinggi: Test device IP sendiri dulu (server mungkin running di device yang sama)
      // Ini penting untuk development atau jika server dan client di device yang sama
      ipCandidates.add(deviceLastOctet);
      
      // Prioritas TINGGI: IP dengan offset kecil (lebih dekat ke device)
      // Test: -1, +1, -2, +2, -5, +5, -10, +10 (dalam urutan ini)
      final priorityOffsets = [-1, 1, -2, 2, -5, 5, -10, 10, -20, 20];
      for (int offset in priorityOffsets) {
        final candidate = deviceLastOctet + offset;
        if (candidate >= 1 && candidate <= 254) {
          if (!ipCandidates.contains(candidate)) {
            ipCandidates.add(candidate);
          }
        }
      }
      
      // Tambahkan common IP (router biasanya .1, server common .11, .100, dll)
      // Tapi pastikan tidak duplicate
      final commonIps = [1, 11, 100, 101, 200, 254];
      for (final ip in commonIps) {
        if (!ipCandidates.contains(ip)) {
          ipCandidates.add(ip);
        }
      }
      
      if (kDebugMode) {
        print('🔍 [API Helper] Will test ${ipCandidates.length} IPs');
        print('🔍 [API Helper] First 10 candidates: ${ipCandidates.take(10).map((ip) => '$subnet.$ip').join(', ')}');
      }
      
      // Test setiap candidate secara sequential
      int tested = 0;
      for (final lastOctet in ipCandidates) {
        tested++;
        final testIp = '$subnet.$lastOctet';
        final testUrl = 'http://$testIp:$_defaultPort';
        
        if (kDebugMode && tested <= 5) {
          print('🔍 [API Helper] Testing ($tested/${ipCandidates.length}): $testUrl');
        }
        
        final isConnected = await testConnection(testUrl, timeout: timeout);
        if (isConnected) {
          if (kDebugMode) {
            print('✅ [API Helper] ✅✅✅ SERVER FOUND at: $testIp ✅✅✅');
          }
          _cachedLocalIp = testIp;
          return testIp;
        }
      }
      
      if (kDebugMode) {
        print('❌ [API Helper] No server found after testing ${ipCandidates.length} IPs in subnet $subnet.x');
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [API Helper] Error finding server IP: $e');
      }
      return null;
    }
  }
  
}

