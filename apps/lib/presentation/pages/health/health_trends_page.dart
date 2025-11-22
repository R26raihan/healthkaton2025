import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:video_player/video_player.dart';
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
    
    // Calculate statistics
    final values = metrics.map((m) => m.metricValue).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final trend = metrics.length > 1 
        ? (metrics.last.metricValue - metrics.first.metricValue) 
        : 0.0;
    final trendIcon = trend > 0 
        ? Icons.trending_up 
        : trend < 0 
            ? Icons.trending_down 
            : Icons.trending_flat;
    final trendColor = trend > 0 
        ? Colors.red 
        : trend < 0 
            ? Colors.green 
            : Colors.grey;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _showAIAnalysis(metricType, metrics, color),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getMetricIcon(metricType),
                            color: color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              metricType,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                            Text(
                              '${metrics.length} data point',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: trendColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendIcon,
                            color: trendColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trend > 0 
                                ? '+${trend.toStringAsFixed(1)}' 
                                : trend < 0 
                                    ? trend.toStringAsFixed(1) 
                                    : '0.0',
                            style: TextStyle(
                              color: trendColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calculateInterval(metrics),
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[200]!,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 35,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < metrics.length) {
                                final date = metrics[value.toInt()].recordedAt;
                                return Text(
                                  DateFormat('MM/dd').format(date),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
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
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1.5,
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: color,
                          barWidth: 4,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: color,
                                strokeWidth: 3,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                color.withOpacity(0.3),
                                color.withOpacity(0.05),
                              ],
                            ),
                          ),
                          shadow: Shadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ),
                      ],
                      minY: _getMinValue(metrics),
                      maxY: _getMaxValue(metrics),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((LineBarSpot touchedSpot) {
                              final index = touchedSpot.x.toInt();
                              if (index >= 0 && index < metrics.length) {
                                final metric = metrics[index];
                                return LineTooltipItem(
                                  '${metric.metricValue.toStringAsFixed(1)} ${metric.unit}\n${DateFormat('dd MMM yyyy').format(metric.recordedAt)}',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }
                              return null;
                            }).toList();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Rata-rata',
                        avg.toStringAsFixed(1),
                        metrics.first.unit,
                        Icons.analytics_outlined,
                        color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Min',
                        min.toStringAsFixed(1),
                        metrics.first.unit,
                        Icons.arrow_downward,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Max',
                        max.toStringAsFixed(1),
                        metrics.first.unit,
                        Icons.arrow_upward,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Latest value with AI button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.15),
                        color.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1.5,
                    ),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${metrics.last.metricValue} ${metrics.last.unit}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy, HH:mm').format(metrics.last.recordedAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.withOpacity(0.2),
                              Colors.purple.withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Analisa AI',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$value $unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getMetricIcon(String metricType) {
    switch (metricType) {
      case 'BMI':
        return Icons.monitor_weight;
      case 'BMR':
        return Icons.local_fire_department;
      case 'TDEE':
        return Icons.fitness_center;
      case 'BodyFat':
        return Icons.person;
      case 'MaxHeartRate':
        return Icons.favorite;
      default:
        return Icons.show_chart;
    }
  }
  
  void _showAIAnalysis(String metricType, List<HealthMetric> metrics, Color color) {
    // Sort by date
    metrics.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    // Format metrics data untuk query
    final metricsText = metrics.map((m) {
      return '${DateFormat('yyyy-MM-dd').format(m.recordedAt)}: ${m.metricValue} ${m.unit}';
    }).join('\n');
    
    // Calculate statistics
    final values = metrics.map((m) => m.metricValue).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final trend = metrics.length > 1 
        ? (metrics.last.metricValue - metrics.first.metricValue) 
        : 0.0;
    final latest = metrics.last.metricValue;
    
    final query = 'Analisa tren data $metricType saya:\n\n'
        'Data historis:\n$metricsText\n\n'
        'Statistik:\n'
        '- Nilai terakhir: $latest ${metrics.first.unit}\n'
        '- Rata-rata: ${avg.toStringAsFixed(2)} ${metrics.first.unit}\n'
        '- Minimum: $min ${metrics.first.unit}\n'
        '- Maksimum: $max ${metrics.first.unit}\n'
        '- Tren: ${trend > 0 ? "Naik" : trend < 0 ? "Turun" : "Stabil"} (${trend.toStringAsFixed(2)} ${metrics.first.unit})\n\n'
        'Berikan analisa mendalam tentang tren kesehatan saya, identifikasi pola, dan berikan rekomendasi yang bisa saya lakukan untuk meningkatkan kesehatan saya.';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MetricAIAnalysisBottomSheet(
        metricType: metricType,
        metrics: metrics,
        color: color,
        initialQuery: query,
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

/// Bottom Sheet untuk analisa metrics dengan AI
class _MetricAIAnalysisBottomSheet extends StatefulWidget {
  final String metricType;
  final List<HealthMetric> metrics;
  final Color color;
  final String initialQuery;
  
  const _MetricAIAnalysisBottomSheet({
    required this.metricType,
    required this.metrics,
    required this.color,
    required this.initialQuery,
  });
  
  @override
  State<_MetricAIAnalysisBottomSheet> createState() => _MetricAIAnalysisBottomSheetState();
}

class _MetricAIAnalysisBottomSheetState extends State<_MetricAIAnalysisBottomSheet> {
  bool _hasQueried = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasQueried && mounted) {
        _queryAI();
      }
    });
  }
  
  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'assets/images/asisten_animasi_hello.mp4',
      );
      
      await _videoController!.initialize();
      _videoController!.setLooping(true);
      await _videoController!.play();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
  
  Future<void> _queryAI() async {
    if (_hasQueried) return;
    _hasQueried = true;
    
    final ragProvider = context.read<RagChatProvider>();
    ragProvider.clearChat();
    await ragProvider.sendMessage(widget.initialQuery);
  }
  
  @override
  Widget build(BuildContext context) {
    // Calculate statistics
    final values = widget.metrics.map((m) => m.metricValue).toList();
    final avg = values.reduce((a, b) => a + b) / values.length;
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final latest = widget.metrics.last.metricValue;
    final trend = widget.metrics.length > 1 
        ? (widget.metrics.last.metricValue - widget.metrics.first.metricValue) 
        : 0.0;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header dengan gradient
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20 + MediaQuery.of(context).padding.top,
              bottom: 20,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Video Player sebagai icon animasi
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _isVideoInitialized && _videoController != null
                      ? SizedBox.expand(
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _videoController!.value.size.width,
                              height: _videoController!.value.size.height,
                              child: VideoPlayer(_videoController!),
                            ),
                          ),
                        )
                      : Container(
                          color: widget.color.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.auto_awesome,
                              color: widget.color,
                              size: 24,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisa Tren AI',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.metricType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Consumer<RagChatProvider>(
              builder: (context, ragProvider, child) {
                if (ragProvider.isLoading && ragProvider.messages.isEmpty) {
                  return _buildLoadingState();
                }
                
                if (ragProvider.errorMessage != null && ragProvider.messages.isEmpty) {
                  return _buildErrorState(ragProvider.errorMessage ?? 'Terjadi kesalahan');
                }
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Statistics Card
                      _buildSummaryCard(context, widget.metrics, widget.color, avg, min, max, latest, trend),
                      const SizedBox(height: 20),
                      // AI Response
                      if (ragProvider.messages.isNotEmpty)
                        _buildAIResponse(context, ragProvider),
                      if (ragProvider.isLoading)
                        _buildLoadingIndicator(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          ),
          const SizedBox(height: 16),
          Text(
            'Menganalisa tren data...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
              error,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _hasQueried = false;
                _queryAI();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard(BuildContext context, List<HealthMetric> metrics, Color color, double avg, double min, double max, double latest, double trend) {
    final trendIcon = trend > 0 
        ? Icons.trending_up 
        : trend < 0 
            ? Icons.trending_down 
            : Icons.trending_flat;
    final trendColor = trend > 0 
        ? Colors.red 
        : trend < 0 
            ? Colors.green 
            : Colors.grey;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getMetricIcon(widget.metricType),
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Statistik',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${metrics.length} data point',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Rata-rata', avg.toStringAsFixed(1), metrics.first.unit, Icons.analytics_outlined, color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem('Min', min.toStringAsFixed(1), metrics.first.unit, Icons.arrow_downward, Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Max', max.toStringAsFixed(1), metrics.first.unit, Icons.arrow_upward, Colors.red),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem('Tren', trend > 0 ? '+${trend.toStringAsFixed(1)}' : trend.toStringAsFixed(1), metrics.first.unit, trendIcon, trendColor),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 12),
              Row(
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
                        '$latest ${metrics.first.unit}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                        'Periode',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('dd MMM').format(metrics.first.recordedAt)} - ${DateFormat('dd MMM yyyy').format(metrics.last.recordedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$value $unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIResponse(BuildContext context, RagChatProvider provider) {
    final aiMessages = provider.messages.where((m) => !m.isUser).toList();
    
    if (aiMessages.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue.withOpacity(0.05),
              Colors.purple.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Analisa AI',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...aiMessages.map((message) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    message.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(widget.color),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'AI sedang menganalisa...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getMetricIcon(String metricType) {
    switch (metricType) {
      case 'BMI':
        return Icons.monitor_weight;
      case 'BMR':
        return Icons.local_fire_department;
      case 'TDEE':
        return Icons.fitness_center;
      case 'BodyFat':
        return Icons.person;
      case 'MaxHeartRate':
        return Icons.favorite;
      default:
        return Icons.show_chart;
    }
  }
}

/// Chat Dialog untuk analisa metrics (legacy, masih digunakan untuk button analytics)
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
