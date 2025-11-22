import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:apps/core/services/health_calculator_service.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/widgets/calculator_base_widget.dart';

/// Body Fat Calculator Page
class BodyFatCalculatorPage extends StatefulWidget {
  const BodyFatCalculatorPage({super.key});
  
  @override
  State<BodyFatCalculatorPage> createState() => _BodyFatCalculatorPageState();
}

class _BodyFatCalculatorPageState extends State<BodyFatCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _waistController = TextEditingController();
  final _neckController = TextEditingController();
  final _hipController = TextEditingController();
  String _gender = 'male';
  
  Map<String, dynamic>? _result;
  bool _isCalculating = false;
  
  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _waistController.dispose();
    _neckController.dispose();
    _hipController.dispose();
    super.dispose();
  }
  
  void _calculate() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isCalculating = true;
      });
      
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final age = int.parse(_ageController.text);
      final waist = double.parse(_waistController.text);
      final neck = double.parse(_neckController.text);
      final hip = _gender == 'female' ? double.tryParse(_hipController.text) : null;
      
      // Hitung manual di Dart
      final result = HealthCalculatorService.calculateBodyFatPercentage(
        weightKg: weight,
        heightCm: height,
        age: age,
        gender: _gender,
        waistCm: waist,
        neckCm: neck,
        hipCm: hip,
      );
      
      setState(() {
        _result = result;
        _isCalculating = false;
      });
    }
  }
  
  Future<void> _saveResult() async {
    if (_result == null || _result!.containsKey('error')) return;
    
    final provider = context.read<HealthCalculatorProvider>();
    
    final inputData = {
      "weight_kg": double.parse(_weightController.text),
      "height_cm": double.parse(_heightController.text),
      "age": int.parse(_ageController.text),
      "gender": _gender,
      "waist_cm": double.parse(_waistController.text),
      "neck_cm": double.parse(_neckController.text),
      if (_gender == 'female') "hip_cm": double.parse(_hipController.text),
    };
    
    final success = await provider.saveCalculation(
      calculationType: "BodyFat",
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
    final bodyFatColor = Colors.purple;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CalculatorBaseWidget.buildHeader(
                context: context,
                title: 'Kalkulator Body Fat',
                subtitle: 'Persentase Lemak Tubuh',
                color: bodyFatColor,
                icon: Icons.person,
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
                      color: bodyFatColor,
                      children: [
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(
                            labelText: 'Jenis Kelamin',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Usia (tahun)',
                            prefixIcon: const Icon(Icons.calendar_today),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan usia';
                            final age = int.tryParse(value);
                            if (age == null || age <= 0 || age > 120) return 'Usia harus antara 1-120 tahun';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
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
                          controller: _neckController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Lingkar Leher (cm)',
                            prefixIcon: const Icon(Icons.straighten),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Masukkan lingkar leher';
                            final neck = double.tryParse(value);
                            if (neck == null || neck <= 0) return 'Lingkar leher harus lebih dari 0';
                            return null;
                          },
                        ),
                        if (_gender == 'female') ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _hipController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Lingkar Pinggul (cm) *',
                              prefixIcon: const Icon(Icons.straighten),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              helperText: 'Wajib untuk perempuan',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Masukkan lingkar pinggul';
                              final hip = double.tryParse(value);
                              if (hip == null || hip <= 0) return 'Lingkar pinggul harus lebih dari 0';
                              return null;
                            },
                          ),
                        ],
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
                            label: Text(_isCalculating ? 'Menghitung...' : 'Hitung Body Fat'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bodyFatColor,
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
                        title: _result!.containsKey('error') ? 'Error' : 'Hasil Perhitungan',
                        color: _result!.containsKey('error') ? Colors.red : bodyFatColor,
                        content: _result!.containsKey('error')
                            ? Text(
                                _result!['error'],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.red,
                                ),
                              )
                            : Column(
                                children: [
                                  Text(
                                    'Body Fat',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_result!['body_fat_percentage']} ${_result!['unit']}',
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: bodyFatColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: bodyFatColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _result!['category'] ?? '',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: bodyFatColor,
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
                        actions: _result!.containsKey('error')
                            ? []
                            : [
                                CalculatorBaseWidget.buildAIExplanationButton(
                                  context: context,
                                  calculationType: 'BodyFat',
                                  result: _result!,
                                  color: bodyFatColor,
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
                      if (!_result!.containsKey('error')) ...[
                        const SizedBox(height: 20),
                        CalculatorBaseWidget.buildRelatedCalculators(
                          context: context,
                          calculators: [
                            RelatedCalculator(
                              title: 'BMI',
                              icon: Icons.monitor_weight,
                              color: AppTheme.buttonGreen,
                              route: '/calculator/bmi',
                            ),
                            RelatedCalculator(
                              title: 'Body Water',
                              icon: Icons.water_drop,
                              color: Colors.lightBlue,
                              route: '/calculator/body-water',
                            ),
                            RelatedCalculator(
                              title: 'Waist to Hip',
                              icon: Icons.straighten,
                              color: Colors.teal,
                              route: '/calculator/waist-to-hip',
                            ),
                          ],
                        ),
                      ],
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

