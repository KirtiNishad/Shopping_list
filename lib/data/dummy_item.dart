import 'package:shopping_list/models/grocery_item_model.dart';
import 'package:shopping_list/data/categories_data.dart';
import 'package:shopping_list/models/category_model.dart';

List<GroceryItemModel> groceryItems = [
  GroceryItemModel(
      id: 'a',
      name: 'Milk',
      quantity: 1,
      category: categoriesData[Categories.dairy]!),
  GroceryItemModel(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categoriesData[Categories.fruit]!),
  GroceryItemModel(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categoriesData[Categories.meat]!),
];
