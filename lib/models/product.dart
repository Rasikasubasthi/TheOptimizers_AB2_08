class Product {
  final String id;
  final String farmerId;
  final String name;
  final String description;
  final double price;
  final String unit; // e.g., kg, piece, bundle
  final int availableQuantity;
  final String category;
  final List<String> images;
  final DateTime harvestDate;
  final int shelfLifeDays;

  Product({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.availableQuantity,
    required this.category,
    required this.images,
    required this.harvestDate,
    required this.shelfLifeDays,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      farmerId: map['farmer_id'],
      name: map['name'],
      description: map['description'],
      price: (map['price'] as num).toDouble(),
      unit: map['unit'],
      availableQuantity: map['available_quantity'],
      category: map['category'],
      images: List<String>.from(map['images'] ?? []),
      harvestDate: map['harvest_date'] is DateTime 
          ? map['harvest_date'] 
          : DateTime.parse(map['harvest_date']),
      shelfLifeDays: map['shelf_life_days'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'available_quantity': availableQuantity,
      'category': category,
      'images': images,
      'harvest_date': harvestDate.toIso8601String(),
      'shelf_life_days': shelfLifeDays,
    };
  }

  bool get isAvailable => availableQuantity > 0;
  
  DateTime get expiryDate => harvestDate.add(Duration(days: shelfLifeDays));
} 