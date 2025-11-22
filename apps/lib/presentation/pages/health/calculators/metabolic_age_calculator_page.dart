import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// Metabolic Age Calculator Page
class MetabolicAgeCalculatorPage extends StatefulWidget {
  const MetabolicAgeCalculatorPage({super.key});
  
  @override
  State<MetabolicAgeCalculatorPage> createState() => _MetabolicAgeCalculatorPageState();
}

class _MetabolicAgeCalculatorPageState extends State<MetabolicAgeCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _bmrController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'male';
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _bmrController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final bmr = double.parse(_bmrController.text);
      final age = int.parse(_ageController.text);
      
      final result = HealthCalculatorService.calculateMetabolicAge(bmr, age, _gender);
      
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
      "age": int.parse(_ageController.text),
      "gender": _gender,
    };
    
    final success = await provider.saveCalculation(
      calculationType: "MetabolicAge",
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
        title: const Text('Kalkulator Metabolic Age'),
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
                        controller: _bmrController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'BMR (Basal Metabolic Rate)',
                          hintText: 'Contoh: 1656',
                          prefixIcon: Icon(Icons.local_fire_department),
                          border: OutlineInputBorder(),
                          helperText: 'Gunakan kalkulator BMR untuk mendapatkan nilai BMR',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan nilai BMR';
                          final bmr = double.tryParse(value);
                          if (bmr == null || bmr <= 0) return 'BMR harus lebih dari 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Usia Aktual (tahun)',
                          hintText: 'Contoh: 25',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Masukkan usia';
                          final age = int.tryParse(value);
                          if (age == null || age <= 0 || age > 120) return 'Usia harus antara 1-120 tahun';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Kelamin',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                          DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _gender = value!;
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.calculate),
                          label: Text(_isCalculating ? 'Menghitung...' : 'Hitung Metabolic Age'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
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
                  color: Colors.amber.withOpacity(0.1),
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
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Metabolic Age',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_result!['metabolic_age']} tahun',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Actual Age: ${_result!['actual_age']} tahun',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_result!['status']),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Status: ${_result!['status']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'younger':
        return Colors.green;
      case 'older':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}

