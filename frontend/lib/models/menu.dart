import 'category.dart';

class Menu {
  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final String? image;
  final bool isAvailable;
  final Category? category;

  Menu({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.image,
    required this.isAvailable,
    this.category,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      image: json['image'],
      isAvailable: json['is_available'] == 1 || json['is_available'] == true,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}
