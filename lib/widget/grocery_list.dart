import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories_data.dart';

import 'package:shopping_list/models/grocery_item_model.dart';
import 'package:shopping_list/widget/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItemModel> _groceryitem = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'shopping-list-flutter-9cc75-default-rtdb.firebaseio.com',
        'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to frtch data, try again after some time';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);

      final List<GroceryItemModel> lodedItem = [];

      for (final item in listData.entries) {
        final category = categoriesData.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;

        lodedItem.add(
          GroceryItemModel(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryitem = lodedItem;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'No Item Added Yet, Add new Item!';
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItemModel>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryitem.add(newItem);
    });
  }

  void _removeItem(GroceryItemModel item) async {
    final index = _groceryitem.indexOf(item);
    setState(() {
      _groceryitem.remove(item);
    });

    final url = Uri.https(
        'shopping-list-flutter-9cc75-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryitem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No Item Added Yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    }

    if (_groceryitem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryitem.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryitem[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryitem[index]);
          },
          child: ListTile(
            title: Text(_groceryitem[index].name),
            leading: Container(
              height: 24,
              width: 24,
              color: _groceryitem[index].category.color,
            ),
            trailing: Text(_groceryitem[index].quantity.toString()),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Grocery'),
        actions: [IconButton(onPressed: addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
