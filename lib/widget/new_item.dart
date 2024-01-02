import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories_data.dart';
import 'package:shopping_list/models/category_model.dart';
import 'package:shopping_list/models/grocery_item_model.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _enteredCategory = categoriesData[Categories.vegetables]!;
  var _isSending = false;

  void saveItem() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
          'shopping-list-flutter-9cc75-default-rtdb.firebaseio.com',
          'shopping-list.json');

      final response = await http.post(
        url,
        headers: {'Content-type': 'Application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _enteredCategory.title,
        }),
      );

      // print(response.body);
      // print(response.statusCode);

      // print(_enteredName);
      // print(_enteredQuantity);
      // print(_enteredCategory);

      final Map<String, dynamic> resData = json.decode(response.body);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(
        GroceryItemModel(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _enteredCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value == null ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'In Between 1 to 50 charactor';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(label: Text('Quantity')),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be valid positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _enteredCategory,
                      items: [
                        for (final category in categoriesData.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  height: 24,
                                  width: 24,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title)
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _enteredCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                width: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formkey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                    onPressed: _isSending ? null : saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Save'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
