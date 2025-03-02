enum OrderStatus {
  pending,
  confirmed,
  inTransit,
  delivered,
  cancelled
}

class OrderItem {
  final String productId;
  final int quantity;
  final double pricePerUnit;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.pricePerUnit,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['product_id'],
      quantity: map['quantity'],
      pricePerUnit: (map['price_per_unit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
    };
  }

  double get totalPrice => quantity * pricePerUnit;
}

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

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      consumerId: map['consumer_id'],
      farmerId: map['farmer_id'],
      items: (map['items'] as List? ?? [])
          .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      orderDate: map['order_date'] is DateTime 
          ? map['order_date'] 
          : DateTime.parse(map['order_date']),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      deliveryDistance: (map['delivery_distance'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consumer_id': consumerId,
      'farmer_id': farmerId,
      'items': items.map((item) => item.toMap()).toList(),
      'order_date': orderDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'delivery_distance': deliveryDistance,
      'total_amount': totalAmount,
    };
  }

  bool get isBulkOrder {
    int totalQuantity = items.fold(0, (sum, item) => sum + item.quantity);
    return totalQuantity >= 50; // Consider orders with 50+ items as bulk
  }

  bool get isShortDistance => deliveryDistance <= 20; // Short distance is <= 20km

  double calculatePriorityScore() {
    double score = 0;
    
    if (isShortDistance) {
      score += 100;
      if (!isBulkOrder) score += 50;
    } else {
      score += 50;
      if (isBulkOrder) score += 75;
    }

    if (!isBulkOrder && !isShortDistance) {
      score -= 25;
    }

    final hoursElapsed = DateTime.now().difference(orderDate).inHours;
    score += hoursElapsed * 2;

    return score;
  }
} 