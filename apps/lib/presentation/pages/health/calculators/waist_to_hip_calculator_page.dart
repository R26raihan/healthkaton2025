import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// Waist to Hip Ratio Calculator Page
class WaistToHipCalculatorPage extends StatefulWidget {
  const WaistToHipCalculatorPage({super.key});
  
  @override
  State<WaistToHipCalculatorPage> createState() => _WaistToHipCalculatorPageState();
}

class _WaistToHipCalculatorPageState extends State<WaistToHipCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _waistController.dispose();
    _hipController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final waist = double.parse(_waistController.text);
      final hip = double.parse(_hipController.text);
      
      final result = HealthCalculatorService.calculateWaistToHipRatio(waist, hip);
      
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
      "hip_cm": double.parse(_hipController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "WaistToHip",
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
    final whrColor = Colors.teal;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator Waist to Hip Ratio',
                subtitle: 'Rasio Pinggang ke Pinggul',
                color: whrColor,
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
                      color: whrColor,
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
                          controller: _hipController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Lingkar Pinggul (cm)',
                            prefixIcon: const Icon(Icons.straighten),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan lingkar pinggul';
                            final hip = double.tryParse(value);
                            if (hip == null || hip <= 0) return 'Lingkar pinggul harus lebih dari 0';
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
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung WHR'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: whrColor,
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
                        color: whrColor,
                        content: Column(
                          children: [
                            Text(
                              'WHR',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _result!['waist_to_hip_ratio'] ?? '0',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: whrColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: whrColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Risk: ${_result!['risk_level']}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: whrColor,
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
                            calculationType: 'WaistToHip',
                            result: _result!,
                            color: whrColor,
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
                            title: 'Waist to Height',
                            icon: Icons.straighten,
                            color: Colors.indigo,
                            route: '/calculator/waist-to-height',
                          ),
                          RelatedCalculator(
                            title: 'Body Fat',
                            icon: Icons.person,
                            color: Colors.purple,
                            route: '/calculator/body-fat',
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
