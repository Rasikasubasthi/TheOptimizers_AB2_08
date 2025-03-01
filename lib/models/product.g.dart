// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Product',
      json,
      ($checkedConvert) {
        final val = Product(
          id: $checkedConvert('id', (v) => v as String),
          farmerId: $checkedConvert('farmerId', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          description: $checkedConvert('description', (v) => v as String),
          price: $checkedConvert('price', (v) => (v as num).toDouble()),
          unit: $checkedConvert('unit', (v) => v as String),
          availableQuantity:
              $checkedConvert('availableQuantity', (v) => (v as num).toInt()),
          category: $checkedConvert('category', (v) => v as String),
          images: $checkedConvert('images',
              (v) => (v as List<dynamic>).map((e) => e as String).toList()),
          harvestDate: $checkedConvert(
              'harvestDate', (v) => DateTime.parse(v as String)),
          shelfLifeDays:
              $checkedConvert('shelfLifeDays', (v) => (v as num).toInt()),
        );
        return val;
      },
    );

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'farmerId': instance.farmerId,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'unit': instance.unit,
      'availableQuantity': instance.availableQuantity,
      'category': instance.category,
      'images': instance.images,
      'harvestDate': instance.harvestDate.toIso8601String(),
      'shelfLifeDays': instance.shelfLifeDays,
    };
