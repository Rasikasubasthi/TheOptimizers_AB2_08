import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;
  
  DatabaseException(this.message, [this.originalError]);
  
  @override
  String toString() => 'DatabaseException: $message${originalError != null ? '\nOriginal error: $originalError' : ''}';
}

class DatabaseService {
  PostgreSQLConnection? _connection;
  bool _isInitialized = false;
  static final DatabaseService _instance = DatabaseService._internal();
  
  // Configuration
  static const int maxRetries = 3;
  static const int retryDelaySeconds = 2;
  
  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  bool get isInitialized => _isInitialized;

  PostgreSQLConnection get connection {
    if (_connection == null || _connection!.isClosed) {
      throw DatabaseException('Database connection is not initialized or closed. Call initialize() first.');
    }
    return _connection!;
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      print('Database is already initialized');
      return;
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        _connection = PostgreSQLConnection(
          dotenv.env['DB_HOST'] ?? 'localhost',
          int.parse(dotenv.env['DB_PORT'] ?? '5432'),
          dotenv.env['DB_NAME'] ?? 'farmer_marketplace',
          username: dotenv.env['DB_USER'],
          password: dotenv.env['DB_PASSWORD'],
          timeoutInSeconds: 30,
          useSSL: true,
        );
        
        await _connection!.open();
        await _validateConnection();
        await _createTables();
        
        _isInitialized = true;
        print('Database initialized successfully');
        return;
        
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          _isInitialized = false;
          _connection = null;
          throw DatabaseException(
            'Failed to initialize database after $maxRetries attempts',
            e
          );
        }
        
        print('Database connection attempt $retryCount failed. Retrying in $retryDelaySeconds seconds...');
        await Future.delayed(Duration(seconds: retryDelaySeconds));
      }
    }
  }

  Future<void> _validateConnection() async {
    try {
      await _connection!.query('SELECT 1');
    } catch (e) {
      throw DatabaseException('Failed to validate database connection', e);
    }
  }

  Future<void> close() async {
    if (_connection != null && !_connection!.isClosed) {
      try {
        await _connection!.close();
      } catch (e) {
        print('Error while closing database connection: $e');
      } finally {
        _isInitialized = false;
        _connection = null;
      }
    }
  }

  Future<bool> checkConnection() async {
    try {
      if (_connection == null || _connection!.isClosed) {
        return false;
      }
      await _connection!.query('SELECT 1');
      return true;
    } catch (e) {
      print('Connection check failed: $e');
      return false;
    }
  }

  Future<void> reconnect() async {
    await close();
    await initialize();
  }

  // Wrap database operations with error handling
  Future<T> _executeQuery<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PostgreSQLException catch (e) {
      throw DatabaseException('PostgreSQL error: ${e.message}', e);
    } catch (e) {
      throw DatabaseException('Database operation failed', e);
    }
  }

  Future<void> _createTables() async {
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        phone VARCHAR(20) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        user_type VARCHAR(20) NOT NULL,
        address TEXT,
        latitude DOUBLE PRECISION,
        longitude DOUBLE PRECISION,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id UUID PRIMARY KEY,
        farmer_id UUID REFERENCES users(id),
        name VARCHAR(255) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL,
        unit VARCHAR(20) NOT NULL,
        available_quantity INTEGER NOT NULL,
        category VARCHAR(50) NOT NULL,
        harvest_date TIMESTAMP NOT NULL,
        shelf_life_days INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id UUID PRIMARY KEY,
        consumer_id UUID REFERENCES users(id),
        farmer_id UUID REFERENCES users(id),
        status VARCHAR(20) NOT NULL,
        delivery_distance DECIMAL(10,2) NOT NULL,
        total_amount DECIMAL(10,2) NOT NULL,
        order_date TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id UUID PRIMARY KEY,
        order_id UUID REFERENCES orders(id),
        product_id UUID REFERENCES products(id),
        quantity INTEGER NOT NULL,
        price_per_unit DECIMAL(10,2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await connection.execute('''
      CREATE TABLE IF NOT EXISTS otp_verifications (
        id UUID PRIMARY KEY,
        phone VARCHAR(20) NOT NULL,
        otp VARCHAR(6) NOT NULL,
        expires_at TIMESTAMP NOT NULL,
        verified BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // User Operations
  Future<User?> getUserById(String id) async {
    return _executeQuery(() async {
      final results = await connection.mappedResultsQuery(
        'SELECT * FROM users WHERE id = @id',
        substitutionValues: {'id': id},
      );
      if (results.isEmpty) return null;
      return User.fromMap(results.first['users']!);
    });
  }

  Future<User?> getUserByPhone(String phone) async {
    final results = await connection.mappedResultsQuery(
      'SELECT * FROM users WHERE phone = @phone',
      substitutionValues: {'phone': phone},
    );
    if (results.isEmpty) return null;
    return User.fromMap(results.first['users']!);
  }

  Future<void> saveUser(User user) async {
    await connection.execute('''
      INSERT INTO users (id, name, email, phone, user_type, address, latitude, longitude)
      VALUES (@id, @name, @email, @phone, @userType, @address, @latitude, @longitude)
    ''', substitutionValues: {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'userType': user.userType.toString().split('.').last,
      'address': user.address,
      'latitude': user.latitude,
      'longitude': user.longitude,
    });
  }

  // Product Operations
  Future<List<Product>> getProducts({String? farmerId}) async {
    final query = farmerId != null
        ? 'SELECT * FROM products WHERE farmer_id = @farmerId'
        : 'SELECT * FROM products';
    
    final results = await connection.mappedResultsQuery(
      query,
      substitutionValues: farmerId != null ? {'farmerId': farmerId} : null,
    );
    
    return results.map((r) => Product.fromMap(r['products']!)).toList();
  }

  Future<void> saveProduct(Product product) async {
    await connection.execute('''
      INSERT INTO products (
        id, farmer_id, name, description, price, unit, 
        available_quantity, category, harvest_date, shelf_life_days
      )
      VALUES (
        @id, @farmerId, @name, @description, @price, @unit,
        @quantity, @category, @harvestDate, @shelfLife
      )
    ''', substitutionValues: {
      'id': product.id,
      'farmerId': product.farmerId,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'unit': product.unit,
      'quantity': product.availableQuantity,
      'category': product.category,
      'harvestDate': product.harvestDate,
      'shelfLife': product.shelfLifeDays,
    });
  }

  // Order Operations
  Future<List<Order>> getOrders({String? consumerId, String? farmerId}) async {
    String query = 'SELECT * FROM orders WHERE 1=1';
    final Map<String, dynamic> values = {};

    if (consumerId != null) {
      query += ' AND consumer_id = @consumerId';
      values['consumerId'] = consumerId;
    }
    if (farmerId != null) {
      query += ' AND farmer_id = @farmerId';
      values['farmerId'] = farmerId;
    }

    final results = await connection.mappedResultsQuery(
      query,
      substitutionValues: values,
    );
    
    return results.map((r) => Order.fromMap(r['orders']!)).toList();
  }

  Future<void> saveOrder(Order order) async {
    await connection.transaction((ctx) async {
      // Insert order
      await ctx.execute('''
        INSERT INTO orders (
          id, consumer_id, farmer_id, status, delivery_distance,
          total_amount, order_date
        )
        VALUES (
          @id, @consumerId, @farmerId, @status, @distance,
          @amount, @orderDate
        )
      ''', substitutionValues: {
        'id': order.id,
        'consumerId': order.consumerId,
        'farmerId': order.farmerId,
        'status': order.status.toString().split('.').last,
        'distance': order.deliveryDistance,
        'amount': order.totalAmount,
        'orderDate': order.orderDate,
      });

      // Insert order items
      for (final item in order.items) {
        await ctx.execute('''
          INSERT INTO order_items (
            id, order_id, product_id, quantity, price_per_unit
          )
          VALUES (
            uuid_generate_v4(), @orderId, @productId, @quantity, @price
          )
        ''', substitutionValues: {
          'orderId': order.id,
          'productId': item.productId,
          'quantity': item.quantity,
          'price': item.pricePerUnit,
        });

        // Update product quantity
        await ctx.execute('''
          UPDATE products
          SET available_quantity = available_quantity - @quantity
          WHERE id = @productId
        ''', substitutionValues: {
          'quantity': item.quantity,
          'productId': item.productId,
        });
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await connection.execute('''
      UPDATE orders
      SET status = @status
      WHERE id = @id
    ''', substitutionValues: {
      'id': orderId,
      'status': status.toString().split('.').last,
    });
  }
} 