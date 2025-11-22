import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// Calories Burned Calculator Page
class CaloriesBurnedCalculatorPage extends StatefulWidget {
  const CaloriesBurnedCalculatorPage({super.key});
  
  @override
  State<CaloriesBurnedCalculatorPage> createState() => _CaloriesBurnedCalculatorPageState();
}

class _CaloriesBurnedCalculatorPageState extends State<CaloriesBurnedCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();
  final _metController = TextEditingController();
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _weightController.dispose();
    _durationController.dispose();
    _metController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final weight = double.parse(_weightController.text);
      final duration = double.parse(_durationController.text);
      final met = double.parse(_metController.text);
      
      final result = HealthCalculatorService.calculateCaloriesBurned(weight, duration, met);
      
      setState(() {
        _result = result;
        _isCalculating = false;
      });
    }
  }
  
  Future<void> _saveResult() async {
    if (_result == null) return;
    
    final provider = context.read<HealthCalculatorProvider>();
    
    final inputData = {
      "weight_kg": double.parse(_weightController.text),
      "duration_minutes": double.parse(_durationController.text),
      "activity_met": double.parse(_metController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "CaloriesBurned",
      inputData: inputData,
      resultData: _result!,
    );
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hasil perhitungan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Gagal menyimpan hasil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final caloriesBurnedColor = Colors.orange;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator Calories Burned',
                subtitle: 'Kalori yang Terbakar',
                color: caloriesBurnedColor,
                icon: Icons.local_fire_department,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorBaseWidget.buildInputCard(
                      context: context,
                      title: 'Masukkan Data',
                      color: caloriesBurnedColor,
                      children: [
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Berat Badan (kg)',
                            hintText: 'Contoh: 70',
                            prefixIcon: const Icon(Icons.monitor_weight),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan berat badan';
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) return 'Berat badan harus lebih dari 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Durasi Latihan (menit)',
                            hintText: 'Contoh: 30',
                            prefixIcon: const Icon(Icons.timer),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan durasi';
                            final duration = double.tryParse(value);
                            if (duration == null || duration <= 0) return 'Durasi harus lebih dari 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _metController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'MET Value',
                            hintText: 'Contoh: 3.5 (jalan), 8.0 (lari)',
                            prefixIcon: const Icon(Icons.speed),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            helperText: 'MET (Metabolic Equivalent) - intensitas aktivitas',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan MET value';
                            final met = double.tryParse(value);
                            if (met == null || met <= 0) return 'MET harus lebih dari 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isCalculating ? null : _calculate,
                            icon: _isCalculating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.calculate),
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung Calories Burned'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: caloriesBurnedColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_result != null) ...[
                      const SizedBox(height: 20),
                      CalculatorBaseWidget.buildResultCard(
                        context: context,
                        title: 'Hasil Perhitungan',
                        color: caloriesBurnedColor,
                        content: Column(
                          children: [
                            Text(
                              'Calories Burned',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_result!['calories_burned']} ${_result!['unit']}',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: caloriesBurnedColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _result!['interpretation'] ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          CalculatorBaseWidget.buildAIExplanationButton(
                            context: context,
                            calculationType: 'CaloriesBurned',
                            result: _result!,
                            color: caloriesBurnedColor,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final shouldSave = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Simpan Hasil?'),
                                    content: const Text(
                                      'Apakah Anda ingin menyimpan hasil perhitungan ini ke riwayat?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Simpan'),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (shouldSave == true) {
                                  await _saveResult();
                                }
                              },
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan Hasil'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      CalculatorBaseWidget.buildRelatedCalculators(
                        context: context,
                        calculators: [
                          RelatedCalculator(
                            title: 'TDEE',
                            icon: Icons.fitness_center,
                            color: Colors.orange,
                            route: '/calculator/tdee',
                          ),
                          RelatedCalculator(
                            title: 'Daily Calories',
                            icon: Icons.local_fire_department,
                            color: Colors.brown,
                            route: '/calculator/daily-calories',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

