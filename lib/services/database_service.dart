import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseService {
  late PostgreSQLConnection _connection;
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    _connection = PostgreSQLConnection(
      dotenv.env['DB_HOST'] ?? 'localhost',
      int.parse(dotenv.env['DB_PORT'] ?? '5432'),
      dotenv.env['DB_NAME'] ?? 'farmer_marketplace',
      username: dotenv.env['DB_USER'],
      password: dotenv.env['DB_PASSWORD'],
    );
    await _connection.open();
    await _createTables();
  }

  Future<void> _createTables() async {
    await _connection.execute('''
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

    await _connection.execute('''
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

    await _connection.execute('''
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

    await _connection.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id UUID PRIMARY KEY,
        order_id UUID REFERENCES orders(id),
        product_id UUID REFERENCES products(id),
        quantity INTEGER NOT NULL,
        price_per_unit DECIMAL(10,2) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await _connection.execute('''
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
} 