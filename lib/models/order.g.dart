// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => $checkedCreate(
      'OrderItem',
      json,
      ($checkedConvert) {
        final val = OrderItem(
          productId: $checkedConvert('productId', (v) => v as String),
          quantity: $checkedConvert('quantity', (v) => (v as num).toInt()),
          pricePerUnit:
              $checkedConvert('pricePerUnit', (v) => (v as num).toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'productId': instance.productId,
      'quantity': instance.quantity,
      'pricePerUnit': instance.pricePerUnit,
    };

Order _$OrderFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Order',
      json,
      ($checkedConvert) {
        final val = Order(
          id: $checkedConvert('id', (v) => v as String),
          consumerId: $checkedConvert('consumerId', (v) => v as String),
          farmerId: $checkedConvert('farmerId', (v) => v as String),
          items: $checkedConvert(
              'items',
              (v) => (v as List<dynamic>)
                  .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
                  .toList()),
          orderDate:
              $checkedConvert('orderDate', (v) => DateTime.parse(v as String)),
          status: $checkedConvert(
              'status', (v) => $enumDecode(_$OrderStatusEnumMap, v)),
          deliveryDistance:
              $checkedConvert('deliveryDistance', (v) => (v as num).toDouble()),
          totalAmount:
              $checkedConvert('totalAmount', (v) => (v as num).toDouble()),
        );
        return val;
      },
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'consumerId': instance.consumerId,
      'farmerId': instance.farmerId,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'orderDate': instance.orderDate.toIso8601String(),
      'status': _$OrderStatusEnumMap[instance.status]!,
      'deliveryDistance': instance.deliveryDistance,
      'totalAmount': instance.totalAmount,
    };

const _$OrderStatusEnumMap = {
  OrderStatus.pending: 'pending',
  OrderStatus.confirmed: 'confirmed',
  OrderStatus.inTransit: 'inTransit',
  OrderStatus.delivered: 'delivered',
  OrderStatus.cancelled: 'cancelled',
};
