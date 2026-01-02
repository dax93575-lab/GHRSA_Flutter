import 'package:flutter/material.dart';
import 'dart:io';
import '../models/plant.dart';

class PlantCareScreen extends StatefulWidget {
  final Plant plant;

  const PlantCareScreen({super.key, required this.plant});

  @override
  State<PlantCareScreen> createState() => _PlantCareScreenState();
}

class _PlantCareScreenState extends State<PlantCareScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Image Header
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green[800],
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'عناية ${widget.plant.name}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  () {
                    var finalUrl = widget.plant.imageUrl;
                    // If simple filename (no slash, no http, no assets prefix), assume asset
                    if (!finalUrl.startsWith('http') &&
                        !finalUrl.startsWith('assets') &&
                        !finalUrl.contains('/') &&
                        !finalUrl.contains('\\')) {
                      finalUrl = 'assets/images/$finalUrl';
                    }

                    if (finalUrl.startsWith('http')) {
                      return Image.network(
                        finalUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[800]),
                      );
                    } else if (finalUrl.startsWith('assets')) {
                      return Image.asset(finalUrl, fit: BoxFit.cover);
                    } else {
                      return Image.file(File(finalUrl), fit: BoxFit.cover);
                    }
                  }(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Metrics (Sliders) Section
                  const Text(
                    'مؤشرات الحيوية',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildAnimatedMetric(
                    'كمية المياه',
                    Icons.water_drop,
                    Colors.blue,
                    widget.plant.waterLevel,
                  ),
                  _buildAnimatedMetric(
                    'مستوى الضوء',
                    Icons.wb_sunny,
                    Colors.orange,
                    widget.plant.lightLevel,
                  ),
                  _buildAnimatedMetric(
                    'نسبة الرطوبة',
                    Icons.cloud,
                    Colors.lightBlueAccent,
                    widget.plant.humidityLevel,
                  ),
                  _buildAnimatedMetric(
                    'التسميد',
                    Icons.science,
                    Colors.purple,
                    widget.plant.fertilizerLevel,
                  ),

                  const SizedBox(height: 20),

                  // Age & Soil (Non-slider visual info)
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'عمر النبات',
                          '${widget.plant.plantAge} شهر',
                          Icons.date_range,
                          Colors.teal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildInfoCard(
                          'نوع التربة',
                          widget.plant.soil ?? 'غير محدد',
                          Icons.grass,
                          Colors.brown,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 30),

                  // 3. Detailed Text Section
                  const Text(
                    'دليل العناية الشامل',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildDetailSection(
                    'طريقة الري',
                    widget.plant.water ?? 'غير محدد',
                    Icons.water_drop_outlined,
                  ),
                  _buildDetailSection(
                    'الإضاءة المناسبة',
                    widget.plant.light ?? 'غير محدد',
                    Icons.wb_sunny_outlined,
                  ),
                  _buildDetailSection(
                    'درجة الحرارة',
                    'تحتاج درجة حرارة مثالية ${widget.plant.temperature ?? "غير محددة"} لنمو سليم.',
                    Icons.thermostat_outlined,
                  ),
                  _buildDetailSection(
                    'أخطاء شائعة',
                    'تجنب زيادة الري المفرط في الشتاء، وتأكد من وجود فتحات تصريف في الأصيص لتجنب تعفن الجذور.',
                    Icons.warning_amber_rounded,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMetric(
    String title,
    IconData icon,
    Color color,
    double level,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Text(
                '${(level * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _controller.value * level,
                  minHeight: 12,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.green[800], size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
