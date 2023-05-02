import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class _FormProduct {
  String? id;
  String? title;
  String? description;
  double? price;
  String? imageUrl;
  bool isFav = false;

  // ignore: unused_element
  _FormProduct({this.title, this.description, this.price, this.imageUrl});
}

class EditProductScreen extends StatefulWidget {
  static const route = '/editProduct';
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  // Creating a focus node is required to navigate to a different input field
  // when the user taps the enter button. In this version,
  // I found that it is not required as flutter automatically focuses on the next input field.
  final _priceFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  // ignore: prefer_final_fields
  var _editedProduct = _FormProduct();
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments as String?;
      // print(productId);
      if (productId != null) {
        final product =
            Provider.of<Products>(context, listen: false).findById(productId);
        _editedProduct.id = productId;
        _editedProduct.description = product.description;
        _editedProduct.title = product.title;
        _imageUrlController.text = product.imageUrl;
        _editedProduct.price = product.price;
        _editedProduct.isFav = product.isFavorite;
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    // Focus nodes need to be disposed after the field is removed.
    _priceFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    setState(() {
      _isLoading = true;
    });

    // Run the validator functions for all the input fields
    final isValid = _form.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    // Call the onSaved callback function for all the input fields
    _form.currentState?.save();
    var id = _editedProduct.id ?? DateTime.now().toString();
    var prod = Product(
      id: id,
      title: _editedProduct.title as String,
      description: _editedProduct.description as String,
      price: _editedProduct.price as double,
      imageUrl: _editedProduct.imageUrl as String,
      isFavorite: _editedProduct.isFav,
    );

    // print(prod.description);

    if (_editedProduct.id != null) {
      // To Edit an already existing product.
      await Provider.of<Products>(context, listen: false)
          .updateProduct(prod.id, prod);
    } else {
      // Add a new Product
      // print("Adding a new Product.");
      try {
        await Provider.of<Products>(context, listen: false).addProduct(prod);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('An error occurred.'),
            content: const Text("Something went wrong.."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Close'),
              )
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product.'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Title'),
                        initialValue: _editedProduct.title,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_priceFocusNode);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a value';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          _editedProduct.title = newValue;
                        },
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Price'),
                        initialValue: _editedProduct.price?.toString() ?? '',
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please provide a value';
                          } else if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          } else if (double.parse(value) <= 0) {
                            return 'Please enter a number greater than 0';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          _editedProduct.price =
                              double.parse(newValue as String);
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                        maxLines: 3,
                        initialValue: _editedProduct.description,
                        keyboardType: TextInputType.multiline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          } else if (value.length < 10) {
                            return 'Description should be atleast 10 characters.';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          _editedProduct.description = newValue;
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Enter URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image Url'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageUrlController,
                              focusNode: _imageUrlFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a image url';
                                } else if (!value.startsWith('http') &&
                                    !value.startsWith('https')) {
                                  return 'Please enter a valid url';
                                } else if (!value.endsWith('png') &&
                                    !value.endsWith('jpeg') &&
                                    !value.endsWith('jpg')) {
                                  return 'Please provide a url for an image.';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (newValue) {
                                _editedProduct.imageUrl = newValue;
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
