import 'package:flutter/material.dart';

void main() {
  runApp(const FoodMenuApp());
}

// Data Model for Food Item
class FoodItem {
  final String name;
  final double price;
  final double rating;
  final String imageUrl;
  final String category;

  const FoodItem({
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
    required this.category,
  });
}

class FoodMenuApp extends StatefulWidget {
  const FoodMenuApp({super.key});

  @override
  State<FoodMenuApp> createState() => _FoodMenuAppState();
}

class _FoodMenuAppState extends State<FoodMenuApp> {
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Custom Light ThemeData (Primary colors, text styles, custom font)
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFFD32F2F),
    scaffoldBackgroundColor: const Color(0xFFF9F9F9),
    fontFamily: 'Georgia',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD32F2F),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFD32F2F),
      foregroundColor: Colors.white,
      elevation: 2,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
    ),
  );

  // Custom Dark ThemeData (Primary colors, text styles, custom font)
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFFF9800),
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: 'Georgia',
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF9800),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Color(0xFFFF9800),
      elevation: 2,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFF9800)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Menu',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: FoodMenuScreen(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class FoodMenuScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const FoodMenuScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  static const List<FoodItem> _foodItems = [
    FoodItem(
      name: 'Grilled Chicken Burger',
      price: 280.0,
      rating: 4.8,
      category: 'Fast Food',
      imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    ),
    FoodItem(
      name: 'Margherita Wood-Fired Pizza',
      price: 550.0,
      rating: 4.9,
      category: 'Italian',
      imageUrl: 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?w=500',
    ),
    FoodItem(
      name: 'Hyderabadi Mutton Biryani',
      price: 360.0,
      rating: 4.7,
      category: 'Desi Cuisine',
      imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500',
    ),
    FoodItem(
      name: 'Creamy Alfredo Pasta',
      price: 320.0,
      rating: 4.5,
      category: 'Continental',
      imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3d5d6281298?w=500',
    ),
    FoodItem(
      name: 'Crispy Fried Chicken Bucket',
      price: 450.0,
      rating: 4.6,
      category: 'Snacks',
      imageUrl: 'https://images.unsplash.com/photo-1626645738196-c2a7c87a8f58?w=500',
    ),
    FoodItem(
      name: 'Belgian Chocolate Lava Cake',
      price: 220.0,
      rating: 4.9,
      category: 'Dessert',
      imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=500',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Food Menu'),
        actions: [
          IconButton(
            tooltip: 'Switch Theme',
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: SafeArea(
        // Responsive choice using LayoutBuilder
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWideScreen = constraints.maxWidth >= 600;

            if (!isWideScreen) {
              // Phone / Portrait: Show ListView
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 130,
                      child: FoodCard(item: _foodItems[index]),
                    ),
                  );
                },
              );
            } else {
              // Wider Screen / Landscape: Show GridView
              final int columns = constraints.maxWidth >= 900 ? 3 : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 140, // Prevents vertical overflow in landscape
                ),
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  return FoodCard(item: _foodItems[index]);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

// Reusable Custom Widget using Stack, Row, Column, and Expanded
class FoodCard extends StatelessWidget {
  final FoodItem item;

  const FoodCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Stack for Image + Rating Badge Overlay
          SizedBox(
            width: 130,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.fastfood, size: 48, color: Colors.grey),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Expanded + Column for Details (Prevents overflow)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.name,
                    style: textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.category,
                    style: textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'BDT ${item.price.toStringAsFixed(0)}',
                          style: textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}