import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';

/// Health Calculator Menu Page - Menu untuk memilih jenis kalkulator
class HealthCalculatorMenuPage extends StatelessWidget {
  static const String routeName = AppRoutes.healthCalculator;
  
  const HealthCalculatorMenuPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Kesehatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalkulator Kesehatan',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hitung berbagai parameter kesehatan Anda',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Kesehatan Tubuh Umum
            _buildSectionTitle(context, '🩺 Kesehatan Tubuh Umum'),
            const SizedBox(height: 12),
            _buildCalculatorGrid(
              context,
              [
                _CalculatorItem(
                  title: 'BMI',
                  icon: Bootstrap.speedometer2,
                  color: AppTheme.buttonGreen,
                  route: '/calculator/bmi',
                  calculationType: 'BMI',
                ),
                _CalculatorItem(
                  title: 'BMR',
                  icon: Bootstrap.fire,
                  color: Colors.blue,
                  route: '/calculator/bmr',
                ),
                _CalculatorItem(
                  title: 'TDEE',
                  icon: Bootstrap.activity,
                  color: Colors.orange,
                  route: '/calculator/tdee',
                ),
                _CalculatorItem(
                  title: 'Body Fat',
                  icon: Bootstrap.person,
                  color: Colors.purple,
                  route: '/calculator/body-fat',
                ),
                _CalculatorItem(
                  title: 'Waist to Hip',
                  icon: Bootstrap.rulers,
                  color: Colors.teal,
                  route: '/calculator/waist-to-hip',
                ),
                _CalculatorItem(
                  title: 'Waist to Height',
                  icon: Bootstrap.rulers,
                  color: Colors.indigo,
                  route: '/calculator/waist-to-height',
                ),
                _CalculatorItem(
                  title: 'Ideal Weight',
                  icon: Bootstrap.rulers,
                  color: Colors.pink,
                  route: '/calculator/ideal-weight',
                ),
                _CalculatorItem(
                  title: 'Body Surface',
                  icon: Bootstrap.bounding_box,
                  color: Colors.cyan,
                  route: '/calculator/body-surface',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Kesehatan Jantung & Metabolisme
            _buildSectionTitle(context, '❤️ Kesehatan Jantung & Metabolisme'),
            const SizedBox(height: 12),
            _buildCalculatorGrid(
              context,
              [
                _CalculatorItem(
                  title: 'Max Heart Rate',
                  icon: Bootstrap.heart_pulse,
                  color: Colors.red,
                  route: '/calculator/max-heart-rate',
                ),
                _CalculatorItem(
                  title: 'Target Heart Rate',
                  icon: Bootstrap.heart,
                  color: Colors.redAccent,
                  route: '/calculator/target-heart-rate',
                ),
                _CalculatorItem(
                  title: 'MAP',
                  icon: Bootstrap.droplet,
                  color: Colors.deepOrange,
                  route: '/calculator/map',
                ),
                _CalculatorItem(
                  title: 'Metabolic Age',
                  icon: Bootstrap.calendar,
                  color: Colors.amber,
                  route: '/calculator/metabolic-age',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Nutrisi & Gizi
            _buildSectionTitle(context, '🍎 Nutrisi & Gizi'),
            const SizedBox(height: 12),
            _buildCalculatorGrid(
              context,
              [
                _CalculatorItem(
                  title: 'Daily Calories',
                  icon: Bootstrap.cup_hot,
                  color: Colors.brown,
                  route: '/calculator/daily-calories',
                ),
                _CalculatorItem(
                  title: 'Macronutrients',
                  icon: Bootstrap.egg_fried,
                  color: Colors.green,
                  route: '/calculator/macronutrients',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Kebugaran & Latihan
            _buildSectionTitle(context, '🏋️ Kebugaran & Latihan'),
            const SizedBox(height: 12),
            _buildCalculatorGrid(
              context,
              [
                _CalculatorItem(
                  title: 'One Rep Max',
                  icon: Bootstrap.trophy,
                  color: Colors.deepPurple,
                  route: '/calculator/one-rep-max',
                ),
                _CalculatorItem(
                  title: 'Calories Burned',
                  icon: Bootstrap.fire,
                  color: Colors.orange,
                  route: '/calculator/calories-burned',
                ),
                _CalculatorItem(
                  title: 'VO2 Max',
                  icon: Bootstrap.wind,
                  color: Colors.blue,
                  route: '/calculator/vo2-max',
                ),
                _CalculatorItem(
                  title: 'Recovery Time',
                  icon: Bootstrap.clock,
                  color: Colors.grey,
                  route: '/calculator/recovery-time',
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Cairan & Hidrasi
            _buildSectionTitle(context, '💧 Cairan & Hidrasi'),
            const SizedBox(height: 12),
            _buildCalculatorGrid(
              context,
              [
                _CalculatorItem(
                  title: 'Water Needs',
                  icon: Bootstrap.droplet,
                  color: Colors.blue,
                  route: '/calculator/water-needs',
                ),
                _CalculatorItem(
                  title: 'Body Water',
                  icon: Bootstrap.water,
                  color: Colors.lightBlue,
                  route: '/calculator/body-water',
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildCalculatorGrid(BuildContext context, List<_CalculatorItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _CalculatorCard(
          item: item,
          onTap: () {
            Navigator.of(context).pushNamed(item.route);
          },
        );
      },
    );
  }
}

class _CalculatorItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final String calculationType;
  
  const _CalculatorItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.calculationType = '',
  });
}

class _CalculatorCard extends StatelessWidget {
  final _CalculatorItem item;
  final VoidCallback onTap;
  
  const _CalculatorCard({
    required this.item,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 32,
                color: item.color,
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

