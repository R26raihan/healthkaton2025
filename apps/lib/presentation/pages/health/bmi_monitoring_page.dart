import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';
import 'package:intl/intl.dart';

/// BMI Monitoring Page - BMI & Self Monitoring
class BMIMonitoringPage extends StatefulWidget {
  static const String routeName = AppRoutes.bmiMonitoring;
  
  const BMIMonitoringPage({super.key});
  
  @override
  State<BMIMonitoringPage> createState() => _BMIMonitoringPageState();
}

class _BMIMonitoringPageState extends State<BMIMonitoringPage> {
  @override
  void initState() {
    super.initState();
    // Load calculation history when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthCalculatorProvider>().getCalculationHistory();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI & Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HealthCalculatorProvider>().getCalculationHistory();
            },
          ),
        ],
      ),
      body: Consumer<HealthCalculatorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.hasError) {
            return Center(
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
                    provider.errorMessage ?? 'Terjadi kesalahan',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.getCalculationHistory();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          if (provider.calculations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat perhitungan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mulai hitung BMI atau kesehatan lainnya',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              await provider.getCalculationHistory();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.calculations.length,
              itemBuilder: (context, index) {
                final calculation = provider.calculations[index];
                return _CalculationCard(
                  calculation: calculation,
                  onTap: () => _showAIExplanation(context, calculation),
                );
              },
            ),
          );
        },
      ),
    );
  }
  
  /// Show AI explanation bottom sheet
  void _showAIExplanation(BuildContext context, dynamic calculation) {
    final result = calculation.result as Map<String, dynamic>;
    final type = calculation.calculationType;
    
    // Build query berdasarkan tipe perhitungan
    String query = _buildAIQuery(type, result);
    
    // Show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AIExplanationBottomSheet(
        calculation: calculation,
        initialQuery: query,
      ),
    );
  }
  
  /// Build AI query berdasarkan tipe perhitungan
  String _buildAIQuery(String type, Map<String, dynamic> result) {
    switch (type) {
      case 'BMI':
        final bmi = _CalculationCard._toDouble(result['bmi']);
        final category = result['category'] as String? ?? '';
        return 'Jelaskan hasil BMI saya yang bernilai ${bmi.toStringAsFixed(2)} dengan kategori $category. Berikan penjelasan lengkap tentang artinya dan rekomendasi yang bisa saya lakukan.';
      
      case 'BMR':
        final bmr = _CalculationCard._toDouble(result['bmr']);
        final unit = result['unit'] as String? ?? '';
        return 'Jelaskan tentang BMR (Basal Metabolic Rate) saya yang bernilai ${bmr.toStringAsFixed(0)} $unit. Berikan penjelasan lengkap tentang artinya dan bagaimana cara menggunakannya untuk kesehatan saya.';
      
      case 'TDEE':
        final tdee = _CalculationCard._toDouble(result['tdee']);
        final unit = result['unit'] as String? ?? '';
        return 'Jelaskan tentang TDEE (Total Daily Energy Expenditure) saya yang bernilai ${tdee.toStringAsFixed(0)} $unit. Berikan penjelasan lengkap tentang artinya dan bagaimana cara menggunakannya untuk diet dan kesehatan saya.';
      
      default:
        return 'Jelaskan hasil perhitungan $type saya. Berikan penjelasan lengkap tentang artinya dan rekomendasi yang bisa saya lakukan.';
    }
  }
}

class _CalculationCard extends StatelessWidget {
  final dynamic calculation;
  final VoidCallback? onTap;
  
  const _CalculationCard({
    required this.calculation,
    this.onTap,
  });
  
  /// Helper function to safely convert number to double
  /// Handles both int and double types from JSON
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final result = calculation.result as Map<String, dynamic>;
    final typeColor = _getTypeColor(calculation.calculationType);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: typeColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Header dengan icon dan badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(calculation.calculationType),
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          calculation.calculationType,
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormat.format(calculation.calculatedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Divider(
                color: Colors.grey[300],
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 16),
                // Content hasil perhitungan
                _buildResultContent(context, calculation.calculationType, result),
                // AI Explanation hint
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: typeColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ketuk untuk penjelasan AI',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: typeColor.withOpacity(0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'BMI':
        return Icons.monitor_weight;
      case 'BMR':
        return Icons.local_fire_department;
      case 'TDEE':
        return Icons.fitness_center;
      default:
        return Icons.calculate;
    }
  }
  
  Widget _buildResultContent(BuildContext context, String type, Map<String, dynamic> result) {
    switch (type) {
      case 'BMI':
        return _buildBMIResult(context, result);
      case 'BMR':
        return _buildBMRResult(context, result);
      case 'TDEE':
        return _buildTDEEResult(context, result);
      default:
        return _buildGenericResult(context, result);
    }
  }
  
  Widget _buildBMIResult(BuildContext context, Map<String, dynamic> result) {
    final bmi = _toDouble(result['bmi']);
    final category = result['category'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    final bmiColor = _getBMIColor(bmi);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nilai BMI dengan background highlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bmiColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nilai BMI',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bmi.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                      fontSize: 32,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'kg/m²',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Kategori BMI
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bmiColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getBMIIcon(bmi),
                color: bmiColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                category,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: bmiColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Interpretasi
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interpretation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  IconData _getBMIIcon(double bmi) {
    if (bmi < 18.5) {
      return Icons.trending_down;
    } else if (bmi < 25) {
      return Icons.check_circle;
    } else if (bmi < 30) {
      return Icons.trending_up;
    } else {
      return Icons.warning;
    }
  }
  
  Widget _buildBMRResult(BuildContext context, Map<String, dynamic> result) {
    final bmr = _toDouble(result['bmr']);
    final unit = result['unit'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    final bmrColor = Colors.blue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nilai BMR dengan background highlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bmrColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: bmrColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basal Metabolic Rate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bmr.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: bmrColor,
                      fontSize: 32,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Interpretasi
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interpretation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildTDEEResult(BuildContext context, Map<String, dynamic> result) {
    final tdee = _toDouble(result['tdee']);
    final unit = result['unit'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    final tdeeColor = Colors.orange;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nilai TDEE dengan background highlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tdeeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: tdeeColor.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Daily Energy Expenditure',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tdee.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tdeeColor,
                      fontSize: 32,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      unit,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Interpretasi
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interpretation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildGenericResult(BuildContext context, Map<String, dynamic> result) {
    final mainEntries = result.entries.where((e) => e.key != 'interpretation').toList();
    final interpretation = result['interpretation'] as String?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main values dalam container
        if (mainEntries.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: mainEntries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formatKey(entry.key),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.toString(),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        // Interpretasi
        if (interpretation != null && interpretation.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    interpretation,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  String _formatKey(String key) {
    // Convert snake_case atau camelCase ke format yang lebih readable
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty 
            ? '' 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ')
        .trim();
  }
  
  Color _getTypeColor(String type) {
    switch (type) {
      case 'BMI':
        return AppTheme.buttonGreen;
      case 'BMR':
        return Colors.blue;
      case 'TDEE':
        return Colors.orange;
      default:
        return AppTheme.primaryGreen;
    }
  }
  
  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue; // Underweight
    } else if (bmi < 25) {
      return Colors.green; // Normal
    } else if (bmi < 30) {
      return Colors.orange; // Overweight
    } else {
      return Colors.red; // Obese
    }
  }
  
  // Static methods untuk digunakan di bottom sheet
  static Color _getTypeColorStatic(String type) {
    switch (type) {
      case 'BMI':
        return AppTheme.buttonGreen;
      case 'BMR':
        return Colors.blue;
      case 'TDEE':
        return Colors.orange;
      default:
        return AppTheme.primaryGreen;
    }
  }
  
  static IconData _getTypeIconStatic(String type) {
    switch (type) {
      case 'BMI':
        return Icons.monitor_weight;
      case 'BMR':
        return Icons.local_fire_department;
      case 'TDEE':
        return Icons.fitness_center;
      default:
        return Icons.calculate;
    }
  }
  
  static Widget _buildResultContentStatic(BuildContext context, String type, Map<String, dynamic> result) {
    switch (type) {
      case 'BMI':
        return _buildBMIResultStatic(context, result);
      case 'BMR':
        return _buildBMRResultStatic(context, result);
      case 'TDEE':
        return _buildTDEEResultStatic(context, result);
      default:
        return _buildGenericResultStatic(context, result);
    }
  }
  
  static Widget _buildBMIResultStatic(BuildContext context, Map<String, dynamic> result) {
    final bmi = _toDouble(result['bmi']);
    final category = result['category'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    final bmiColor = _getBMIColorStatic(bmi);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'BMI: ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              bmi.toStringAsFixed(2),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: bmiColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          category,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: bmiColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            interpretation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
  
  static Widget _buildBMRResultStatic(BuildContext context, Map<String, dynamic> result) {
    final bmr = _toDouble(result['bmr']);
    final unit = result['unit'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'BMR: ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${bmr.toStringAsFixed(0)} $unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            interpretation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
  
  static Widget _buildTDEEResultStatic(BuildContext context, Map<String, dynamic> result) {
    final tdee = _toDouble(result['tdee']);
    final unit = result['unit'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TDEE: ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${tdee.toStringAsFixed(0)} $unit',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        if (interpretation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            interpretation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
  
  static Widget _buildGenericResultStatic(BuildContext context, Map<String, dynamic> result) {
    final mainEntries = result.entries.where((e) => e.key != 'interpretation').toList();
    final interpretation = result['interpretation'] as String?;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...mainEntries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  '${entry.key}: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  entry.value.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }),
        if (interpretation != null && interpretation.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            interpretation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
  
  static Color _getBMIColorStatic(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// Bottom Sheet untuk menampilkan penjelasan AI
class _AIExplanationBottomSheet extends StatefulWidget {
  final dynamic calculation;
  final String initialQuery;
  
  const _AIExplanationBottomSheet({
    required this.calculation,
    required this.initialQuery,
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
    // Initialize video
    _initializeVideo();
    // Auto query saat bottom sheet dibuka
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
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
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
    final result = widget.calculation.result as Map<String, dynamic>;
    final typeColor = _CalculationCard._getTypeColorStatic(widget.calculation.calculationType);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header dengan gradient
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
                // Video Player sebagai icon animasi
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
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
                        widget.calculation.calculationType,
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
          // Content
          Expanded(
            child: Consumer<RagChatProvider>(
              builder: (context, ragProvider, child) {
                if (ragProvider.isLoading && ragProvider.messages.isEmpty) {
                  return _buildLoadingState();
                }
                
                if (ragProvider.errorMessage != null && ragProvider.messages.isEmpty) {
                  return _buildErrorState(ragProvider.errorMessage ?? 'Terjadi kesalahan');
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary card
                      _buildSummaryCard(context, widget.calculation, result, typeColor),
                      const SizedBox(height: 20),
                      // AI Explanation
                      if (ragProvider.messages.isNotEmpty)
                        _buildAIResponse(context, ragProvider),
                      if (ragProvider.isLoading)
                        _buildLoadingIndicator(),
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
  
  Widget _buildLoadingState() {
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
  
  Widget _buildErrorState(String error) {
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
              error,
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
  
  Widget _buildSummaryCard(BuildContext context, dynamic calculation, Map<String, dynamic> result, Color typeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _CalculationCard._getTypeIconStatic(calculation.calculationType),
                color: typeColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Hasil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: typeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CalculationCard._buildResultContentStatic(context, calculation.calculationType, result),
        ],
      ),
    );
  }
  
  Widget _buildAIResponse(BuildContext context, RagChatProvider ragProvider) {
    final aiMessage = ragProvider.messages.lastWhere(
      (msg) => !msg.isUser,
      orElse: () => ragProvider.messages.first,
    );
    
    return Container(
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
            aiMessage.message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[800],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Padding(
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
    );
  }
}


