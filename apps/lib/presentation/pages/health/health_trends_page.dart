import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:apps/core/constants/app_routes.dart';
import 'package:apps/core/theme/app_theme.dart';
import 'package:apps/presentation/providers/health_calculator_provider.dart';
import 'package:apps/presentation/providers/rag_chat_provider.dart';
import 'package:apps/presentation/widgets/chatbot_wrapper.dart';
import 'package:apps/domain/entities/health_metric.dart';

/// Health Trends Page - Tren / Grafik Kesehatan
class HealthTrendsPage extends StatefulWidget {
  static const String routeName = AppRoutes.healthTrends;
  
  const HealthTrendsPage({super.key});
  
  @override
  State<HealthTrendsPage> createState() => _HealthTrendsPageState();
}

class _HealthTrendsPageState extends State<HealthTrendsPage> {
  String? _selectedMetricType;
  final List<String> _metricTypes = ['BMI', 'BMR', 'TDEE', 'BodyFat', 'MaxHeartRate'];
  
  @override
  void initState() {
    super.initState();
    // Load metrics saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthCalculatorProvider>().getMetrics();
    });
  }
  
  void _analyzeMetrics() {
    final provider = context.read<HealthCalculatorProvider>();
    final metrics = provider.metrics;
    
    if (metrics.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data metrics untuk dianalisa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // Format metrics data untuk query RAG
    final metricsText = metrics.map((m) {
      return '${m.metricType}: ${m.metricValue} ${m.unit} (${DateFormat('yyyy-MM-dd HH:mm').format(m.recordedAt)})';
    }).join('\n');
    
    final query = 'Analisa data kesehatan saya:\n$metricsText\n\nBerikan insight dan rekomendasi berdasarkan tren data ini.';
    
    // Open chat dialog dengan query
    final ragProvider = context.read<RagChatProvider>();
    ragProvider.openChat();
    ragProvider.sendMessage(query);
    
    // Show chat dialog
    _showChatDialog();
  }
  
  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _ChatDialog(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tren Grafik Kesehatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HealthCalculatorProvider>().getMetrics();
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _analyzeMetrics,
            tooltip: 'Analisa Metrics',
          ),
        ],
      ),
      floatingActionButton: const ChatbotFAB(pageContext: 'health-trends'),
      body: Consumer<HealthCalculatorProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (provider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage ?? 'Terjadi kesalahan',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.getMetrics();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          
          final metrics = _selectedMetricType != null
              ? provider.metrics.where((m) => m.metricType == _selectedMetricType).toList()
              : provider.metrics;
          
          if (metrics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada data metrics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gunakan kalkulator kesehatan untuk membuat data metrics',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          // Group metrics by type
          final groupedMetrics = <String, List<HealthMetric>>{};
          for (var metric in metrics) {
            groupedMetrics.putIfAbsent(metric.metricType, () => []).add(metric);
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter by metric type
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Filter Metrik',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedMetricType,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Tipe Metrik',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.filter_list),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Semua Metrik'),
                            ),
                            ..._metricTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedMetricType = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Charts for each metric type
                ...groupedMetrics.entries.map((entry) {
                  return _buildMetricChart(entry.key, entry.value);
                }),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMetricChart(String metricType, List<HealthMetric> metrics) {
    // Sort by date
    metrics.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    // Prepare chart data
    final spots = metrics.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.metricValue);
    }).toList();
    
    // Get color based on metric type
    final color = _getMetricColor(metricType);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  metricType,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${metrics.length} data',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(metrics),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < metrics.length) {
                            final date = metrics[value.toInt()].recordedAt;
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: _getMinValue(metrics),
                  maxY: _getMaxValue(metrics),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Latest value
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nilai Terakhir',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${metrics.last.metricValue} ${metrics.last.unit}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Tanggal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(metrics.last.recordedAt),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getMetricColor(String metricType) {
    switch (metricType) {
      case 'BMI':
        return AppTheme.buttonGreen;
      case 'BMR':
        return Colors.blue;
      case 'TDEE':
        return Colors.orange;
      case 'BodyFat':
        return Colors.purple;
      case 'MaxHeartRate':
        return Colors.red;
      default:
        return AppTheme.primaryGreen;
    }
  }
  
  double _calculateInterval(List<HealthMetric> metrics) {
    if (metrics.isEmpty) return 10;
    final min = _getMinValue(metrics);
    final max = _getMaxValue(metrics);
    final range = max - min;
    if (range <= 0) return 10;
    return range / 5;
  }
  
  double _getMinValue(List<HealthMetric> metrics) {
    if (metrics.isEmpty) return 0;
    final values = metrics.map((m) => m.metricValue).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    return min * 0.9; // Add 10% padding
  }
  
  double _getMaxValue(List<HealthMetric> metrics) {
    if (metrics.isEmpty) return 100;
    final values = metrics.map((m) => m.metricValue).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    return max * 1.1; // Add 10% padding
  }
}

/// Chat Dialog untuk analisa metrics
class _ChatDialog extends StatelessWidget {
  const _ChatDialog();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Analisa Metrics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<RagChatProvider>().closeChat();
                  },
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: Consumer<RagChatProvider>(
              builder: (context, provider, child) {
                if (provider.messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Menunggu analisa...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          // Loading indicator
          Consumer<RagChatProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Menganalisa...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(message) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 20,
                color: Colors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
