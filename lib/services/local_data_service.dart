import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

class LocalDataService {
  static const String _usersFileName = 'users.json';
  static const String _productsFileName = 'products.json';
  static const String _ordersFileName = 'orders.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  // Users CRUD operations
  Future<List<User>> getUsers() async {
    try {
      final file = await _getFile(_usersFileName);
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => User.fromMap(json)).toList();
    } catch (e) {
      print('Error reading users: $e');
      return [];
    }
  }

  Future<void> saveUsers(List<User> users) async {
    final file = await _getFile(_usersFileName);
    final jsonList = users.map((user) => user.toMap()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  // Products CRUD operations
  Future<List<Product>> getProducts() async {
    try {
      final file = await _getFile(_productsFileName);
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Product.fromMap(json)).toList();
    } catch (e) {
      print('Error reading products: $e');
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    final file = await _getFile(_productsFileName);
    final jsonList = products.map((product) => product.toMap()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  // Orders CRUD operations
  Future<List<Order>> getOrders() async {
    try {
      final file = await _getFile(_ordersFileName);
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Order.fromMap(json)).toList();
    } catch (e) {
      print('Error reading orders: $e');
      return [];
    }
  }

  Future<void> saveOrders(List<Order> orders) async {
    final file = await _getFile(_ordersFileName);
    // Sort orders by priority score before saving
    orders.sort((a, b) => b.calculatePriorityScore().compareTo(a.calculatePriorityScore()));
    final jsonList = orders.map((order) => order.toMap()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  // Helper methods remain the same
  Future<void> addOrder(Order order) async {
    final orders = await getOrders();
    orders.add(order);
    await saveOrders(orders);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final orders = await getOrders();
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final updatedOrder = Order(
        id: orders[index].id,
        consumerId: orders[index].consumerId,
        farmerId: orders[index].farmerId,
        items: orders[index].items,
        orderDate: orders[index].orderDate,
        status: newStatus,
        deliveryDistance: orders[index].deliveryDistance,
        totalAmount: orders[index].totalAmount,
      );
      orders[index] = updatedOrder;
      await saveOrders(orders);
    }
  }

  Future<void> addProduct(Product product) async {
    final products = await getProducts();
    products.add(product);
    await saveProducts(products);
  }

  Future<void> updateProduct(Product product) async {
    final products = await getProducts();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      await saveProducts(products);
    }
  }
}