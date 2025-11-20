import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:video_player/video_player.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/core/services/tutorial_service.dart';

/// Widget untuk menampilkan tutorial onboarding dengan video perkenalan
class OnboardingTutorialWidget {
  final BuildContext context;
  final List<TargetFocus> targets;
  
  OnboardingTutorialWidget({
    required this.context,
    required this.targets,
  });
  
  /// Show tutorial dengan video perkenalan
  static Future<void> showTutorial({
    required BuildContext context,
    required List<GlobalKey> menuKeys,
    required GlobalKey? chatbotKey,
    required GlobalKey? bottomNavKey,
    GlobalKey? headerKey,
  }) async {
    // Tampilkan video perkenalan dulu
    await _showIntroVideo(context);
    
    // Tunggu sebentar sebelum menampilkan tutorial
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Tampilkan tutorial coach marks
    await _showCoachMarks(context, menuKeys, chatbotKey, bottomNavKey, headerKey);
    
    // Mark tutorial sebagai sudah ditampilkan
    await TutorialService.markTutorialShown();
  }
  
  /// Tampilkan video perkenalan AI Assistant
  static Future<void> _showIntroVideo(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _IntroVideoDialog(),
    );
  }
  
  /// Tampilkan tutorial coach marks untuk semua fitur
  static Future<void> _showCoachMarks(
    BuildContext context,
    List<GlobalKey> menuKeys,
    GlobalKey? chatbotKey,
    GlobalKey? bottomNavKey,
    GlobalKey? headerKey,
  ) async {
    final targets = <TargetFocus>[];
    
    // Target 1: Header Dashboard
    if (headerKey != null) {
      targets.add(
        TargetFocus(
          identify: "dashboard_header",
          keyTarget: headerKey,
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _buildTargetContent(
                  context,
                  controller,
                  title: "Selamat Datang! 👋",
                  description: "Ini adalah dashboard utama aplikasi Healthkon BPJS. Di sini Anda dapat mengakses semua layanan kesehatan.",
                  showVideo: true,
                  videoPath: 'assets/images/video_rag1.mp4',
                );
              },
            ),
          ],
        ),
      );
    }
    
    // Target 2-9: Menu Items
    final menuTitles = [
      "Ringkasan Rekam Medis",
      "Penjelasan Obat",
      "Daftar Alergi",
      "Q&A Personal Kesehatan",
      "Cek Interaksi Obat",
      "Tren Grafik Kesehatan",
      "Kalkulator Kesehatan",
      "BMI & Monitoring",
    ];
    
    final menuDescriptions = [
      "Lihat riwayat kesehatan dan rekam medis Anda",
      "Dapatkan penjelasan detail tentang obat-obatan",
      "Kelola daftar alergi Anda",
      "Konsultasi kesehatan dengan AI Assistant",
      "Cek interaksi antar obat yang Anda konsumsi",
      "Pantau tren kesehatan Anda dengan grafik",
      "Hitung berbagai indikator kesehatan",
      "Pantau BMI dan kesehatan Anda secara berkala",
    ];
    
    for (int i = 0; i < menuKeys.length && i < menuTitles.length; i++) {
      targets.add(
        TargetFocus(
          identify: "menu_$i",
          keyTarget: menuKeys[i],
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _buildTargetContent(
                  context,
                  controller,
                  title: menuTitles[i],
                  description: menuDescriptions[i],
                  showVideo: true,
                  videoPath: 'assets/images/video_rag1.mp4',
                );
              },
            ),
          ],
        ),
      );
    }
    
    // Target: Chatbot FAB
    if (chatbotKey != null) {
      targets.add(
        TargetFocus(
          identify: "chatbot",
          keyTarget: chatbotKey,
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _buildTargetContent(
                  context,
                  controller,
                  title: "AI Assistant 🤖",
                  description: "Klik tombol ini untuk berinteraksi dengan AI Assistant. Dapatkan jawaban tentang kesehatan Anda berdasarkan data medis pribadi.",
                  showVideo: true,
                  videoPath: 'assets/images/video_rag1.mp4',
                );
              },
            ),
          ],
        ),
      );
    }
    
    // Target: Bottom Navigation
    if (bottomNavKey != null) {
      targets.add(
        TargetFocus(
          identify: "bottom_nav",
          keyTarget: bottomNavKey,
          alignSkip: Alignment.topRight,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _buildTargetContent(
                  context,
                  controller,
                  title: "Navigasi Utama",
                  description: "Gunakan navigasi ini untuk berpindah antar halaman: Dashboard, Rekam Medis, dan Profile.",
                  showVideo: true,
                  videoPath: 'assets/images/video_rag1.mp4',
                );
              },
            ),
          ],
        ),
      );
    }
    
    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: AppTheme.primaryGreen.withOpacity(0.8),
      textSkip: "LEWATI",
      paddingFocus: 10,
      opacityShadow: 0.8,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        // Tutorial selesai
      },
      onSkip: () {
        // User skip tutorial
        return true;
      },
    );
    
    tutorial.show(context: context);
  }
  
  static Widget _buildTargetContent(
    BuildContext context,
    TutorialCoachMarkController controller, {
    required String title,
    required String description,
    bool showVideo = false,
    String? videoPath,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showVideo && videoPath != null)
            _VideoPlayerWidget(videoPath: videoPath)
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  controller.skip();
                },
                child: const Text(
                  'Lewati',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  controller.next();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Lanjut'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dialog untuk video perkenalan
class _IntroVideoDialog extends StatefulWidget {
  @override
  State<_IntroVideoDialog> createState() => _IntroVideoDialogState();
}

class _IntroVideoDialogState extends State<_IntroVideoDialog> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/images/asisten_animasi_hello.mp4',
      );
      
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading intro video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Video atau placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isVideoInitialized && _videoController != null && !_hasError
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : _hasError
                      ? const Icon(
                          Icons.play_circle_outline,
                          size: 80,
                          color: Colors.white,
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Selamat Datang! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Saya adalah AI Assistant kesehatan Anda. Mari kita jelajahi fitur-fitur aplikasi Healthkon BPJS bersama-sama!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Mulai Tutorial',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk video player di tutorial
class _VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  
  const _VideoPlayerWidget({required this.videoPath});
  
  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(widget.videoPath);
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading tutorial video: $e');
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: _isVideoInitialized && _videoController != null
          ? AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
    );
  }
}

