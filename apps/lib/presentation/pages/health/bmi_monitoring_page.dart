import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
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
                return _CalculationCard(calculation: calculation);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CalculationCard extends StatelessWidget {
  final dynamic calculation;
  
  const _CalculationCard({required this.calculation});
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final result = calculation.result as Map<String, dynamic>;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(calculation.calculationType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    calculation.calculationType,
                    style: TextStyle(
                      color: _getTypeColor(calculation.calculationType),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  dateFormat.format(calculation.calculatedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResultContent(context, calculation.calculationType, result),
          ],
        ),
      ),
    );
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
    final bmi = result['bmi'] as double? ?? 0.0;
    final category = result['category'] as String? ?? '';
    final interpretation = result['interpretation'] as String? ?? '';
    
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
                color: _getBMIColor(bmi),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          category,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _getBMIColor(bmi),
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
  
  Widget _buildBMRResult(BuildContext context, Map<String, dynamic> result) {
    final bmr = result['bmr'] as double? ?? 0.0;
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
                color: AppTheme.buttonGreen,
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
  
  Widget _buildTDEEResult(BuildContext context, Map<String, dynamic> result) {
    final tdee = result['tdee'] as double? ?? 0.0;
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
                color: AppTheme.buttonGreen,
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
  
  Widget _buildGenericResult(BuildContext context, Map<String, dynamic> result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: result.entries.map((entry) {
        if (entry.key == 'interpretation') {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              entry.value.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
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
      }).toList(),
    );
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
}


