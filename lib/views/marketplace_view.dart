import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketplaceView extends StatefulWidget {
  const MarketplaceView({super.key});

  @override
  State<MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<MarketplaceView> {
  String _selectedCategory = 'Tous';
  
  final List<String> _categories = [
    'Tous',
    'Volailles',
    'Bovins',
    'Ovins',
    'Caprins',
    'Matériel',
    'Aliments'
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Poulets de Chair - Lot Premium',
      'seller': 'Ferme Kouassi',
      'price': '2,500 F',
      'location': 'Abidjan, Cocody',
      'category': 'Volailles',
      'image': Icons.egg_alt,
      'rating': 4.8,
      'inStock': true,
      'quantity': '500 sujets disponibles',
    },
    {
      'name': 'Aliment Ponte Enrichi 25kg',
      'seller': 'SIPRA Nutrition',
      'price': '18,000 F',
      'location': 'Abidjan, Yopougon',
      'category': 'Aliments',
      'image': Icons.grain,
      'rating': 4.9,
      'inStock': true,
      'quantity': '50 sacs en stock',
    },
    {
      'name': 'Vaches Laitières Holstein',
      'seller': 'Ranch Bété',
      'price': '450,000 F',
      'location': 'Yamoussoukro',
      'category': 'Bovins',
      'image': Icons.pets,
      'rating': 4.7,
      'inStock': true,
      'quantity': '12 têtes disponibles',
    },
    {
      'name': 'Incubateur Automatique 500 œufs',
      'seller': 'AgroTech CI',
      'price': '850,000 F',
      'location': 'Bouaké',
      'category': 'Matériel',
      'image': Icons.device_thermostat,
      'rating': 4.6,
      'inStock': false,
      'quantity': 'Sur commande',
    },
    {
      'name': 'Chèvres Sahéliennes',
      'seller': 'Élevage Nordique',
      'price': '75,000 F',
      'location': 'Korhogo',
      'category': 'Caprins',
      'image': Icons.grass,
      'rating': 4.5,
      'inStock': true,
      'quantity': '25 têtes disponibles',
    },
    {
      'name': 'Moutons Djallonké',
      'seller': 'Ferme Traditionelle',
      'price': '120,000 F',
      'location': 'Man',
      'category': 'Ovins',
      'image': Icons.pets,
      'rating': 4.8,
      'inStock': true,
      'quantity': '15 têtes disponibles',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _selectedCategory == 'Tous' 
        ? _products 
        : _products.where((product) => product['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Statistiques du marketplace
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Produits',
                      '1,847',
                      Icons.inventory,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      'Vendeurs',
                      '234',
                      Icons.store,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

            // Filtres par catégorie
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: Colors.green[700]?.withOpacity(0.2),
                      checkmarkColor: Colors.green[700],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green[700] : Colors.grey[600],
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Liste des produits
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return _buildProductCard(product);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-product'),
        backgroundColor: Colors.green[700],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Vendre',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Image du produit (simulée avec une icône)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.green[700]?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  product['image'],
                  color: Colors.green[700],
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              
              // Informations principales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: product['inStock'] 
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            product['inStock'] ? 'En stock' : 'Sur commande',
                            style: TextStyle(
                              color: product['inStock'] ? Colors.green[700] : Colors.orange[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['seller'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          product['location'],
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          product['rating'].toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Prix et quantité
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['price'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Text(
                    product['quantity'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat, size: 16),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: product['inStock'] ? () {} : null,
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Acheter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}