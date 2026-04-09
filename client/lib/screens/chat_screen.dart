import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/constants.dart';
import '../services/chat_service.dart';
import '../widgets/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = context.read<ChatService>();
      // Load real dessert data if not already loaded
      if (chatService.desserts.isEmpty) {
        chatService.loadDesserts();
      }
      if (chatService.messages.isEmpty) {
        chatService.addMessage(
          'Привет! 🍰 Я ваш ИИ-кондитер в Katrin\'s Cakes. Помогу выбрать идеальный десерт! Спросите меня про:\n\n'
          '• "Посоветуй шоколадное" 🍫\n'
          '• "Что без орехов?" 🥜\n'
          '• "Недорогой десерт до 300₽" 💰\n'
          '• "Состав Тирамису" 📋\n'
          '• "Добавь капкейк в корзину" 🛒',
          isUser: false,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<ChatService>().sendMessage(text);
    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      appBar: AppBar(
        title: Text('ИИ-кондитер', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: const Color(0xFF4A4A4A))),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, chatService, _) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: chatService.messages.length + (chatService.isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (chatService.isTyping && index == chatService.messages.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
                            ),
                            const SizedBox(width: 10),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFB6C1)),
                            ),
                            const SizedBox(width: 10),
                            Text('Печатает...', style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF888888))),
                          ],
                        ),
                      );
                    }
                    final msg = chatService.messages[index];
                    return ChatMessageBubble(
                      text: msg.text,
                      isUser: msg.isUser,
                      timestamp: msg.timestamp,
                    );
                  },
                );
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Напишите сообщение...',
                        hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.poppins(color: const Color(0xFF4A4A4A)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFB6C1), Color(0xFFFF69B4)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF69B4).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 22),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
