class Dessert {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<dynamic> ingredients;
  final List<dynamic> allergens;
  final bool available;
  final String? imageUrl;

  Dessert({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.category = 'other',
    this.ingredients = const [],
    this.allergens = const [],
    this.available = true,
    this.imageUrl,
  });

  factory Dessert.fromJson(Map<String, dynamic> json) {
    return Dessert(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? 'other',
      ingredients: json['ingredients'] ?? [],
      allergens: json['allergens'] ?? [],
      available: json['available'] ?? true,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'ingredients': ingredients,
      'allergens': allergens,
      'available': available,
      'image_url': imageUrl,
    };
  }
}
