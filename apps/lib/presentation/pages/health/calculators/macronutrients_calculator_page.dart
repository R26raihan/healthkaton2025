import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';

/// Macronutrients Calculator Page
class MacronutrientsCalculatorPage extends StatefulWidget {
  const MacronutrientsCalculatorPage({super.key});
  
  @override
  State<MacronutrientsCalculatorPage> createState() => _MacronutrientsCalculatorPageState();
}

class _MacronutrientsCalculatorPageState extends State<MacronutrientsCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '30');
  final _carbController = TextEditingController(text: '40');
  final _fatController = TextEditingController(text: '30');
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final calories = double.parse(_caloriesController.text);
      final proteinPercent = double.parse(_proteinController.text);
      final carbPercent = double.parse(_carbController.text);
      final fatPercent = double.parse(_fatController.text);
      
      final result = HealthCalculatorService.calculateMacronutrients(
        calories,
        proteinPercent,
        carbPercent,
        fatPercent,
      );
      
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
      "calories": double.parse(_caloriesController.text),
      "protein_percent": double.parse(_proteinController.text),
      "carb_percent": double.parse(_carbController.text),
      "fat_percent": double.parse(_fatController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "Macronutrients",
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Macronutrients'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masukkan Data',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total Kalori (kcal)',
                          hintText: 'Contoh: 2000',
                          prefixIcon: Icon(Icons.local_fire_department),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan total kalori';
                          final calories = double.tryParse(value);
                          if (calories == null || calories <= 0) return 'Kalori harus lebih dari 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protein (%)',
                          hintText: '30',
                          prefixIcon: Icon(Icons.restaurant),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan persentase protein';
                          final protein = double.tryParse(value);
                          if (protein == null || protein < 0 || protein > 100) return 'Protein harus 0-100%';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _carbController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Karbohidrat (%)',
                          hintText: '40',
                          prefixIcon: Icon(Icons.restaurant),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan persentase karbohidrat';
                          final carb = double.tryParse(value);
                          if (carb == null || carb < 0 || carb > 100) return 'Karbohidrat harus 0-100%';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lemak (%)',
                          hintText: '30',
                          prefixIcon: Icon(Icons.restaurant),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan persentase lemak';
                          final fat = double.tryParse(value);
                          if (fat == null || fat < 0 || fat > 100) return 'Lemak harus 0-100%';
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.calculate),
                          label: Text(_isCalculating ? 'Menghitung...' : 'Hitung Macronutrients'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_result != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: Colors.green.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil Perhitungan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildMacroCard(
                          context,
                          'Protein',
                          _result!['protein'] as Map<String, dynamic>,
                          Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildMacroCard(
                          context,
                          'Karbohidrat',
                          _result!['carbohydrates'] as Map<String, dynamic>,
                          Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        _buildMacroCard(
                          context,
                          'Lemak',
                          _result!['fat'] as Map<String, dynamic>,
                          Colors.red,
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _result!['interpretation'] ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMacroCard(BuildContext context, String name, Map<String, dynamic> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data['grams']}g',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${data['calories']} kcal (${data['percent']}%)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

