import 'package:flutter_test/flutter_test.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

void main() {
  group('User Model Tests', () {
    test('fromMap and toMap should work correctly', () {
      final userData = {
        'id': 'test-id',
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1234567890',
        'user_type': 'farmer',
        'address': '123 Farm St',
        'latitude': 40.7128,
        'longitude': -74.0060,
      };

      final user = User.fromMap(userData);
      expect(user.id, 'test-id');
      expect(user.name, 'John Doe');
      expect(user.userType, UserType.farmer);

      final map = user.toMap();
      expect(map['user_type'], 'farmer');
      expect(map['latitude'], 40.7128);
    });
  });

  group('Product Model Tests', () {
    test('fromMap and toMap should work correctly', () {
      final productData = {
        'id': 'prod-id',
        'farmer_id': 'farmer-id',
        'name': 'Tomatoes',
        'description': 'Fresh tomatoes',
        'price': 2.99,
        'unit': 'kg',
        'available_quantity': 100,
        'category': 'Vegetables',
        'harvest_date': '2024-01-20T10:00:00.000Z',
        'shelf_life_days': 7,
      };

      final product = Product.fromMap(productData);
      expect(product.id, 'prod-id');
      expect(product.price, 2.99);
      expect(product.isAvailable, true);

      final map = product.toMap();
      expect(map['farmer_id'], 'farmer-id');
      expect(map['available_quantity'], 100);
    });
  });

  group('Order Model Tests', () {
    test('fromMap and toMap should work correctly', () {
      final orderItemData = {
        'product_id': 'prod-id',
        'quantity': 5,
        'price_per_unit': 2.99,
      };

      final orderData = {
        'id': 'order-id',
        'consumer_id': 'consumer-id',
        'farmer_id': 'farmer-id',
        'items': [orderItemData],
        'order_date': '2024-01-20T10:00:00.000Z',
        'status': 'pending',
        'delivery_distance': 15.5,
        'total_amount': 14.95,
      };

      final order = Order.fromMap(orderData);
      expect(order.id, 'order-id');
      expect(order.items.length, 1);
      expect(order.status, OrderStatus.pending);
      expect(order.isShortDistance, true);

      final map = order.toMap();
      expect(map['status'], 'pending');
      expect(map['total_amount'], 14.95);
    });

    test('Priority score calculation should work correctly', () {
      final orderData = {
        'id': 'order-id',
        'consumer_id': 'consumer-id',
        'farmer_id': 'farmer-id',
        'items': List.generate(60, (i) => {
          'product_id': 'prod-$i',
          'quantity': 1,
          'price_per_unit': 1.0,
        }),
        'order_date': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        'status': 'pending',
        'delivery_distance': 25.0,
        'total_amount': 60.0,
      };

      final order = Order.fromMap(orderData);
      expect(order.isBulkOrder, true);
      expect(order.isShortDistance, false);
      
      final score = order.calculatePriorityScore();
      expect(score, greaterThan(0));
    });
  });
} 