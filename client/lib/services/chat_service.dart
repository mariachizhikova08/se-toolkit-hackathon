import 'package:flutter/foundation.dart';
import '../models/dessert.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatService extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _isTyping = false;
  List<Dessert> _desserts = [];
  final ApiService _apiService = ApiService();

  List<Dessert> get desserts => _desserts;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isTyping => _isTyping;

  /// Load real dessert data from API
  Future<void> loadDesserts() async {
    try {
      _desserts = await _apiService.getDesserts();
      _isConnected = true;
      notifyListeners();
    } catch (e) {
      _isConnected = false;
      notifyListeners();
    }
  }

  void setDesserts(List<Dessert> desserts) {
    _desserts = desserts;
    _isConnected = true;
    notifyListeners();
  }

  void addMessage(String text, {required bool isUser}) {
    _messages.add(ChatMessage(
      text: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // ─── Helper: search real desserts ───
  List<Dessert> _search(String query) {
    final q = query.toLowerCase();
    return _desserts.where((d) {
      final inName = d.name.toLowerCase().contains(q);
      final inDesc = d.description.toLowerCase().contains(q);
      final inIng = d.ingredients.any((i) => i.toString().toLowerCase().contains(q));
      return inName || inDesc || inIng;
    }).toList();
  }

  List<Dessert> _byCategory(String cat) {
    return _desserts.where((d) => d.category == cat).toList();
  }

  List<Dessert> _budget(double max) {
    return _desserts.where((d) => d.price <= max).toList();
  }

  List<Dessert> _excludeIngredients(List<String> exclude) {
    return _desserts.where((d) {
      final allText = '${d.description} ${d.ingredients.join(' ')} ${d.allergens.join(' ')}'.toLowerCase();
      return !exclude.any((e) => allText.contains(e.toLowerCase()));
    }).toList();
  }

  List<Dessert> _includeIngredients(List<String> include) {
    return _desserts.where((d) {
      final allText = '${d.description} ${d.ingredients.join(' ')}'.toLowerCase();
      return include.any((e) => allText.contains(e.toLowerCase()));
    }).toList();
  }

  String _formatDesserts(List<Dessert> list, {String intro = '', String suffix = ''}) {
    if (list.isEmpty) return 'К сожалению, ничего не нашлось по вашему запросу 😔 Попробуйте изменить запрос!';
    final items = list.map((d) => '• ${d.name} — ${d.price.toStringAsFixed(0)}₽ (${d.description})').join('\n');
    return '${intro.isNotEmpty ? "$intro\n" : ""}$items$suffix';
  }

  String _formatDessertsWithAllergens(List<Dessert> list, {String intro = ''}) {
    if (list.isEmpty) return 'К сожалению, ничего не нашлось 😔';
    final items = list.map((d) {
      final allergens = d.allergens.isNotEmpty ? ' ⚠️ ${d.allergens.join(', ')}' : '';
      return '• ${d.name} — ${d.price.toStringAsFixed(0)}₽${allergens}\n  ${d.description}';
    }).join('\n\n');
    return '${intro.isNotEmpty ? "$intro\n" : ""}$items';
  }

  // ─── Intent detection + response ───
  void _generateResponse(String userMessage) {
    final lower = userMessage.toLowerCase().trim();

    // ── Greeting ──
    if (_matches(lower, ['привет', 'здравствуй', 'добрый', 'хай', 'hello', 'hi ', 'доброе'])) {
      _reply('Привет! 🍰 Я ИИ-кондитер Katrin\'s Cakes. Помогу выбрать десерт!\n\n'
          'Спросите меня:\n'
          '• "Посоветуй шоколадное" 🍫\n'
          '• "Что без орехов?" 🥜\n'
          '• "Недорогой десерт до 300₽" 💰\n'
          '• "Состав Тирамису" 📋\n'
          '• "Добавь капкейк в корзину" 🛒');
      return;
    }

    // ── "Thank you" ──
    if (_matches(lower, ['спасибо', 'благодар'])) {
      _reply('Пожалуйста! 😊 Обращайтесь, если нужна помощь. Приятного аппетита! 🍰');
      return;
    }

    // ── Price inquiry: "сколько стоит", "цена", "прайс" ──
    if (_matches(lower, ['сколько стоит', 'какая цена', 'прайс', 'стоимость'])) {
      final found = _search(lower.replaceAll(RegExp(r'(сколько стоит|какая цена|прайс|стоимость)'), '').trim());
      if (found.isNotEmpty) {
        _reply(_formatDesserts(found, intro: '💰 Цены:'));
      } else {
        final all = _desserts.map((d) => '• ${d.name} — ${d.price.toStringAsFixed(0)}₽').join('\n');
        _reply('📋 Наш прайс:\n\n$all');
      }
      return;
    }

    // ── "What's in / composition" ──
    if (_matches(lower, ['состав', 'что входит', 'из чего', 'ингредиент'])) {
      final found = _search(lower);
      if (found.isNotEmpty) {
        final d = found.first;
        final ingredients = d.ingredients.isNotEmpty ? d.ingredients.map((i) => '• $i').join('\n') : 'Не указан';
        final allergens = d.allergens.isNotEmpty ? '\n\n⚠️ Аллергены: ${d.allergens.join(', ')}' : '';
        _reply('📋 ${d.name} (${d.price.toStringAsFixed(0)}₽):\n\n$ingredients$allergens');
      } else {
        _reply('Напишите название десерта, и я расскажу его состав! Например: "состав тирамису" 🍰');
      }
      return;
    }

    // ── "Without / exclude" — allergens ──
    if (_matches(lower, ['без ', 'что без', 'чего нет', 'нет орех', 'нет глютен', 'нет молочн', 'не содерж'])) {
      final exclusions = <String>[];
      if (lower.contains('орех')) exclusions.add('орех');
      if (lower.contains('глютен')) exclusions.add('глютен');
      if (lower.contains('молочн') || lower.contains('лактоз')) exclusions.add('молочн');
      if (lower.contains('яиц') || lower.contains('яйц')) exclusions.add('яйц');
      if (lower.contains('кофеин')) exclusions.add('кофеин');

      if (exclusions.isEmpty) {
        // Try generic search
        final found = _search(lower);
        if (found.isNotEmpty) {
          _reply(_formatDesserts(found, intro: '🔍 Нашёл:'));
        } else {
          _reply('Уточните, какие ингредиенты вас интересуют? Например: "без орехов" или "без глютена" 🌿');
        }
      } else {
        final filtered = _excludeIngredients(exclusions);
        _reply(_formatDessertsWithAllergens(filtered,
            intro: '✅ Без ${exclusions.join(', ')} у нас есть:'));
      }
      return;
    }

    // ── "With / include" — specific ingredients ──
    if (_matches(lower, ['с клубник', 'с вишн', 'с шоколад', 'с карамел', 'с маскарпон', 'с какао', 'с ягод'])) {
      final found = _search(lower);
      if (found.isNotEmpty) {
        _reply(_formatDesserts(found, intro: '🔍 Нашёл для вас:'));
      } else {
        _reply('К сожалению, не нашёл десертов по этому запросу 😔 Попробуйте иначе!');
      }
      return;
    }

    // ── Budget: "до X рублей", "недорог", "бюджет", "дешев" ──
    if (_matches(lower, ['недорог', 'бюджет', 'дешев', 'до '])) {
      final priceMatch = RegExp(r'до\s*(\d+)').firstMatch(lower);
      if (priceMatch != null) {
        final maxPrice = double.tryParse(priceMatch.group(1) ?? '0') ?? 500;
        final budget = _budget(maxPrice);
        _reply(_formatDesserts(budget, intro: '💰 Десерты до ${maxPrice.toStringAsFixed(0)}₽:'));
      } else {
        final budget = _budget(300);
        _reply(_formatDesserts(budget, intro: '💰 Бюджетные варианты (до 300₽):'));
      }
      return;
    }

    // ── Category queries ──
    if (_matches(lower, ['торт', 'на праздник', 'день рожден', 'юбилей'])) {
      final cakes = _byCategory('cake');
      _reply(_formatDesserts(cakes.isNotEmpty ? cakes : _search('торт'),
          intro: '🎂 Наши торты:'));
      return;
    }
    if (_matches(lower, ['чизкейк'])) {
      final cs = _byCategory('cheesecake');
      _reply(_formatDesserts(cs.isNotEmpty ? cs : _search('чизкейк'),
          intro: '🍰 Наши чизкейки:'));
      return;
    }
    if (_matches(lower, ['капкейк', 'маффин'])) {
      final cb = _byCategory('bakery');
      _reply(_formatDesserts(cb.isNotEmpty ? cb : _search('капкейк'),
          intro: '🧁 Наша выпечка:'));
      return;
    }
    if (_matches(lower, ['тирамису'])) {
      final found = _search('тирамису');
      _reply(_formatDesserts(found, intro: '☕ Тирамису:'));
      return;
    }
    if (_matches(lower, ['наполеон'])) {
      final found = _search('наполеон');
      _reply(_formatDesserts(found, intro: '🥐 Наполеон:'));
      return;
    }
    if (_matches(lower, ['кейк-попс', 'кейк попс', 'на палочк'])) {
      final found = _search('кейк');
      _reply(_formatDesserts(found, intro: '🍭 Кейк-попс:'));
      return;
    }
    if (_matches(lower, ['трайфл'])) {
      final found = _search('трайфл');
      _reply(_formatDesserts(found, intro: '🍮 Трайфл:'));
      return;
    }

    // ── "Add to cart" ──
    if (_matches(lower, ['добавь', 'положи', 'хочу в корзину', 'в корзину'])) {
      final found = _search(lower);
      if (found.isNotEmpty && found.length == 1) {
        _reply('✅ Отлично! Чтобы добавить "${found.first.name}" (${found.first.price.toStringAsFixed(0)}₽) в корзину:\n\n'
            '1. Перейдите в каталог 🏠\n'
            '2. Нажмите "В корзину" на карточке\n\n'
            'Могу ещё помочь с выбором? 😊');
      } else if (found.length > 1) {
        _reply('Какой именно десерт хотите?\n\n${_formatDesserts(found)}\n\n'
            'Напишите точнее, и я подскажу! 😊');
      } else {
        _reply('Не нашла такой десерт 😅 Посмотрите каталог — там все наши десерты с фото и ценами!');
      }
      return;
    }

    // ── "Order / checkout" ──
    if (_matches(lower, ['заказ', 'оформ', 'купить', 'заказать'])) {
      _reply('Чтобы оформить заказ:\n\n'
          '1. Добавьте десерты в корзину 🛒 (кнопка на карточке)\n'
          '2. Откройте корзину (иконка сверху)\n'
          '3. Нажмите "Оформить заказ"\n'
          '4. Заполните: имя, телефон, адрес\n\n'
          'Могу помочь с выбором десерта! Просто спросите 😊');
      return;
    }

    // ── "Recommend / suggest / top / best" ──
    if (_matches(lower, ['посоветуй', 'рекоменд', 'лучш', 'топ', 'что выбрать', 'что скажешь', 'помоги выбрать'])) {
      final top = _desserts.take(5).toList();
      _reply(_formatDesserts(top,
          intro: '🏆 Мои рекомендации — самые популярные позиции:',
          suffix: '\n\nХотите узнать подробнее о каком-то десерте?'));
      return;
    }

    // ── "Chocolate" generic ──
    if (lower.contains('шоколад')) {
      final found = _search('шоколад');
      _reply(_formatDesserts(found.isNotEmpty ? found : _desserts,
          intro: found.isNotEmpty ? '🍫 Вот десерты с шоколадом:' : '🍫 Шоколадные десерты:'));
      return;
    }

    // ── Fallback: try general search ──
    {
      final found = _search(lower);
      if (found.isNotEmpty) {
        _reply(_formatDesserts(found, intro: '🔍 Нашла для вас:'));
        return;
      }
    }

    // ── Ultimate fallback ──
    _reply('Интересный вопрос! 🤔 Я могу помочь с:\n\n'
        '• Рекомендациями по вкусу — "посоветуй шоколадное"\n'
        '• Поиском по ингредиентам — "с клубникой"\n'
        '• Фильтрацией по аллергенам — "без орехов"\n'
        '• Бюджетными вариантами — "до 300 рублей"\n'
        '• Составом десертов — "состав Тирамису"\n'
        '• Оформлением заказа 🛒\n\n'
        'Просто спросите! 🍰');
  }

  bool _matches(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  void _reply(String text) {
    _isTyping = false;
    addMessage(text, isUser: false);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    addMessage(text, isUser: true);
    _isConnected = true;
    _isTyping = true;
    notifyListeners();

    // Simulate thinking delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_desserts.isEmpty) {
        // Load data first
        loadDesserts().then((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _generateResponse(text);
          });
        }).catchError((_) {
          _generateResponse(text);
        });
      } else {
        _generateResponse(text);
      }
    });
  }

  void clear() {
    _messages.clear();
    _isConnected = true;
    notifyListeners();
  }
}
