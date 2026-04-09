import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/constants.dart';
import '../models/dessert.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/chat_service.dart';
import '../widgets/dessert_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/hero_banner.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'my_orders_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _catalogKey = GlobalKey();
  List<Dessert> _desserts = [];
  List<Dessert> _filteredDesserts = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadDesserts();
  }

  Future<void> _loadDesserts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final desserts = await _apiService.getDesserts();
      setState(() {
        _desserts = desserts;
        _filteredDesserts = desserts;
        _isLoading = false;
      });
      if (mounted) {
        context.read<ChatService>().setDesserts(desserts);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    var result = _desserts;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) =>
          d.name.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q) ||
          d.ingredients.any((i) => i.toString().toLowerCase().contains(q))).toList();
    }
    if (_selectedCategory != 'all') {
      result = result.where((d) => d.category == _selectedCategory).toList();
    }
    setState(() => _filteredDesserts = result);
  }

  void _onSearch(String query) {
    setState(() => _searchQuery = query);
    _applyFilters();
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  void _scrollToCatalog() {
    final context = _catalogKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : (width > 600 ? 3 : 2);
    final padding = width > 900 ? 32.0 : (width > 600 ? 24.0 : 16.0);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF4A4A4A),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Katrin\'s Cakes',
          style: GoogleFonts.greatVibes(
            fontSize: 30,
            color: const Color(0xFFFF69B4),
          ),
        ),
        actions: [
          // My Orders
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined, size: 28),
            tooltip: 'Мои заказы',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyOrdersScreen()),
            ),
          ),
          // Cart
          Consumer<CartService>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, size: 28),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Center(
                          child: Text(
                            '${cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            HeroBanner(onBrowseTap: _scrollToCatalog),

            // Search + Filter bar
            Padding(
              padding: EdgeInsets.fromLTRB(padding, 24, padding, 0),
              child: SearchBarWidget(onSearch: _onSearch),
            ),

            // Categories
            Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'best deals for you',
                    style: GoogleFonts.dancingScript(
                      fontSize: 22,
                      color: const Color(0xFFD4A5A5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'НАШИ ХИТЫ',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B4513),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _categoryChip('all', '✨ Все'),
                        _categoryChip('cake', '🎂 Торты'),
                        _categoryChip('cheesecake', '🍰 Чизкейки'),
                        _categoryChip('bakery', '🧁 Выпечка'),
                        _categoryChip('portion', '🍽️ Порции'),
                        _categoryChip('dessert', '🍮 Десерты'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Desserts grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: SizedBox(
                key: _catalogKey,
                child: _isLoading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(color: Color(0xFFFFB6C1)),
                      ))
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(48),
                              child: Column(
                                children: [
                                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text('Ошибка загрузки', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: _loadDesserts,
                                    child: const Text('Попробовать снова'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredDesserts.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(48),
                                  child: Column(
                                    children: [
                                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                      const SizedBox(height: 16),
                                      Text('Ничего не найдено', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              )
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: width > 900 ? 24 : 16,
                                  mainAxisSpacing: width > 900 ? 24 : 16,
                                ),
                                itemCount: _filteredDesserts.length,
                                itemBuilder: (context, index) {
                                  final dessert = _filteredDesserts[index];
                                  return DessertCardWidget(
                                    dessert: dessert,
                                    onAddToCart: () {
                                      context.read<CartService>().addToCart(dessert);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${dessert.name} добавлен в корзину'),
                                          backgroundColor: const Color(0xFF8B4513),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      floatingActionButton: Animate(
        effects: [ScaleEffect(delay: 800.ms, duration: 300.ms, curve: Curves.elasticOut)],
        child: SizedBox(
          width: 72,
          height: 72,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
            backgroundColor: const Color(0xFFFFB6C1),
            foregroundColor: Colors.white,
            elevation: 8,
            child: const Icon(Icons.smart_toy, size: 34),
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(String value, String label) {
    final isSelected = _selectedCategory == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
        selected: isSelected,
        onSelected: (_) => _onCategoryChanged(value),
        selectedColor: const Color(0xFFFFB6C1).withOpacity(0.3),
        checkmarkColor: const Color(0xFFFF69B4),
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFFFF69B4) : Colors.grey[300]!,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF8B4513) : const Color(0xFF4A4A4A),
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
    );
  }
}
