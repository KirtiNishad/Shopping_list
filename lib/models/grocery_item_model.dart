import 'package:shopping_list/models/category_model.dart';

class GroceryItemModel {
  const GroceryItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id;
  final String name;
  final int quantity;
  final CategoryModel category;
}
