import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// Waist to Height Ratio Calculator Page
class WaistToHeightCalculatorPage extends StatefulWidget {
  const WaistToHeightCalculatorPage({super.key});
  
  @override
  State<WaistToHeightCalculatorPage> createState() => _WaistToHeightCalculatorPageState();
}

class _WaistToHeightCalculatorPageState extends State<WaistToHeightCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _waistController = TextEditingController();
  final _heightController = TextEditingController();
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _waistController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final waist = double.parse(_waistController.text);
      final height = double.parse(_heightController.text);
      
      final result = HealthCalculatorService.calculateWaistToHeightRatio(waist, height);
      
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
      "waist_cm": double.parse(_waistController.text),
      "height_cm": double.parse(_heightController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "WaistToHeight",
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
    final wthrColor = Colors.indigo;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator Waist to Height Ratio',
                subtitle: 'Rasio Pinggang ke Tinggi',
                color: wthrColor,
                icon: Icons.straighten,
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
                      color: wthrColor,
                      children: [
                        TextFormField(
                          controller: _waistController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Lingkar Pinggang (cm)',
                            prefixIcon: const Icon(Icons.straighten),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan lingkar pinggang';
                            final waist = double.tryParse(value);
                            if (waist == null || waist <= 0) return 'Lingkar pinggang harus lebih dari 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Tinggi Badan (cm)',
                            prefixIcon: const Icon(Icons.height),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan tinggi badan';
                            final height = double.tryParse(value);
                            if (height == null || height <= 0) return 'Tinggi badan harus lebih dari 0';
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
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung WtHR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: wthrColor,
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
                        color: wthrColor,
                        content: Column(
                          children: [
                            Text(
                              'WtHR',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result!['waist_to_height_ratio'] ?? '0',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: wthrColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: wthrColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Risk: ${_result!['risk_level']}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: wthrColor,
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
                            calculationType: 'WaistToHeight',
                            result: _result!,
                            color: wthrColor,
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
                            title: 'Waist to Hip',
                            icon: Icons.straighten,
                            color: Colors.teal,
                            route: '/calculator/waist-to-hip',
                          ),
                          RelatedCalculator(
                            title: 'BMI',
                            icon: Icons.monitor_weight,
                            color: AppTheme.buttonGreen,
                            route: '/calculator/bmi',
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
