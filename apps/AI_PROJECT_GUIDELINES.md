# 🎯 PROJECT GUIDELINES - Flutter Clean Architecture dengan Provider

## 📋 INFORMASI PENTING UNTUK AI/ASSISTANT

**Ketika kamu mengubah atau membuat kode dalam project ini, WAJIB mengikuti aturan-aturan berikut:**

---

## 🏗️ ARSITEKTUR: CLEAN ARCHITECTURE

Project ini menggunakan **Clean Architecture** dengan struktur 3 layer:

```
lib/
├── core/                    # Shared utilities, constants, extensions
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── network/
│   ├── theme/
│   └── utils/
│
├── data/                    # Data Layer (External)
│   ├── datasources/         # Remote & Local Data Sources
│   │   ├── remote/
│   │   └── local/
│   ├── models/              # Data Models (JSON serialization)
│   └── repositories/        # Repository Implementations
│
├── domain/                  # Domain Layer (Business Logic)
│   ├── entities/            # Business Objects
│   ├── repositories/        # Repository Interfaces (Contracts)
│   └── usecases/           # Business Logic Use Cases
│
└── presentation/           # Presentation Layer (UI)
    ├── providers/          # State Management (Provider)
    ├── pages/              # Full Page Screens
    ├── widgets/            # Reusable Widgets
    └── routes/             # Navigation & Routing
```

### ⚠️ ATURAN LAYER DEPENDENCY:
- **Presentation** → **Domain** (Boleh akses domain)
- **Domain** → **Data** (TIDAK BOLEH! Domain murni business logic)
- **Data** → **Domain** (Boleh, untuk implementasi repository)
- **Core** bisa diakses semua layer

---

## 🔄 STATE MANAGEMENT: PROVIDER

### ✅ GUNAKAN PROVIDER:
- State management **WAJIB** menggunakan **Provider** (bukan Bloc, Riverpod, atau lainnya)
- Buat file Provider terpisah di `lib/presentation/providers/`
- Naming: `[feature]_provider.dart` (contoh: `auth_provider.dart`, `home_provider.dart`)

### 📏 MAX 1000 LINES PER FILE:
- **Maksimal 1000 baris per file Dart**
- Jika file melebihi 1000 baris, **WAJIB dipecah menjadi komponen-komponen lebih kecil**
- Contoh pemecahan:
  ```
  lib/presentation/pages/home/
  ├── home_page.dart          # Main page (< 300 lines)
  ├── home_header.dart        # Header widget (< 200 lines)
  ├── home_content.dart       # Content widget (< 300 lines)
  └── home_footer.dart        # Footer widget (< 200 lines)
  ```

---

## 📁 STRUKTUR FOLDER BERDASARKAN FUNGSIONALITAS

### ✅ ORGANISASI YANG BENAR:

Setiap fitur/feature harus memiliki struktur folder sendiri:

```
lib/
├── presentation/
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── login/
│   │   │   │   ├── login_page.dart
│   │   │   │   ├── login_form.dart
│   │   │   │   └── login_button.dart
│   │   │   └── register/
│   │   │       ├── register_page.dart
│   │   │       └── register_form.dart
│   │   └── home/
│   │       ├── home_page.dart
│   │       ├── home_header.dart
│   │       └── home_content.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── home_provider.dart
│   │   └── user_provider.dart
│   │
│   └── widgets/
│       ├── common/          # Widgets umum yang bisa digunakan semua fitur
│       │   ├── custom_button.dart
│       │   ├── custom_text_field.dart
│       │   └── loading_indicator.dart
│       └── auth/            # Widgets khusus untuk auth
│           ├── auth_card.dart
│           └── password_field.dart
│
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   └── product.dart
│   ├── repositories/
│   │   ├── auth_repository.dart        # Interface
│   │   └── product_repository.dart     # Interface
│   └── usecases/
│       ├── auth/
│       │   ├── login_usecase.dart
│       │   └── register_usecase.dart
│       └── product/
│           ├── get_products_usecase.dart
│           └── get_product_detail_usecase.dart
│
└── data/
    ├── datasources/
    │   ├── remote/
    │   │   ├── auth_remote_datasource.dart
    │   │   └── product_remote_datasource.dart
    │   └── local/
    │       ├── auth_local_datasource.dart
    │       └── product_local_datasource.dart
    ├── models/
    │   ├── user_model.dart
    │   └── product_model.dart
    └── repositories/
        ├── auth_repository_impl.dart
        └── product_repository_impl.dart
```

### ❌ STRUKTUR YANG SALAH (JANGAN LAKUKAN):
- Semua file di satu folder besar
- File terlalu panjang (> 1000 lines)
- Tidak ada pemisahan berdasarkan fitur
- Provider dicampur dengan UI di satu file

---

## 📝 ATURAN KODE & BEST PRACTICES

### 1. **NAMING CONVENTIONS:**
- **File**: `snake_case.dart` (contoh: `user_profile_page.dart`)
- **Class**: `PascalCase` (contoh: `UserProfilePage`)
- **Variable/Function**: `camelCase` (contoh: `getUserData()`)
- **Constant**: `UPPER_SNAKE_CASE` (contoh: `MAX_RETRY_COUNT`)

### 2. **FILE ORGANIZATION:**
Setiap file Dart harus diorganisir dengan urutan:
```dart
// 1. Imports (dart, flutter, packages, relative)
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

// 2. Part files (jika ada)
part 'home_header.dart';

// 3. Class documentation
/// HomePage widget untuk menampilkan halaman utama aplikasi
class HomePage extends StatelessWidget {
  // 4. Constants
  static const String routeName = '/home';
  
  // 5. Fields
  final String? userId;
  
  // 6. Constructor
  const HomePage({Key? key, this.userId}) : super(key: key);
  
  // 7. Methods
  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

### 3. **PROVIDER USAGE:**
```dart
// ✅ BENAR: Menggunakan Provider dengan Consumer atau context.read()
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return CircularProgressIndicator();
        }
        return Text(authProvider.user?.name ?? 'Guest');
      },
    );
  }
}

// Atau menggunakan context.read() untuk one-time read
final authProvider = context.read<AuthProvider>();
```

### 4. **ERROR HANDLING:**
- Gunakan `Either<Failure, Success>` pattern dari package `dartz` untuk domain layer
- Handle errors di presentation layer dengan try-catch atau error state di Provider

### 5. **DEPENDENCY INJECTION:**
- Gunakan `MultiProvider` atau `Provider` untuk dependency injection
- Setup di `main.dart` atau file provider setup terpisah

---

## 🚫 YANG TIDAK BOLEH DILAKUKAN

1. ❌ **Mengganti state management** dari Provider ke Bloc/Riverpod/GetX
2. ❌ **Membuat file > 1000 lines** tanpa dipecah
3. ❌ **Mencampur layer** (misal: UI langsung akses data source)
4. ❌ **Menghapus struktur folder** yang sudah ada tanpa konfirmasi
5. ❌ **Mengubah arsitektur** dari Clean Architecture
6. ❌ **Membuat semua widget di satu file** besar
7. ❌ **Tidak menggunakan folder per fitur**

---

## ✅ CHECKLIST SEBELUM COMMIT/SAVE

Sebelum menyelesaikan task, pastikan:

- [ ] Semua file Dart ≤ 1000 lines
- [ ] Struktur folder mengikuti Clean Architecture
- [ ] State management menggunakan Provider
- [ ] Setiap fitur punya folder sendiri
- [ ] Naming convention sudah benar
- [ ] Layer dependency sudah benar (domain tidak akses data layer)
- [ ] Error handling sudah diimplementasikan
- [ ] Provider sudah di-setup dengan benar
- [ ] Widget-widget sudah dipecah sesuai fungsionalitas
- [ ] Tidak ada hardcoded values (gunakan constants)

---

## 📚 REFERENSI STRUKTUR

Jika bingung, lihat contoh struktur di:
- Clean Architecture: https://resocoder.com/flutter-clean-architecture-tdd
- Provider: https://pub.dev/packages/provider

---

## 🎯 CONTOH IMPLEMENTASI BENAR

### Provider Example:
```dart
// lib/presentation/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:your_app/domain/usecases/auth/login_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUsecase _loginUsecase;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  AuthProvider(this._loginUsecase);
  
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    final result = await _loginUsecase(email, password);
    
    result.fold(
      (failure) => _errorMessage = failure.message,
      (user) => {
        // Handle success
      },
    );
    
    _isLoading = false;
    notifyListeners();
  }
}
```

### Page Example:
```dart
// lib/presentation/pages/auth/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import 'login_form.dart';

class LoginPage extends StatelessWidget {
  static const String routeName = '/login';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Login', style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 32),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 🔄 UPDATE LOG

Jika ada perubahan aturan, update file ini dan tambahkan di section ini:
- 2024-XX-XX: Initial guidelines created

---

**INGAT: Setiap perubahan kode HARUS mengikuti guidelines ini!**
