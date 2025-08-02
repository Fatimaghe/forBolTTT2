import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _defaultCodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _standardPriceController = TextEditingController();
  // Removed _salePriceController, use _listPriceController only
  final _listPriceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _weightController = TextEditingController();

  final ProductService _productService = ProductService();

  Uint8List? _imageBytes;
  String? _imageBase64;

  int? selectedCategId; // Odoo expects int ID
  String selectedProductType = 'consu';
  int? selectedUomId; // Odoo expects int ID
  String selectedUomName = 'Units';
  bool canBeSold = true;
  bool canBePurchased = true;

  final List<String> categories = ['Software', 'Hardware', 'Services', 'Cloud Services'];
  final List<String> productTypes = ['consu', 'service', 'product'];
  final List<String> uomOptions = ['Units', 'Hours', 'Days', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData();
    }
  }

  void _loadProductData() {
    final product = widget.product!;
    _nameController.text = product.name;
    _defaultCodeController.text = product.defaultCode;
    _descriptionController.text = product.description;
    _standardPriceController.text = product.standardPrice.toString();
    _listPriceController.text = product.listPrice.toString();
    _barcodeController.text = product.barcode;
    _weightController.text = product.weight.toString();
    selectedCategId = product.categId;
    selectedUomId = product.uomId;
    selectedProductType = product.productType;
    selectedUomName = product.uomName;
    canBeSold = product.canBeSold;
    canBePurchased = product.canBePurchased;
    if (product.image.isNotEmpty) {
      try {
        _imageBase64 = product.image;
        _imageBytes = base64Decode(product.image);
      } catch (_) {
        _imageBase64 = null;
        _imageBytes = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('DEBUG: AddProductScreen build called');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: SizedBox(
                    width: 120,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _saveProduct,
                      icon: const Icon(Icons.save),
                      label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 16),
                        elevation: 2,
                      ),
                    ),
                  ),
                ),
              ),
              // Product Image Picker
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                              )
                            : Icon(Icons.add_a_photo, size: 48, color: Colors.grey[500]),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Tap to select image', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Basic Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _defaultCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Internal Reference',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Internal Reference';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: selectedCategId?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Category ID (int)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  selectedCategId = int.tryParse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Product Type & Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Type & Settings',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: productTypes.contains(selectedProductType) ? selectedProductType : productTypes.first,
                              decoration: const InputDecoration(
                                labelText: 'Product Type',
                                border: OutlineInputBorder(),
                              ),
                              items: productTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedProductType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: selectedUomId?.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'UOM ID (int)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  selectedUomId = int.tryParse(value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Can be Sold'),
                              value: canBeSold,
                              onChanged: (value) {
                                setState(() {
                                  canBeSold = value;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: SwitchListTile(
                              title: const Text('Can be Purchased'),
                              value: canBePurchased,
                              onChanged: (value) {
                                setState(() {
                                  canBePurchased = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pricing
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pricing',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _standardPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Cost',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter cost';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid cost';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              // Removed salePrice field, use listPrice only
                              decoration: const InputDecoration(
                                labelText: 'Sale Price',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter sale price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _listPriceController,
                        decoration: const InputDecoration(
                          labelText: 'List Price',
                          border: OutlineInputBorder(),
                          prefixText: '\$ ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter list price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid price';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _barcodeController,
                              decoration: const InputDecoration(
                                labelText: 'Barcode',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProduct() async {
    print('DEBUG: _saveProduct called, widget.product=${widget.product}');
    final isValid = _formKey.currentState!.validate();
    print('DEBUG: _formKey.currentState!.validate() = $isValid');
    if (isValid) {
      final product = Product(
        id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        defaultCode: _defaultCodeController.text,
        description: _descriptionController.text,
        categId: selectedCategId,
        standardPrice: double.parse(_standardPriceController.text),
        listPrice: double.parse(_listPriceController.text),
        canBeSold: canBeSold,
        canBePurchased: canBePurchased,
        productType: selectedProductType,
        uomId: selectedUomId,
        uomName: selectedUomName,
        barcode: _barcodeController.text,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        image: _imageBase64 ?? widget.product?.image ?? '',
        createdAt: widget.product?.createdAt ?? DateTime.now(),
      );

      // Debug: print payload
      print('DEBUG: Product to save:');
      print(product.toJson());

      bool success = false;
      try {
        if (widget.product == null) {
          print('DEBUG: Entering CREATE branch');
          final id = await _productService.createProduct(product.toJson());
          print('DEBUG: Create product result: id=$id');
          success = id > 0;
        } else {
          print('DEBUG: Entering UPDATE branch');
          final updateFields = <String, dynamic>{
            'name': _nameController.text,
            'default_code': _defaultCodeController.text,
            'description': _descriptionController.text,
            'categ_id': selectedCategId,
            'standard_price': double.parse(_standardPriceController.text),
            'list_price': double.parse(_listPriceController.text),
            'sale_ok': canBeSold,
            'purchase_ok': canBePurchased,
            'type': selectedProductType,
            'uom_id': selectedUomId,
            'barcode': _barcodeController.text,
            'weight': double.tryParse(_weightController.text) ?? 0.0,
            'image_128': _imageBase64 ?? widget.product?.image ?? '',
          };
          print('DEBUG: About to call updateProduct with id=${product.id} and fields=$updateFields');
          final updateResult = await _productService.updateProduct(int.tryParse(product.id.toString()) ?? 0, updateFields);
          print('DEBUG: Update product result: $updateResult');
          success = updateResult;
        }
      } catch (e, stack) {
        print('ERROR: Exception during save: $e');
        print(stack);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        return;
      }
      if (success) {
        Navigator.pop(context, product);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save product.')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes;
        _imageBase64 = base64Encode(_imageBytes!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _defaultCodeController.dispose();
    _descriptionController.dispose();
    _standardPriceController.dispose();
    // Removed _salePriceController
    _listPriceController.dispose();
    _barcodeController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}