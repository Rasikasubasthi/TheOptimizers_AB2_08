import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
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

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  bool get isAvailable => availableQuantity > 0;
  
  DateTime get expiryDate => harvestDate.add(Duration(days: shelfLifeDays));
} 