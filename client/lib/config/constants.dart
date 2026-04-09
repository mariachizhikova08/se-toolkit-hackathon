class AppConstants {
  // API endpoints
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://localhost:18790',
  );

  // Endpoints
  static const String dessertsEndpoint = '/desserts/';
  static const String searchEndpoint = '/desserts/search';
  static const String ordersEndpoint = '/orders/';

  // Цвета
  static const int primaryColorValue = 0xFFE91E63;
  static const int secondaryColorValue = 0xFF8D6E63;
  static const int backgroundColorValue = 0xFFFFF5F5;
  static const int cardColorValue = 0xFFFFFFFF;
  static const int textColorValue = 0xFF2D2D2D;
  static const int successColorValue = 0xFF4CAF50;
  static const int errorColorValue = 0xFFF44336;
  static const int accentColorValue = 0xFFFF7043;

  // Категории
  static const Map<String, String> categoryNames = {
    'cake': 'Торт',
    'cheesecake': 'Чизкейк',
    'bakery': 'Выпечка',
    'dessert': 'Десерт',
    'portion': 'Порция',
  };

  // Эмодзи для категорий
  static const Map<String, String> categoryEmojis = {
    'cake': '🎂',
    'cheesecake': '🍰',
    'bakery': '🧁',
    'dessert': '🍮',
    'portion': '🍽️',
  };
}
