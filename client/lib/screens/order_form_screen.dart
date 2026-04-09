import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import 'order_success_screen.dart';

class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final cart = context.read<CartService>();
      final api = ApiService();

      final result = await api.createOrder(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
        items: cart.toOrderItems(),
      );

      if (mounted) {
        cart.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderSuccessScreen(
              orderId: result['id'] ?? 0,
              totalPrice: result['total_price'] ?? 0.0,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка оформления: $e'),
            backgroundColor: const Color(0xFFFF69B4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text('Оформление', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ваш заказ', style: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513))),
                    const SizedBox(height: 12),
                    Consumer<CartService>(
                      builder: (context, cart, _) {
                        return Column(
                          children: cart.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.dessertName} × ${item.quantity}', style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A))),
                                  Text('${item.totalPrice.toStringAsFixed(0)} ₽', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFF8B4513))),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const Divider(color: Color(0xFFFFE4E8)),
                    Consumer<CartService>(
                      builder: (context, cart, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Итого:', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(
                              '${cart.totalPrice.toStringAsFixed(0)} ₽',
                              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF8B4513)),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildField('Ваше имя *', _nameController, Icons.person_outline, (v) => v == null || v.trim().isEmpty ? 'Введите имя' : null),
              const SizedBox(height: 16),
              _buildField('Телефон *', _phoneController, Icons.phone_outlined, (v) => v == null || v.trim().isEmpty ? 'Введите телефон' : null, phone: true),
              const SizedBox(height: 16),
              _buildField('Адрес доставки *', _addressController, Icons.location_on_outlined, (v) => v == null || v.trim().isEmpty ? 'Введите адрес доставки' : null),
              const SizedBox(height: 16),
              _buildMultiField('Комментарий', _commentController, Icons.chat_bubble_outline),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text('Отправить заказ', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, String? Function(String?)? validator, {bool phone = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF69B4)),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF888888), fontSize: 14),
      ),
      keyboardType: phone ? TextInputType.phone : null,
      style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A)),
      validator: validator,
    );
  }

  Widget _buildMultiField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF69B4)),
        labelStyle: GoogleFonts.poppins(color: const Color(0xFF888888), fontSize: 14),
      ),
      maxLines: 3,
      style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}
