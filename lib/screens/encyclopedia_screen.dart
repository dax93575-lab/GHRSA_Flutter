import 'package:flutter/material.dart';

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الموسوعة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(
            context,
            'نصائح ري النباتات',
            'احرص على تنظيف أوراق النباتات بانتظام للحفاظ على صحتها ولمعانها.',
            'الري هو أهم عامل لنجاح نمو النباتات. \n\n1. افحص التربة قبل الري: أدخل إصبعك في التربة بعمق 2-3 سم، إذا كانت جافة فاروها.\n2. الوقت المناسب: أفضل وقت للري هو الصباح الباكر أو بعد غروب الشمس لتجنب تبخر الماء سريعاً.\n3. علامات العطش: ذبول الأوراق واصفرارها قد يدل على نقص الماء، بينما تعفن الجذور يدل على كثرته.',
            Icons.water_drop,
            Colors.blue[50]!,
            Colors.blue[900]!,
          ),
          _buildTipCard(
            context,
            'الإضاءة المناسبة',
            'تجنب الإفراط في الري. معظم النباتات الداخلية تحتاج إلى تربة جيدة التصريف.',
            'الإضاءة هي غذاء النبات:\n\n1. ضوء مباشر: تحتاجه الصباريات والنباتات المزهرة الخارجية.\n2. ضوء ساطع غير مباشر: مثالي لمعظم النباتات الداخلية مثل البوتس والمونستيرا.\n3. ظل جزئي: يناسب نباتات مثل الزاميا.\n\nراقب نباتك: إذا استطالت الساق بضعف فهذا يعني أنها تبحث عن الضوء.',
            Icons.wb_sunny,
            Colors.orange[50]!,
            Colors.orange[900]!,
          ),
          _buildTipCard(
            context,
            'التسميد',
            'استخدم سماد عضوي مخفف مرة شهرياً في موسم النمو.',
            'التسميد يمد النبات بالعناصر الغذائية:\n\n- NPK: سماد متوازن (نيتروجين للنمو الخضري، فوسفور للجذور، بوتاسيوم للأزهار).\n- التوقيت: سمد النباتات خلال موسم النمو (الربيع والصيف) وتوقف في الشتاء.\n- تحذير: لا تفرط في التسميد فقد يحرق الجذور.',
            Icons.grass,
            Colors.green[50]!,
            Colors.green[900]!,
          ),
          _buildTipCard(
            context,
            'اختيار الأصيص',
            'تأكد من اختيار حجم الأصيص المناسب لحجم النبات وجذوره.',
            'اختيار الأصيص لا يقل أهمية عن التربة:\n\n1. فتحات التصريف: ضرورية جداً لتصريف الماء الزائد ومنع تعفن الجذور.\n2. الحجم: اختر أصيصاً أكبر قليلاً من حجم الجذور. الأصيص الكبير جداً قد يحبس رطوبة زائدة.\n3. المادة: الفخار يسمح للتربة بالتنفس، بينما البلاستيك يحفظ الرطوبة لفترة أطول.',
            Icons.check_box_outline_blank,
            Colors.brown[50]!,
            Colors.brown[900]!,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    String title,
    String summary,
    String fullContent,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () =>
            _showTipDetails(context, title, fullContent, icon, iconColor),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: iconColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipDetails(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(icon, size: 30, color: color),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              Text(
                content,
                style: const TextStyle(fontSize: 16, height: 1.6),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
