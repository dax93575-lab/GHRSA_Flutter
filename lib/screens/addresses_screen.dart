import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  Future<void> _launchMaps(double lat, double lng) async {
    // Using the requested format: https://www.google.com/maps/search/?api=1&query=LAT,LNG
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );

    try {
      if (!await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $googleMapsUrl';
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'عناوين غرسة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddressCard(
            context,
            title: 'غرسة – فرع كلية التقنية الإلكترونية',
            description:
                'كلية التقنية الإلكترونية، بالقرب من Jaraba Mall، شارع الجرابة',
            city: 'طرابلس – ليبيا',
            lat: 32.873369,
            lng: 13.208808,
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            context,
            title: 'غرسة – فرع شارع الجمهورية',
            description: 'شارع الجمهورية',
            city: 'طرابلس – ليبيا',
            lat: 32.887104,
            lng: 13.196511,
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context, {
    required String title,
    required String description,
    required String city,
    required double lat,
    required double lng,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _launchMaps(lat, lng),
        borderRadius: BorderRadius.circular(12),
        // Ripple effect enabled by InkWell
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[800], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      city,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
