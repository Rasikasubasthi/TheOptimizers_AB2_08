import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_data_service.dart';
import '../models/product.dart';
import '../models/order.dart';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({super.key});

  @override
  State<ConsumerDashboard> createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard> {
  int _selectedIndex = 0;
  final String _mockConsumerId = 'consumer123'; // TODO: Replace with actual consumer authentication

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumer Dashboard'),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'My Orders',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildMarketplace();
      case 1:
        return _buildMyOrders();
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }

  Widget _buildMarketplace() {
    return FutureBuilder<List<Product>>(
      future: context.read<LocalDataService>().getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${product.price} per ${product.unit}',
                          style: const TextStyle(
                            color: Colors.green,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: product.availableQuantity > 0
                              ? () => _showOrderDialog(product)
                              : null,
                          child: Text(
                            product.availableQuantity > 0
                                ? 'Order Now'
                                : 'Out of Stock',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMyOrders() {
    return FutureBuilder<List<Order>>(
      future: context.read<LocalDataService>().getOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final orders = snapshot.data ?? [];
        final consumerOrders = orders.where((o) => o.consumerId == _mockConsumerId).toList();

        if (consumerOrders.isEmpty) {
          return const Center(child: Text('No orders placed yet'));
        }

        return ListView.builder(
          itemCount: consumerOrders.length,
          itemBuilder: (context, index) {
            final order = consumerOrders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Order #${order.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: ${order.status.name}'),
                    Text('Total Amount: \$${order.totalAmount.toStringAsFixed(2)}'),
                    Text('Items: ${order.items.length}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showOrderDialog(Product product) async {
    final quantityController = TextEditingController(text: '1');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (${product.unit})',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text(
              'Available: ${product.availableQuantity} ${product.unit}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (quantity <= 0 || quantity > product.availableQuantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid quantity'),
                  ),
                );
                return;
              }

              final order = Order(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                consumerId: _mockConsumerId,
                farmerId: product.farmerId,
                items: [
                  OrderItem(
                    productId: product.id,
                    quantity: quantity,
                    pricePerUnit: product.price,
                  ),
                ],
                orderDate: DateTime.now(),
                status: OrderStatus.pending,
                deliveryDistance: 10.0, // TODO: Calculate actual distance
                totalAmount: quantity * product.price,
              );

              await context.read<LocalDataService>().addOrder(order);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Place Order'),
          ),
        ],
      ),
    );
  }
} 