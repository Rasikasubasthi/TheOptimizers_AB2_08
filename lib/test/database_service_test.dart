import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/database_service.dart';

void main() {
  late DatabaseService db;

  setUp(() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    db = DatabaseService();
  });

  tearDown(() async {
    // Clean up after each test
    if (db.isInitialized) {
      await db.close();
    }
  });

  group('DatabaseService Connection Tests', () {
    test('Should initialize database connection', () async {
      await db.initialize();
      expect(db.isInitialized, true);
    });

    test('Should handle connection errors gracefully', () async {
      // Force an error by using invalid credentials
      await dotenv.load(fileName: '.env.test', mergeWith: {
        'DB_USER': 'invalid_user',
        'DB_PASSWORD': 'invalid_password'
      });
      
      expect(
        () async => await db.initialize(),
        throwsA(isA<DatabaseException>()),
      );
    });

    test('Should reconnect after connection loss', () async {
      await db.initialize();
      expect(db.isInitialized, true);

      await db.close();
      expect(db.isInitialized, false);

      await db.reconnect();
      expect(db.isInitialized, true);
      expect(await db.checkConnection(), true);
    });

    test('Should handle multiple initialization attempts', () async {
      await db.initialize();
      expect(db.isInitialized, true);

      // Second initialization should not throw error
      await db.initialize();
      expect(db.isInitialized, true);
    });
  });
} 