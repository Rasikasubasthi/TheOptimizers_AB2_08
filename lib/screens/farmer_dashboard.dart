import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_data_service.dart';
import '../models/product.dart';
import '../models/order.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;
  final String _mockFarmerId = 'farmer123'; // TODO: Replace with actual farmer authentication

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
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
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildProductsList();
      case 1:
        return _buildOrdersList();
      default:
        return const Center(child: Text('Unknown tab'));
    }
  }

  Widget _buildProductsList() {
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
        final farmerProducts = products.where((p) => p.farmerId == _mockFarmerId).toList();

        if (farmerProducts.isEmpty) {
          return const Center(child: Text('No products added yet'));
        }

        return ListView.builder(
          itemCount: farmerProducts.length,
          itemBuilder: (context, index) {
            final product = farmerProducts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(
                  '${product.price} per ${product.unit} - Available: ${product.availableQuantity}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditProductDialog(product),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersList() {
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
        final farmerOrders = orders.where((o) => o.farmerId == _mockFarmerId).toList();

        if (farmerOrders.isEmpty) {
          return const Center(child: Text('No orders received yet'));
        }

        return ListView.builder(
          itemCount: farmerOrders.length,
          itemBuilder: (context, index) {
            final order = farmerOrders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Order #${order.id}'),
                subtitle: Text(
                  'Status: ${order.status.name} - Items: ${order.items.length}',
                ),
                trailing: PopupMenuButton<OrderStatus>(
                  onSelected: (OrderStatus status) {
                    _updateOrderStatus(order.id, status);
                  },
                  itemBuilder: (BuildContext context) {
                    return OrderStatus.values.map((OrderStatus status) {
                      return PopupMenuItem<OrderStatus>(
                        value: status,
                        child: Text(status.name),
                      );
                    }).toList();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    String selectedUnit = 'kg';
    String selectedCategory = 'Vegetables';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Available Quantity'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                items: ['kg', 'piece', 'bundle'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    selectedUnit = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Vegetables', 'Fruits', 'Grains', 'Others'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final product = Product(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                farmerId: _mockFarmerId,
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0,
                unit: selectedUnit,
                availableQuantity: int.tryParse(quantityController.text) ?? 0,
                category: selectedCategory,
                images: const [],
                harvestDate: DateTime.now(),
                shelfLifeDays: 7,
              );

              await context.read<LocalDataService>().addProduct(product);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditProductDialog(Product product) async {
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final quantityController = TextEditingController(text: product.availableQuantity.toString());
    String selectedUnit = product.unit;
    String selectedCategory = product.category;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Available Quantity'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                items: ['kg', 'piece', 'bundle'].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    selectedUnit = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: ['Vegetables', 'Fruits', 'Grains', 'Others'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedProduct = Product(
                id: product.id,
                farmerId: product.farmerId,
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? product.price,
                unit: selectedUnit,
                availableQuantity: int.tryParse(quantityController.text) ?? product.availableQuantity,
                category: selectedCategory,
                images: product.images,
                harvestDate: product.harvestDate,
                shelfLifeDays: product.shelfLifeDays,
              );

              await context.read<LocalDataService>().updateProduct(updatedProduct);
              if (mounted) {
                Navigator.pop(context);
                setState(() {});
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await context.read<LocalDataService>().updateOrderStatus(orderId, newStatus);
    setState(() {});
  }
} 