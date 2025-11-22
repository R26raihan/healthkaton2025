import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// One Rep Max Calculator Page
class OneRepMaxCalculatorPage extends StatefulWidget {
  const OneRepMaxCalculatorPage({super.key});
  
  @override
  State<OneRepMaxCalculatorPage> createState() => _OneRepMaxCalculatorPageState();
}

class _OneRepMaxCalculatorPageState extends State<OneRepMaxCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final weight = double.parse(_weightController.text);
      final reps = int.parse(_repsController.text);
      
      final result = HealthCalculatorService.calculateOneRepMax(weight, reps);
      
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
      "weight": double.parse(_weightController.text),
      "reps": int.parse(_repsController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "OneRepMax",
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
    final oneRepMaxColor = Colors.deepPurple;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator One Rep Max',
                subtitle: 'Kekuatan Maksimal Satu Repetisi',
                color: oneRepMaxColor,
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
                      color: oneRepMaxColor,
                      children: [
                        TextFormField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Berat yang Diangkat (kg)',
                            hintText: 'Contoh: 50',
                            prefixIcon: const Icon(Icons.fitness_center),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan berat';
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0) return 'Berat harus lebih dari 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Repetisi',
                            hintText: 'Contoh: 10',
                            prefixIcon: const Icon(Icons.repeat),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                            helperText: 'Jumlah repetisi maksimal yang bisa dilakukan',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan jumlah repetisi';
                            final reps = int.tryParse(value);
                            if (reps == null || reps <= 0 || reps > 30) return 'Repetisi harus 1-30';
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
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung 1RM'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: oneRepMaxColor,
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
                        color: oneRepMaxColor,
                        content: Column(
                          children: [
                            Text(
                              'One Rep Max',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_result!['one_rep_max']} ${_result!['unit']}',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: oneRepMaxColor,
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
                            calculationType: 'OneRepMax',
                            result: _result!,
                            color: oneRepMaxColor,
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

