import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// Body Surface Area Calculator Page
class BodySurfaceCalculatorPage extends StatefulWidget {
  const BodySurfaceCalculatorPage({super.key});
  
  @override
  State<BodySurfaceCalculatorPage> createState() => _BodySurfaceCalculatorPageState();
}

class _BodySurfaceCalculatorPageState extends State<BodySurfaceCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      
      final result = HealthCalculatorService.calculateBodySurfaceArea(weight, height);
      
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
      "height_cm": double.parse(_heightController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "BodySurfaceArea",
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
    final bsaColor = Colors.cyan;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator Body Surface Area',
                subtitle: 'Luas Permukaan Tubuh',
                color: bsaColor,
                icon: Icons.square_foot,
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
                      color: bsaColor,
                      children: [
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Berat Badan (kg)',
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
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung BSA'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bsaColor,
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
                        color: bsaColor,
                        content: Column(
                          children: [
                            Text(
                              'BSA',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_result!['body_surface_area']} ${_result!['unit']}',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: bsaColor,
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
                            calculationType: 'BodySurfaceArea',
                            result: _result!,
                            color: bsaColor,
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

