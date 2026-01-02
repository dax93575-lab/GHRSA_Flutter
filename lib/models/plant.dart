class Plant {
  final int? id;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final String description;
  final String category;
  final double? discount;
  final bool isFavorite;
  final String? temperature; // e.g. "18-25°C"
  final String? light; // Description
  final String? water; // Description
  final String? soil; // Description

  // Numeric values for Sliders (0.0 - 1.0)
  final double waterLevel;
  final double lightLevel;
  final double humidityLevel;
  final double fertilizerLevel;
  final int plantAge; // in months

  Plant({
    this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.description,
    required this.category,
    this.discount,
    this.isFavorite = false,
    this.temperature,
    this.light,
    this.water,
    this.soil,
    this.waterLevel = 0.5,
    this.lightLevel = 0.5,
    this.humidityLevel = 0.5,
    this.fertilizerLevel = 0.3,
    this.plantAge = 12,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'discount': discount,
      'isFavorite': isFavorite ? 1 : 0,
      'temperature': temperature,
      'light': light,
      'water': water,
      'soil': soil,
      'waterLevel': waterLevel,
      'lightLevel': lightLevel,
      'humidityLevel': humidityLevel,
      'fertilizerLevel': fertilizerLevel,
      'plantAge': plantAge,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id'] is int
          ? map['id']
          : int.tryParse(map['id']?.toString() ?? ''),
      name: map['name'] ?? 'بدون اسم',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'عام',
      discount: (map['discount'] as num?)?.toDouble(),
      isFavorite: map['isFavorite'] == 1 || map['isFavorite'] == true,
      temperature: map['temperature'] ?? '20-25°C',
      light: map['light'] ?? 'ضوء متوسط',
      water: map['water'] ?? 'ري معتدل',
      soil: map['soil'] ?? 'تربة زراعية',
      waterLevel: (map['waterLevel'] as num?)?.toDouble() ?? 0.5,
      lightLevel: (map['lightLevel'] as num?)?.toDouble() ?? 0.5,
      humidityLevel: (map['humidityLevel'] as num?)?.toDouble() ?? 0.5,
      fertilizerLevel: (map['fertilizerLevel'] as num?)?.toDouble() ?? 0.3,
      plantAge: (map['plantAge'] as num?)?.toInt() ?? 12,
    );
  }
  Plant copyWith({
    int? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? description,
    String? category,
    double? discount,
    bool? isFavorite,
    String? temperature,
    String? light,
    String? water,
    String? soil,
    double? waterLevel,
    double? lightLevel,
    double? humidityLevel,
    double? fertilizerLevel,
    int? plantAge,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      discount: discount ?? this.discount,
      isFavorite: isFavorite ?? this.isFavorite,
      temperature: temperature ?? this.temperature,
      light: light ?? this.light,
      water: water ?? this.water,
      soil: soil ?? this.soil,
      waterLevel: waterLevel ?? this.waterLevel,
      lightLevel: lightLevel ?? this.lightLevel,
      humidityLevel: humidityLevel ?? this.humidityLevel,
      fertilizerLevel: fertilizerLevel ?? this.fertilizerLevel,
      plantAge: plantAge ?? this.plantAge,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Plant &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.imageUrl == imageUrl &&
        other.description == description &&
        other.category == category &&
        other.discount == discount &&
        other.isFavorite == isFavorite &&
        other.temperature == temperature &&
        other.light == light &&
        other.water == water &&
        other.soil == soil &&
        other.waterLevel == waterLevel &&
        other.lightLevel == lightLevel &&
        other.humidityLevel == humidityLevel &&
        other.fertilizerLevel == fertilizerLevel &&
        other.plantAge == plantAge;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        imageUrl.hashCode ^
        description.hashCode ^
        category.hashCode ^
        discount.hashCode ^
        isFavorite.hashCode ^
        temperature.hashCode ^
        light.hashCode ^
        water.hashCode ^
        soil.hashCode ^
        waterLevel.hashCode ^
        lightLevel.hashCode ^
        humidityLevel.hashCode ^
        fertilizerLevel.hashCode ^
        plantAge.hashCode;
  }

  @override
  String toString() {
    return 'Plant(id: $id, name: $name, price: $price, quantity: $quantity, isFavorite: $isFavorite)';
  }
}
