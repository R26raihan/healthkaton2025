import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';


/// TDEE Calculator Page
class TDEECalculatorPage extends StatefulWidget {
  const TDEECalculatorPage({super.key});
  
  @override
  State<TDEECalculatorPage> createState() => _TDEECalculatorPageState();
}

class _TDEECalculatorPageState extends State<TDEECalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _bmrController = TextEditingController();
  String _activityLevel = 'sedentary';
  
  final Map<String, String> _activityLevels = {
    'sedentary': 'Sedentary (Tidak aktif)',
    'light': 'Light (Ringan)',
    'moderate': 'Moderate (Sedang)',
    'active': 'Active (Aktif)',
    'very_active': 'Very Active (Sangat Aktif)',
  };
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _bmrController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final bmr = double.parse(_bmrController.text);
      
      // Hitung manual di Dart
      final result = HealthCalculatorService.calculateTDEE(bmr, _activityLevel);
      
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
      "bmr": double.parse(_bmrController.text),
      "activity_level": _activityLevel,
    };
    
    final success = await provider.saveCalculation(
      calculationType: "TDEE",
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
        Navigator.of(context).pop();
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
    final tdeeColor = Colors.orange;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator TDEE',
                subtitle: 'Total Daily Energy Expenditure',
                color: tdeeColor,
                icon: Icons.fitness_center,
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
                      color: tdeeColor,
                      children: [
                        TextFormField(
                          controller: _bmrController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'BMR (Basal Metabolic Rate)',
                            hintText: 'Contoh: 1656',
                            prefixIcon: const Icon(Icons.local_fire_department),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            helperText: 'Gunakan kalkulator BMR untuk mendapatkan nilai BMR',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan nilai BMR';
                            }
                            final bmr = double.tryParse(value);
                            if (bmr == null || bmr <= 0) {
                              return 'BMR harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _activityLevel,
                          decoration: InputDecoration(
                            labelText: 'Tingkat Aktivitas',
                            prefixIcon: const Icon(Icons.fitness_center),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: _activityLevels.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(entry.value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _activityLevel = value!;
                            });
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
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung TDEE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tdeeColor,
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
                        color: tdeeColor,
                        content: Column(
                          children: [
                            Text(
                              'TDEE',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_result!['tdee']} ${_result!['unit']}',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: tdeeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: tdeeColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Activity Level: ${_result!['activity_level']}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: tdeeColor,
                                  fontWeight: FontWeight.w600,
                                ),
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
                            calculationType: 'TDEE',
                            result: _result!,
                            color: tdeeColor,
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
                            title: 'BMR',
                            icon: Icons.local_fire_department,
                            color: Colors.blue,
                            route: '/calculator/bmr',
                          ),
                          RelatedCalculator(
                            title: 'Daily Calories',
                            icon: Icons.local_fire_department,
                            color: Colors.brown,
                            route: '/calculator/daily-calories',
                          ),
                          RelatedCalculator(
                            title: 'Macronutrients',
                            icon: Icons.restaurant,
                            color: Colors.green,
                            route: '/calculator/macronutrients',
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

