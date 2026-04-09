import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await _apiService.listOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    const statusMap = {
      'pending': '⏳ Ожидает',
      'confirmed': '✅ Подтверждён',
      'preparing': '👨‍🍳 Готовится',
      'delivered': '🚗 Доставлен',
      'cancelled': '❌ Отменён',
    };
    return statusMap[status] ?? status;
  }

  Color _getStatusColor(String status) {
    const colorMap = {
      'pending': 0xFFFFB6C1,
      'confirmed': 0xFF4CAF50,
      'preparing': 0xFFFF69B4,
      'delivered': 0xFF4CAF50,
      'cancelled': 0xFFF44336,
    };
    return Color(colorMap[status] ?? 0xFF4A4A4A);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text('Мои заказы', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A))),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        color: const Color(0xFFFF69B4),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFB6C1)))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Ошибка загрузки', style: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFF888888))),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _loadOrders, child: const Text('Попробовать снова')),
                      ],
                    ),
                  )
                : _orders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80, color: const Color(0xFFFFB6C1)),
                            const SizedBox(height: 20),
                            Text(
                              'У вас пока нет заказов',
                              style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Выберите десерты в каталоге!',
                              style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF888888)),
                            ),
                            const SizedBox(height: 28),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const HomeScreen()),
                                (route) => false,
                              ),
                              icon: const Icon(Icons.cake),
                              label: const Text('Перейти в каталог'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _orders.length,
                        itemBuilder: (context, index) {
                          final order = _orders[index];
                          return _OrderCard(
                            order: order,
                            statusText: _getStatusText(order['status'] ?? 'pending'),
                            statusColor: _getStatusColor(order['status'] ?? 'pending'),
                          ).animate(delay: (index * 80).ms).fadeIn().slideY(begin: 0.06, end: 0);
                        },
                      ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final String statusText;
  final Color statusColor;

  const _OrderCard({
    required this.order,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List? ?? [];
    final createdAt = order['created_at'] != null
        ? DateTime.tryParse(order['created_at'].toString())
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [statusColor.withOpacity(0.2), statusColor.withOpacity(0.1)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '#${order['id']}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Заказ #${order['id']}',
              style: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusText,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (createdAt != null)
              Text(
                '${createdAt.day}.${createdAt.month}.${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF888888)),
              ),
            Text(
              '${order['total_price'].toStringAsFixed(0)} ₽ • ${items.length} поз.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF8B4513)),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: Color(0xFFFFE4E8)),
                Text('Состав заказа:', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF4A4A4A))),
                const SizedBox(height: 8),
                ...items.map<Widget>((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item['name']} × ${item['quantity']}', style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A))),
                          Text('${(item['price'] * item['quantity']).toStringAsFixed(0)} ₽', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF8B4513))),
                        ],
                      ),
                    )),
                const Divider(color: Color(0xFFFFE4E8)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Итого:', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${order['total_price'].toStringAsFixed(0)} ₽',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
                    ),
                  ],
                ),
                if (order['address'] != null && order['address'].toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFFFF69B4)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(order['address'], style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A)))),
                    ],
                  ),
                ],
                if (order['comment'] != null && order['comment'].toString().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFFFF69B4)),
                      const SizedBox(width: 6),
                      Expanded(child: Text(order['comment'], style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A)))),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
