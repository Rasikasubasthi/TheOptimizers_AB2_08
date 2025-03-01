import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

enum OrderStatus {
  pending,
  confirmed,
  inTransit,
  delivered,
  cancelled
}

@JsonSerializable()
class OrderItem {
  final String productId;
  final int quantity;
  final double pricePerUnit;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  double get totalPrice => quantity * pricePerUnit;
}

@JsonSerializable()
class Order {
  final String id;
  final String consumerId;
  final String farmerId;
  final List<OrderItem> items;
  final DateTime orderDate;
  final OrderStatus status;
  final double deliveryDistance; // in kilometers
  final double totalAmount;

  Order({
    required this.id,
    required this.consumerId,
    required this.farmerId,
    required this.items,
    required this.orderDate,
    required this.status,
    required this.deliveryDistance,
    required this.totalAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  bool get isBulkOrder {
    int totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
    return totalQuantity >= 50; // Consider orders with 50+ items as bulk
  }

  bool get isShortDistance => deliveryDistance <= 20; // Short distance is <= 20km

  // Calculate priority score (higher score = higher priority)
  double calculatePriorityScore() {
    double score = 0;
    
    // Base priority based on distance and order size
    if (isShortDistance) {
      score += 100; // High priority for short distance
      if (!isBulkOrder) {
        score += 50; // Additional priority for small orders in short distance
      }
    } else {
      score += 50; // Lower priority for long distance
      if (isBulkOrder) {
        score += 75; // Higher priority for bulk orders in long distance
      }
    }

    // Penalize small orders from long distances
    if (!isBulkOrder && !isShortDistance) {
      score -= 25;
    }

    // Add time-based priority (older orders get higher priority)
    final hoursElapsed = DateTime.now().difference(orderDate).inHours;
    score += hoursElapsed * 2; // Add 2 points per hour elapsed

    return score;
  }
} 