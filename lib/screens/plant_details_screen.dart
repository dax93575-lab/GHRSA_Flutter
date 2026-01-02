import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/plant.dart';
import '../providers/app_provider.dart';
import 'plant_care_screen.dart';

class PlantDetailsScreen extends StatefulWidget {
  final Plant plant;

  const PlantDetailsScreen({super.key, required this.plant});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green[800],
            iconTheme: const IconThemeData(color: Colors.black),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.plant.name,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: () {
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
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  );
                } else if (finalUrl.startsWith('assets')) {
                  return Image.asset(finalUrl, fit: BoxFit.cover);
                } else {
                  return Image.file(
                    File(finalUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  );
                }
              }(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.plant.price} د.ل',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          // Find current instance of plant in provider to get reactive favorite status
                          final currentPlant = provider.plants.firstWhere(
                            (p) => p.id == widget.plant.id,
                            orElse: () => widget.plant,
                          );
                          return IconButton(
                            icon: Icon(
                              currentPlant.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: currentPlant.isFavorite
                                  ? Colors.red
                                  : Colors.grey,
                              size: 30,
                            ),
                            onPressed: () {
                              provider.toggleFavorite(currentPlant);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(widget.plant.category),
                        backgroundColor: Colors.green[50],
                        labelStyle: TextStyle(color: Colors.green[800]),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.plant.quantity > 0
                            ? 'متوفر: ${widget.plant.quantity} قطعة'
                            : 'غير متوفر حالياً',
                        style: TextStyle(
                          color: widget.plant.quantity > 0
                              ? Colors.black54
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Care Guide Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PlantCareScreen(plant: widget.plant),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            color: Colors.blue[800],
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'دليل العناية بالنبات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.blue[800],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text(
                    'الوصف',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.plant.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Quantity Selector & Add to Cart Row
                  if (widget.plant.quantity > 0) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // Quantity Selector
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: _quantity < widget.plant.quantity
                                    ? () => setState(() => _quantity++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Add to Cart Button
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Provider.of<AppProvider>(
                                  context,
                                  listen: false,
                                ).addToCart(widget.plant, _quantity);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تمت الإضافة للسلة بنجاح'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.shopping_cart),
                              label: Text(
                                'إضافة (${(widget.plant.price * _quantity).toStringAsFixed(2)} د.ل)',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[800],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('نفذت الكمية'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
