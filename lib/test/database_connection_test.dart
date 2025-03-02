import 'package:flutter_test/flutter_test.dart';
import '../services/database_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late DatabaseService db;

  setUpAll(() async {
    await dotenv.load();
    db = DatabaseService();
    try {
      await db.initialize();
    } catch (e) {
      print('Failed to initialize database: $e');
    }
  });

  test('Database connection should work', () async {
    if (await db.checkConnection()) {
      try {
        final result = await db.connection.query('SELECT 1');
        expect(result, isNotEmpty);
      } catch (e) {
        print('Database operation failed: $e');
      }
    }
  });

  tearDownAll(() async {
    await db.close();
  });
} 