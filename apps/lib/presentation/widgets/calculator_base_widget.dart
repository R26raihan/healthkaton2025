import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';

/// Base widget untuk calculator pages dengan design yang konsisten
class CalculatorBaseWidget {
  /// Build header dengan gradient dan icon
  static Widget buildHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build input card dengan design modern
  static Widget buildInputCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  /// Build result card dengan design modern
  static Widget buildResultCard({
    required BuildContext context,
    required String title,
    required Widget content,
    required Color color,
    required List<Widget> actions,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.calculate,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              content,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 20),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build related calculators section
  static Widget buildRelatedCalculators({
    required BuildContext context,
    required List<RelatedCalculator> calculators,
  }) {
    if (calculators.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.link,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kalkulator Terkait',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: calculators.map((calc) {
                return InkWell(
                  onTap: () => Navigator.of(context).pushNamed(calc.route),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          calc.color.withOpacity(0.1),
                          calc.color.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: calc.color.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          calc.icon,
                          color: calc.color,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          calc.title,
                          style: TextStyle(
                            color: calc.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: calc.color,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build AI explanation button
  static Widget buildAIExplanationButton({
    required BuildContext context,
    required String calculationType,
    required Map<String, dynamic> result,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: () => _showAIExplanation(context, calculationType, result, color),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.purple.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.blue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tanya AI tentang perhitungan ini',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show AI explanation bottom sheet
  static void _showAIExplanation(
    BuildContext context,
    String calculationType,
    Map<String, dynamic> result,
    Color color,
  ) {
    // Build query berdasarkan tipe perhitungan
    String query = _buildAIQuery(calculationType, result);

    // Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AIExplanationBottomSheet(
        calculationType: calculationType,
        result: result,
        initialQuery: query,
        color: color,
      ),
    );
  }

  /// Build AI query berdasarkan tipe perhitungan
  static String _buildAIQuery(String type, Map<String, dynamic> result) {
    switch (type) {
      case 'BMI':
        final bmi = result['bmi'] ?? 0;
        final category = result['category'] ?? '';
        return 'Jelaskan hasil BMI saya yang bernilai $bmi dengan kategori $category. Berikan penjelasan lengkap tentang artinya dan rekomendasi yang bisa saya lakukan.';
      
      case 'BMR':
        final bmr = result['bmr'] ?? 0;
        final unit = result['unit'] ?? '';
        return 'Jelaskan tentang BMR (Basal Metabolic Rate) saya yang bernilai $bmr $unit. Berikan penjelasan lengkap tentang artinya dan bagaimana cara menggunakannya untuk kesehatan saya.';
      
      case 'TDEE':
        final tdee = result['tdee'] ?? 0;
        final unit = result['unit'] ?? '';
        return 'Jelaskan tentang TDEE (Total Daily Energy Expenditure) saya yang bernilai $tdee $unit. Berikan penjelasan lengkap tentang artinya dan bagaimana cara menggunakannya untuk diet dan kesehatan saya.';
      
      case 'BodyFat':
        final bodyFat = result['body_fat_percentage'] ?? 0;
        final category = result['category'] ?? '';
        return 'Jelaskan hasil Body Fat saya yang bernilai $bodyFat% dengan kategori $category. Berikan penjelasan lengkap tentang artinya dan rekomendasi yang bisa saya lakukan.';
      
      case 'IdealBodyWeight':
        final idealWeight = result['ideal_body_weight'] ?? 0;
        final unit = result['unit'] ?? '';
        return 'Jelaskan tentang Ideal Body Weight saya yang bernilai $idealWeight $unit. Berikan penjelasan lengkap tentang artinya dan bagaimana cara mencapainya.';
      
      case 'DailyCalories':
        final calories = result['daily_calories'] ?? 0;
        final goal = result['goal'] ?? '';
        return 'Jelaskan tentang kebutuhan kalori harian saya yang bernilai $calories untuk tujuan $goal. Berikan penjelasan lengkap tentang artinya dan tips untuk mencapainya.';
      
      case 'BodyWater':
        final bodyWater = result['body_water_percentage'] ?? 0;
        final waterWeight = result['water_weight_kg'] ?? 0;
        return 'Jelaskan tentang Body Water saya yang bernilai $bodyWater% dengan berat air $waterWeight kg. Berikan penjelasan lengkap tentang artinya dan tips untuk menjaga hidrasi.';
      
      case 'Macronutrients':
        final protein = result['protein']?['grams'] ?? 0;
        final carb = result['carbohydrates']?['grams'] ?? 0;
        final fat = result['fat']?['grams'] ?? 0;
        return 'Jelaskan tentang kebutuhan makronutrien saya: Protein $protein g, Karbohidrat $carb g, Lemak $fat g. Berikan penjelasan lengkap tentang artinya dan tips untuk mencapainya.';
      
      case 'MaxHeartRate':
        final mhr = result['max_heart_rate'] ?? 0;
        return 'Jelaskan tentang Max Heart Rate saya yang bernilai $mhr bpm. Berikan penjelasan lengkap tentang artinya dan bagaimana cara menggunakannya untuk latihan.';
      
      case 'TargetHeartRate':
        final zone = result['target_heart_rate_zone'] as Map<String, dynamic>?;
        final min = zone?['min'] ?? 0;
        final max = zone?['max'] ?? 0;
        return 'Jelaskan tentang Target Heart Rate Zone saya yang berada di rentang $min-$max bpm. Berikan penjelasan lengkap tentang artinya dan bagaimana cara menggunakannya untuk latihan.';
      
      case 'WaterNeeds':
        final water = result['daily_water_needs'] ?? 0;
        return 'Jelaskan tentang kebutuhan air harian saya yang bernilai $water liter. Berikan penjelasan lengkap tentang artinya dan tips untuk memenuhi kebutuhan hidrasi.';
      
      default:
        return 'Jelaskan hasil perhitungan $type saya. Berikan penjelasan lengkap tentang artinya dan rekomendasi yang bisa saya lakukan.';
    }
  }
}

/// Related calculator model
class RelatedCalculator {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const RelatedCalculator({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// AI Explanation Bottom Sheet
class _AIExplanationBottomSheet extends StatefulWidget {
  final String calculationType;
  final Map<String, dynamic> result;
  final String initialQuery;
  final Color color;

  const _AIExplanationBottomSheet({
    required this.calculationType,
    required this.result,
    required this.initialQuery,
    required this.color,
  });

  @override
  State<_AIExplanationBottomSheet> createState() => _AIExplanationBottomSheetState();
}

class _AIExplanationBottomSheetState extends State<_AIExplanationBottomSheet> {
  bool _hasQueried = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasQueried && mounted) {
        _queryAI();
      }
    });
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
      debugPrint('Error loading video: $e');
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _queryAI() async {
    if (_hasQueried) return;
    _hasQueried = true;
    final ragProvider = context.read<RagChatProvider>();
    ragProvider.clearChat();
    await ragProvider.sendMessage(widget.initialQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _isVideoInitialized && _videoController != null
                        ? SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.white.withOpacity(0.1),
                            child: Center(
                              child: Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penjelasan AI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.calculationType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<RagChatProvider>(
              builder: (context, ragProvider, child) {
                if (ragProvider.isLoading && ragProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'AI sedang menganalisis data Anda...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (ragProvider.errorMessage != null && ragProvider.messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Terjadi kesalahan',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ragProvider.errorMessage ?? 'Terjadi kesalahan',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _hasQueried = false;
                              _queryAI();
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: widget.color,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ringkasan Hasil',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: widget.color,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...widget.result.entries.map((entry) {
                              if (entry.key == 'interpretation') return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        '${entry.key}: ',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        entry.value.toString(),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (ragProvider.messages.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Penjelasan AI',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ragProvider.messages.lastWhere(
                                  (msg) => !msg.isUser,
                                  orElse: () => ragProvider.messages.first,
                                ).message,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[800],
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (ragProvider.isLoading)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'AI sedang memproses...',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

