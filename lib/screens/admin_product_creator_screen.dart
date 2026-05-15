import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:url_launcher/url_launcher.dart';
import '../models/admin_product_model.dart';
import '../services/cloudflare_product_api.dart';
import '../utils/admin_id_generator.dart';
import '../widgets/admin_shared_widgets.dart';

class AdminProductCreatorScreen extends StatefulWidget {
  final AdminProductModel? existingProduct;

  const AdminProductCreatorScreen({super.key, this.existingProduct});

  @override
  State<AdminProductCreatorScreen> createState() =>
      _AdminProductCreatorScreenState();
}

class _AdminProductCreatorScreenState extends State<AdminProductCreatorScreen> {
  final formKey = GlobalKey<FormState>();
  final ImagePicker imagePicker = ImagePicker();
  final CloudflareProductApi imageApi = CloudflareProductApi();

  final titleController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final mainImageController = TextEditingController();
  final caloriesController = TextEditingController(text: '0');
  final List<AdminBulkBoxInput> bulkBoxInputs = [];
  final bulkTemplateNameController = TextEditingController();
  final List<AdminMixItemInput> mixItemInputs = [];

  String? selectedCategory;
  final categoryController = TextEditingController();
  bool isDietFriendly = false;
  bool isCustomizable = false;
  bool isNewArrival = false;
  bool isUploadingImage = false;

  final List<AdminOptionInput> optionInputs = [];
  final List<AdminVariantInput> variantInputs = [];

  // Bulk defaults for generated variants
  final defaultPriceController = TextEditingController(text: '0');
  final defaultWeightController = TextEditingController(text: '0');
  final defaultStockController = TextEditingController(text: '0');

  final categories = const [
    'dates',
    'bars',
    'spoons',
    'mix',
    'bulk',
    'marshmallow',
  ];

  bool get needsBulkConfig =>
      selectedCategory == 'bulk' || selectedCategory == 'mix' || isCustomizable;

  @override
  void initState() {
    super.initState();

    final product = widget.existingProduct;

    if (product == null) {
      bulkTemplateNameController.text = '1/3 Mix Template';
      bulkBoxInputs.add(AdminBulkBoxInput()..nameController.text = 'Small Box'..weightController.text = '500'..priceController.text = '50');
      bulkBoxInputs.add(AdminBulkBoxInput()..nameController.text = 'Medium Box'..weightController.text = '1000'..priceController.text = '90');
      bulkBoxInputs.add(AdminBulkBoxInput()..nameController.text = 'Large Box'..weightController.text = '2000'..priceController.text = '160');
      optionInputs.add(AdminOptionInput());
      return;
    }

    titleController.text = product.title;
    descriptionArController.text = product.descriptionAr;
    descriptionEnController.text = product.descriptionEn.isNotEmpty
        ? product.descriptionEn
        : product.description;
    mainImageController.text = product.mainImage;
    caloriesController.text = product.metadata.caloriesPer100g.toString();

    selectedCategory = product.category;
    categoryController.text = selectedCategory ?? '';
    isDietFriendly = product.isDietFriendly;
    isCustomizable = product.isCustomizable;
    isNewArrival = product.metadata.isNewArrival;

    final bulkConfig = product.bulkConfig;
    if (bulkConfig != null) {
      final boxes = bulkConfig.boxes;
      for (final box in boxes) {
        bulkBoxInputs.add(
          AdminBulkBoxInput()
            ..nameController.text = box.title
            ..weightController.text = box.weightG.toString()
            ..priceController.text = box.price.toString()
        );
      }

      if (bulkConfig.preMadeTemplates.isNotEmpty) {
        final template = bulkConfig.preMadeTemplates.first;
        final partitions = Map<String, dynamic>.from(
          template['partitions'] ?? {},
        );

        bulkTemplateNameController.text = template['name']?.toString() ?? '';
        
        partitions.forEach((key, value) {
          double ratio = 0;
          List<AdminMixSubItemInput> parsedItems = [];
          
          if (value is num) {
            ratio = value.toDouble();
          } else if (value is Map) {
            ratio = (value['ratio'] as num?)?.toDouble() ?? 0;
            if (value['items'] != null) {
              final itemsList = value['items'] as List<dynamic>;
              for (final item in itemsList) {
                if (item is Map) {
                  parsedItems.add(
                    AdminMixSubItemInput()
                      ..nameController.text = item['name']?.toString() ?? ''
                      ..imageController.text = item['image']?.toString() ?? ''
                  );
                }
              }
            } else if (value['images'] != null) {
              final imagesList = List<String>.from(value['images'] ?? []);
              for (final img in imagesList) {
                parsedItems.add(AdminMixSubItemInput()..imageController.text = img);
              }
            }
          }

          mixItemInputs.add(
            AdminMixItemInput()
              ..nameController.text = key
              ..ratioController.text = ratio.toString()
              ..items.addAll(parsedItems),
          );
        });
      }
    }

    if (mixItemInputs.isEmpty) {
      mixItemInputs.add(AdminMixItemInput()..nameController.text = 'dark'..ratioController.text = '0.33');
      mixItemInputs.add(AdminMixItemInput()..nameController.text = 'milk'..ratioController.text = '0.33');
      mixItemInputs.add(AdminMixItemInput()..nameController.text = 'white'..ratioController.text = '0.34');
    }

    if (bulkBoxInputs.isEmpty) {
      bulkBoxInputs.add(AdminBulkBoxInput()..nameController.text = 'Small Box'..weightController.text = '500'..priceController.text = '50');
    }

    if (bulkTemplateNameController.text.trim().isEmpty) {
      bulkTemplateNameController.text = '1/3 Mix Template';
    }

    for (final option in product.options) {
      optionInputs.add(
        AdminOptionInput()
          ..nameController.text = option.name
          ..valuesController.text = option.values.join(', '),
      );
    }

    for (final variant in product.variants) {
      variantInputs.add(
        _buildVariantInput(
          existingId: variant.id,
          title: variant.title,
          attributes: variant.attributes,
          price: variant.price.toString(),
          weight: variant.weightG.toString(),
          stock: variant.stockQuantity.toString(),
          image: variant.image ?? '',
          images: variant.images.join(', '),
        ),
      );
    }

    if (optionInputs.isEmpty) {
      optionInputs.add(AdminOptionInput());
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    categoryController.dispose();
    mainImageController.dispose();
    caloriesController.dispose();
    bulkTemplateNameController.dispose();
    for (final box in bulkBoxInputs) {
      box.dispose();
    }
    for (final mix in mixItemInputs) {
      mix.dispose();
    }

    for (final option in optionInputs) {
      option.dispose();
    }

    for (final variant in variantInputs) {
      variant.dispose();
    }

    defaultPriceController.dispose();
    defaultWeightController.dispose();
    defaultStockController.dispose();

    super.dispose();
  }

  AdminVariantInput _buildVariantInput({
    String? existingId,
    required String title,
    required Map<String, String> attributes,
    String price = '',
    String weight = '',
    String stock = '0',
    String image = '',
    String images = '',
  }) {
    final input = AdminVariantInput(
      existingId: existingId,
      title: title,
      attributes: attributes,
    );

    input.priceController.text = price;
    input.weightController.text = weight;
    input.stockController.text = stock;
    input.imageController.text = image;
    input.imagesController.text = images;

    return input;
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> pickAndUploadImage({String folder = 'products'}) async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return null;
      }

      if (mounted) {
        setState(() {
          isUploadingImage = true;
        });
      }

      final bytes = await pickedFile.readAsBytes();

      return await imageApi.uploadImageBytes(
        bytes: bytes,
        filename: pickedFile.name,
        folder: folder,
      );
    } catch (error) {
      if (mounted) {
        showMessage('Image upload failed: $error');
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

  Future<void> pickAndUploadMultipleImages({
    required AdminMixItemInput targetMix,
    String folder = 'products',
  }) async {
    try {
      final pickedFiles = await imagePicker.pickMultiImage();

      if (pickedFiles.isEmpty) {
        return;
      }

      if (mounted) {
        setState(() {
          isUploadingImage = true;
        });
      }

      for (final pickedFile in pickedFiles) {
        final bytes = await pickedFile.readAsBytes();
        final url = await imageApi.uploadImageBytes(
          bytes: bytes,
          filename: pickedFile.name,
          folder: folder,
        );
        if (mounted) {
          targetMix.items.add(AdminMixSubItemInput()..imageController.text = url);
          setState(() {});
        }
      }
    } catch (error) {
      if (mounted) {
        showMessage('Image upload failed: $error');
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploadingImage = false;
        });
      }
    }
  }

  void _syncMixItemsToCsv(AdminMixItemInput mix) {
    final buffer = StringBuffer();
    for (final item in mix.items) {
      final n = item.nameController.text.trim();
      final u = item.imageController.text.trim();
      if (n.isNotEmpty && u.isNotEmpty) {
        if (mix.csvTitleFirst) {
          buffer.writeln('$n, $u');
        } else {
          buffer.writeln('$u, $n');
        }
      } else if (n.isNotEmpty) {
        buffer.writeln(n);
      } else if (u.isNotEmpty) {
        buffer.writeln(u);
      }
    }
    mix.csvController.text = buffer.toString();
  }

  void _syncMixItemsFromCsv(AdminMixItemInput mix) {
    final text = mix.csvController.text.trim();
    mix.items.clear();
    if (text.isEmpty) return;

    final parts = text.split(RegExp(r'[,\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    if (mix.csvTitleFirst) {
      String? currentName;
      for (final part in parts) {
        if (part.startsWith('http://') || part.startsWith('https://')) {
          if (currentName != null) {
            mix.items.add(AdminMixSubItemInput()
              ..nameController.text = currentName
              ..imageController.text = part);
            currentName = null;
          } else {
            mix.items.add(AdminMixSubItemInput()..imageController.text = part);
          }
        } else {
          if (currentName != null) {
            mix.items.add(AdminMixSubItemInput()..nameController.text = currentName);
          }
          currentName = part;
        }
      }
      if (currentName != null) {
        mix.items.add(AdminMixSubItemInput()..nameController.text = currentName);
      }
    } else {
      // Link then Title
      String? currentUrl;
      for (final part in parts) {
        if (part.startsWith('http://') || part.startsWith('https://')) {
          if (currentUrl != null) {
            mix.items.add(AdminMixSubItemInput()..imageController.text = currentUrl);
          }
          currentUrl = part;
        } else {
          if (currentUrl != null) {
            mix.items.add(AdminMixSubItemInput()
              ..nameController.text = part
              ..imageController.text = currentUrl);
            currentUrl = null;
          } else {
            mix.items.add(AdminMixSubItemInput()..nameController.text = part);
          }
        }
      }
      if (currentUrl != null) {
        mix.items.add(AdminMixSubItemInput()..imageController.text = currentUrl);
      }
    }
  }

  Future<void> _downloadImage(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) showMessage('Could not open image: $urlString');
    }
  }

  List<AdminProductOption> getOptions() {
    return optionInputs
        .map((input) {
          final name = input.nameController.text.trim();
          final values = input.valuesController.text
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();

          return AdminProductOption(name: name, values: values);
        })
        .where((option) => option.name.isNotEmpty && option.values.isNotEmpty)
        .toList();
  }

  List<Map<String, String>> generateCombinations(
    List<AdminProductOption> options,
  ) {
    List<Map<String, String>> result = [{}];

    for (final option in options) {
      final List<Map<String, String>> newResult = [];

      for (final existing in result) {
        for (final value in option.values) {
          newResult.add({
            ...existing,
            option.name.toLowerCase().replaceAll(' ', '_'): value,
          });
        }
      }

      result = newResult;
    }

    return result;
  }

  String getVariantKey({
    required String title,
    required Map<String, String> attributes,
  }) {
    if (attributes.isEmpty) {
      return 'title:$title';
    }

    final keys = attributes.keys.toList()..sort();

    return keys.map((key) => '$key=${attributes[key]}').join('|');
  }

  void addMixItem() {
    setState(() {
      mixItemInputs.add(AdminMixItemInput());
    });
  }

  void removeMixItem(int index) {
    setState(() {
      mixItemInputs[index].dispose();
      mixItemInputs.removeAt(index);
    });
  }

  void addOption() {
    setState(() {
      optionInputs.add(AdminOptionInput());
    });
  }

  void addStandardChocolateTemplate() {
    setState(() {
      optionInputs.clear();
      optionInputs.add(
        AdminOptionInput()
          ..nameController.text = 'Size'
          ..valuesController.text = 'Small, Medium, Large',
      );
      optionInputs.add(
        AdminOptionInput()
          ..nameController.text = 'Flavor'
          ..valuesController.text = 'Milk, Dark, White',
      );
    });
  }

  void removeOption(int index) {
    setState(() {
      optionInputs[index].dispose();
      optionInputs.removeAt(index);
    });
  }

  void generateVariants() {
    final options = getOptions();
    final combinations = generateCombinations(options);
    final existingDrafts = <String, _AdminVariantDraft>{};

    for (final variant in variantInputs) {
      existingDrafts[getVariantKey(
        title: variant.title,
        attributes: variant.attributes,
      )] = _AdminVariantDraft(
        existingId: variant.existingId,
        price: variant.priceController.text,
        weight: variant.weightController.text,
        stock: variant.stockController.text,
        image: variant.imageController.text,
        images: variant.imagesController.text,
      );
      variant.dispose();
    }

    variantInputs.clear();

    final baseTitle = titleController.text.trim();

    for (final combination in combinations) {
      final generatedTitle = combination.isEmpty
          ? (baseTitle.isNotEmpty ? baseTitle : 'Default Variant')
          : combination.values.join(' ');
      final key = getVariantKey(title: generatedTitle, attributes: combination);
      final draft = existingDrafts[key];

      final dPrice = defaultPriceController.text.trim();
      final dWeight = defaultWeightController.text.trim();
      final dStock = defaultStockController.text.trim();

      variantInputs.add(
        _buildVariantInput(
          existingId: draft?.existingId,
          title: generatedTitle,
          attributes: combination,
          price: (draft?.price.isNotEmpty ?? false) ? draft!.price : dPrice,
          weight: (draft?.weight.isNotEmpty ?? false) ? draft!.weight : dWeight,
          stock: (draft?.stock.isNotEmpty ?? false) ? draft!.stock : dStock,
          image: draft?.image ?? '',
          images: draft?.images ?? '',
        ),
      );
    }

    setState(() {});
  }

  bool validateVariants() {
    if (selectedCategory == 'bulk') return true;

    if (variantInputs.isEmpty) {
      showMessage('Generate variants before saving');
      return false;
    }

    for (final variant in variantInputs) {
      final price = double.tryParse(variant.priceController.text.trim());
      final weight = double.tryParse(variant.weightController.text.trim());
      final stock = int.tryParse(variant.stockController.text.trim());

      if (price == null || price <= 0) {
        showMessage('${variant.title} needs a valid price');
        return false;
      }

      if (weight == null || weight <= 0) {
        showMessage('${variant.title} needs a valid weight');
        return false;
      }

      if (stock == null || stock < 0) {
        showMessage('${variant.title} needs valid stock quantity');
        return false;
      }
    }

    return true;
  }

  bool validateBulkConfig() {
    if (!needsBulkConfig) {
      return true;
    }

    if (bulkBoxInputs.isEmpty) {
      showMessage('Bulk products need at least one box size');
      return false;
    }

    for (final box in bulkBoxInputs) {
      if (box.nameController.text.trim().isEmpty) {
        showMessage('All boxes must have a name');
        return false;
      }
      final price = double.tryParse(box.priceController.text.trim());
      if (price == null || price <= 0) {
        showMessage('All boxes must have a valid price');
        return false;
      }
      final weight = double.tryParse(box.weightController.text.trim());
      if (weight == null || weight <= 0) {
        showMessage('All boxes must have a valid weight');
        return false;
      }
    }

    final templateName = bulkTemplateNameController.text.trim();
    
    double total = 0;
    for (final mix in mixItemInputs) {
      final ratio = double.tryParse(mix.ratioController.text.trim());
      if (ratio == null || ratio < 0) {
        showMessage('All mix ratios must be valid positive numbers');
        return false;
      }
      total += ratio;
    }

    if (templateName.isEmpty) {
      showMessage('Bulk template name is required');
      return false;
    }

    if ((total - 1.0).abs() > 0.01) {
      showMessage(
        'Bulk template ratios must add up to 1.0. Current total: ${total.toStringAsFixed(2)}',
      );
      return false;
    }

    return true;
  }

  void saveProduct() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (!validateVariants() || !validateBulkConfig()) {
      return;
    }

    final category = selectedCategory;
    if (category == null || category.trim().isEmpty) {
      showMessage('Category is required');
      return;
    }

    final options = getOptions();
    final variants = variantInputs.map((input) {
      final additionalImages = input.imagesController.text
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      return AdminProductVariant(
        id: input.existingId ?? generateAdminId(),
        title: input.title,
        price: double.parse(input.priceController.text.trim()),
        weightG: double.parse(input.weightController.text.trim()),
        image: input.imageController.text.trim().isEmpty
            ? null
            : input.imageController.text.trim(),
        images: additionalImages,
        attributes: input.attributes,
        stockQuantity: int.parse(input.stockController.text.trim()),
      );
    }).toList();

    if (needsBulkConfig) {
      for (final mix in mixItemInputs) {
        if (mix.isCsvMode) {
          _syncMixItemsFromCsv(mix);
        }
      }
    }

    final bulkConfig = needsBulkConfig
        ? AdminBulkConfig(
            boxes: bulkBoxInputs.map((box) => AdminBulkBox(
              title: box.nameController.text.trim(),
              weightG: double.parse(box.weightController.text.trim()),
              price: double.parse(box.priceController.text.trim()),
            )).toList(),
            preMadeTemplates: [
              {
                'name': bulkTemplateNameController.text.trim(),
                'partitions': {
                   for (final mix in mixItemInputs)
                     mix.nameController.text.trim().toLowerCase(): {
                        'ratio': double.parse(mix.ratioController.text.trim()),
                        'items': mix.items.map((subItem) => {
                          'name': subItem.nameController.text.trim(),
                          'image': subItem.imageController.text.trim(),
                        }).where((item) => (item['image'] as String).isNotEmpty).toList(),
                     }
                },
              },
            ],
          )
        : null;

    final product = AdminProductModel(
      id: widget.existingProduct?.id ?? generateAdminId(),
      title: titleController.text.trim(),
      category: category,
      description: descriptionEnController.text.trim(),
      descriptionAr: descriptionArController.text.trim(),
      descriptionEn: descriptionEnController.text.trim(),
      mainImage: mainImageController.text.trim(),
      isDietFriendly: isDietFriendly,
      isCustomizable: isCustomizable,
      options: selectedCategory == 'bulk' ? [] : options,
      variants: selectedCategory == 'bulk' ? [] : variants,
      bulkConfig: bulkConfig,
      metadata: AdminProductMetadata(
        isNewArrival: isNewArrival,
        caloriesPer100g: double.tryParse(caloriesController.text.trim()) ?? 0,
      ),
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EF),
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Product Creator'),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 16),
            child: FilledButton.icon(
              onPressed: saveProduct,
              icon: const Icon(Icons.save_outlined),
              label: Text(isEditMode ? 'Update Product' : 'Save Product'),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AdminSectionCard(
              title: 'Basic Information',
              child: Column(
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Product Title',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: selectedCategory ?? ''),
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return categories;
                      }
                      return categories.where((String option) {
                        return option.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            );
                      });
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedCategory = selection;
                        categoryController.text = selection;
                      });
                    },
                    fieldViewBuilder: (
                      context,
                      fieldTextEditingController,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      return TextFormField(
                        controller: fieldTextEditingController,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          hintText: 'Select or type a category',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                            categoryController.text = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 76,
                            constraints: const BoxConstraints(maxHeight: 250),
                            color: Colors.white,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, indent: 16),
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                  hoverColor:
                                      Colors.brown.withValues(alpha: 0.05),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionArController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Arabic Description',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Arabic description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: descriptionEnController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'English Description',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'English description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: mainImageController,
                    decoration: const InputDecoration(
                      labelText: 'Main Image URL',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Main image is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  if (mainImageController.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              mainImageController.text.trim(),
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Text('Invalid Image URL')),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton.filled(
                              onPressed: () => _downloadImage(mainImageController.text.trim()),
                              icon: const Icon(Icons.download_for_offline_outlined),
                              tooltip: 'Download/View Full Image',
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.black54,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        FilledButton.icon(
                          onPressed: isUploadingImage
                              ? null
                              : () async {
                                  final imageUrl = await pickAndUploadImage(
                                    folder: 'products/main',
                                  );

                                  if (imageUrl != null && mounted) {
                                    mainImageController.text = imageUrl;
                                    setState(() {});
                                  }
                                },
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(
                            isUploadingImage
                                ? 'Uploading...'
                                : 'Upload Main Image',
                          ),
                        ),
                        if (mainImageController.text.trim().isNotEmpty) ...[
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              mainImageController.clear();
                              setState(() {});
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories Per 100g',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    value: isDietFriendly,
                    onChanged: (value) {
                      setState(() {
                        isDietFriendly = value;
                      });
                    },
                    title: const Text('Diet Friendly'),
                  ),
                  SwitchListTile(
                    value: isCustomizable,
                    onChanged: (value) {
                      setState(() {
                        isCustomizable = value;
                      });
                    },
                    title: const Text('Customizable'),
                  ),
                  SwitchListTile(
                    value: isNewArrival,
                    onChanged: (value) {
                      setState(() {
                        isNewArrival = value;
                      });
                    },
                    title: const Text('New Arrival'),
                  ),
                ],
              ),
            ),
            if (selectedCategory != 'bulk') ...[
              const SizedBox(height: 18),
              AdminSectionCard(
                title: 'Options',
              trailing: OutlinedButton.icon(
                onPressed: addOption,
                icon: const Icon(Icons.add),
                label: const Text('Add Option'),
              ),
              child: Column(
                children: [
                  ...List.generate(optionInputs.length, (index) {
                    final option = optionInputs[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F3EF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Option ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (optionInputs.length > 1)
                                IconButton(
                                  onPressed: () => removeOption(index),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: option.nameController,
                            decoration: const InputDecoration(
                              labelText: 'Option Name',
                              hintText: 'Size, Chocolate Type, Inclusions',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: option.valuesController,
                            decoration: const InputDecoration(
                              labelText: 'Values separated by commas',
                              hintText: 'Small, Medium, Large',
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(height: 32),
                  const Text(
                    'Bulk Defaults for Generated Variants',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: defaultPriceController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Base Price'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: defaultWeightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Base Weight (g)'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: defaultStockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Base Stock'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: addStandardChocolateTemplate,
                          icon: const Icon(Icons.style_outlined),
                          label: const Text('Standard Template (3x3)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: generateVariants,
                          icon: const Icon(Icons.auto_awesome_motion_outlined),
                          label: const Text('Generate 9 Variants'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (variantInputs.isNotEmpty)
              AdminSectionCard(
                title: 'Generated Variants',
                child: Column(
                  children: variantInputs.map((variant) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F3EF),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            variant.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (variant.attributes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: variant.attributes.entries.map((entry) {
                                return Chip(
                                  label: Text('${entry.key}: ${entry.value}'),
                                );
                              }).toList(),
                            ),
                          ],
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: variant.priceController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Price',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: variant.weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Weight in grams',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: variant.stockController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: variant.imageController,
                            decoration: const InputDecoration(
                              labelText: 'Variant Main Image URL Optional',
                            ),
                          ),
                          const SizedBox(height: 10),
                           const SizedBox(height: 10),
                          if (variant.imageController.text.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      variant.imageController.text.trim(),
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Center(child: Text('Invalid Image URL')),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton.filled(
                                      onPressed: () => _downloadImage(variant.imageController.text.trim()),
                                      icon: const Icon(Icons.download_for_offline_outlined),
                                      tooltip: 'Download/View Full Image',
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black54,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: isUploadingImage
                                      ? null
                                      : () async {
                                          final imageUrl = await pickAndUploadImage(
                                            folder: 'products/variants',
                                          );

                                          if (imageUrl != null && mounted) {
                                            variant.imageController.text = imageUrl;
                                            setState(() {});
                                          }
                                        },
                                  icon: const Icon(Icons.upload_file_outlined),
                                  label: Text(
                                    isUploadingImage
                                        ? 'Uploading...'
                                        : 'Upload Variant Main Image',
                                  ),
                                ),
                                if (variant.imageController.text.trim().isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  OutlinedButton(
                                    onPressed: () {
                                      variant.imageController.clear();
                                      setState(() {});
                                    },
                                    child: const Text('Clear'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: variant.imagesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Additional Variant Image URLs',
                              hintText:
                                  'Separate multiple image URLs with commas',
                            ),
                          ),
                          const SizedBox(height: 10),
                           const SizedBox(height: 10),
                          if (variant.imagesController.text.trim().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: variant.imagesController.text
                                    .split(',')
                                    .map((url) => url.trim())
                                    .where((url) => url.isNotEmpty)
                                    .map((url) => Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                url,
                                                height: 100,
                                                width: 100,
                                                fit: BoxFit.contain,
                                                errorBuilder: (c, e, s) => Container(
                                                  height: 100,
                                                  width: 100,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.error_outline),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -4,
                                              right: -4,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () => _downloadImage(url),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.blueAccent,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.download, size: 12, color: Colors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  InkWell(
                                                    onTap: () {
                                                       final urls = variant.imagesController.text.split(',').map((u) => u.trim()).toList();
                                                       urls.remove(url);
                                                       variant.imagesController.text = urls.join(', ');
                                                       setState(() {});
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ))
                                    .toList(),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: isUploadingImage
                                  ? null
                                  : () async {
                                      final imageUrl = await pickAndUploadImage(
                                        folder: 'products/variants/gallery',
                                      );

                                      if (imageUrl != null && mounted) {
                                        final currentValue = variant
                                            .imagesController
                                            .text
                                            .trim();

                                        variant.imagesController.text =
                                            currentValue.isEmpty
                                            ? imageUrl
                                            : '$currentValue, $imageUrl';
                                        setState(() {});
                                      }
                                    },
                              icon: const Icon(Icons.add_photo_alternate_outlined),
                              label: Text(
                                isUploadingImage
                                    ? 'Uploading...'
                                    : 'Upload Additional Variant Image',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (needsBulkConfig) ...[
              const SizedBox(height: 18),
              AdminSectionCard(
                title: 'Bulk Box Configuration',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...bulkBoxInputs.asMap().entries.map((entry) {
                      final index = entry.key;
                      final box = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: box.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Box Name',
                                  hintText: 'e.g., Small Box',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: box.weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Weight (G)',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: box.priceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  bulkBoxInputs.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              tooltip: 'Remove Box',
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          bulkBoxInputs.add(AdminBulkBoxInput());
                        });
                      },
                      icon: const Icon(Icons.add_box_outlined),
                      label: const Text('Add Box Size'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(),
                    ),
                    const Text(
                      'Default Mix Template',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: bulkTemplateNameController,
                      decoration: const InputDecoration(
                        labelText: 'Template Name',
                        hintText: 'e.g., Signature Mix, Dark Lovers...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.brown.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.brown.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        children: [
                          ...mixItemInputs.asMap().entries.map((entry) {
                             final index = entry.key;
                             final mix = entry.value;
                             return Padding(
                               padding: const EdgeInsets.only(bottom: 24),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Row(
                                     children: [
                                       Expanded(
                                         flex: 2,
                                         child: TextFormField(
                                           controller: mix.nameController,
                                           decoration: const InputDecoration(
                                             labelText: 'Type Name',
                                             hintText: 'e.g. Dark',
                                           ),
                                         ),
                                       ),
                                       const SizedBox(width: 12),
                                       Expanded(
                                         flex: 1,
                                         child: TextFormField(
                                           controller: mix.ratioController,
                                           onChanged: (_) => setState(() {}),
                                           keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                           decoration: const InputDecoration(
                                             labelText: 'Ratio (0.0-1.0)',
                                             hintText: '0.33',
                                           ),
                                         ),
                                       ),
                                       if (mixItemInputs.length > 1)
                                          IconButton(
                                            onPressed: () => removeMixItem(index),
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                          ),
                                     ],
                                   ),
                                   const SizedBox(height: 12),
                                   Container(
                                     padding: const EdgeInsets.all(12),
                                     decoration: BoxDecoration(
                                       color: Colors.white.withValues(alpha: 0.5),
                                       borderRadius: BorderRadius.circular(8),
                                       border: Border.all(color: Colors.grey.shade300),
                                     ),
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Text(
                                               '${mix.nameController.text.trim().isEmpty ? "Type" : mix.nameController.text} Items',
                                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                             ),
                                             Row(
                                               mainAxisSize: MainAxisSize.min,
                                               children: [
                                                 if (mix.isCsvMode) ...[
                                                   InkWell(
                                                     onTap: () {
                                                       setState(() {
                                                         _syncMixItemsFromCsv(mix);
                                                         mix.csvTitleFirst = !mix.csvTitleFirst;
                                                         _syncMixItemsToCsv(mix);
                                                       });
                                                     },
                                                     child: Container(
                                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                       decoration: BoxDecoration(
                                                         color: Colors.brown.withValues(alpha: 0.1),
                                                         borderRadius: BorderRadius.circular(12),
                                                         border: Border.all(color: Colors.brown.withValues(alpha: 0.2)),
                                                       ),
                                                       child: Row(
                                                         mainAxisSize: MainAxisSize.min,
                                                         children: [
                                                           Icon(Icons.swap_horiz, size: 14, color: Colors.brown.shade700),
                                                           const SizedBox(width: 4),
                                                           Text(
                                                             mix.csvTitleFirst ? 'Name, Link' : 'Link, Name',
                                                             style: TextStyle(
                                                               fontSize: 10,
                                                               fontWeight: FontWeight.bold,
                                                               color: Colors.brown.shade700,
                                                             ),
                                                           ),
                                                         ],
                                                       ),
                                                     ),
                                                   ),
                                                   const SizedBox(width: 12),
                                                 ],
                                                 const Text('CSV View', style: TextStyle(fontSize: 12)),
                                                 const SizedBox(width: 4),
                                                 SizedBox(
                                                   height: 24,
                                                   width: 40,
                                                   child: Switch(
                                                     value: mix.isCsvMode,
                                                     onChanged: (val) {
                                                       setState(() {
                                                         if (val) {
                                                           _syncMixItemsToCsv(mix);
                                                         } else {
                                                           _syncMixItemsFromCsv(mix);
                                                         }
                                                         mix.isCsvMode = val;
                                                       });
                                                     },
                                                   ),
                                                 ),
                                               ],
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 12),
                                         if (mix.isCsvMode)
                                           TextFormField(
                                             controller: mix.csvController,
                                             maxLines: null,
                                             minLines: 3,
                                             style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
                                             decoration: InputDecoration(
                                               hintText: mix.csvTitleFirst 
                                                 ? 'Item Name, https://link\nAnother Item, https://link'
                                                 : 'https://link, Item Name\nhttps://link, Another Item',
                                               labelText: 'CSV Entry (${mix.csvTitleFirst ? "Name, Link" : "Link, Name"})',
                                               alignLabelWithHint: true,
                                               border: const OutlineInputBorder(),
                                               contentPadding: const EdgeInsets.all(12),
                                             ),
                                           )
                                         else ...[
                                           ...mix.items.asMap().entries.map((subEntry) {
                                             final subIndex = subEntry.key;
                                             final subItem = subEntry.value;
                                             final imgUrl = subItem.imageController.text.trim();
                                             return Padding(
                                               padding: const EdgeInsets.only(bottom: 12),
                                               child: Row(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                   if (imgUrl.isNotEmpty)
                                                     Padding(
                                                       padding: const EdgeInsets.only(right: 12),
                                                       child: ClipRRect(
                                                         borderRadius: BorderRadius.circular(6),
                                                         child: Image.network(
                                                           imgUrl,
                                                           height: 48,
                                                           width: 48,
                                                           fit: BoxFit.cover,
                                                           errorBuilder: (c, e, s) => Container(
                                                             height: 48,
                                                             width: 48,
                                                             color: Colors.grey.shade200,
                                                             child: const Icon(Icons.error_outline, size: 20),
                                                           ),
                                                         ),
                                                       ),
                                                     ),
                                                   Expanded(
                                                     flex: 2,
                                                     child: TextFormField(
                                                       controller: subItem.nameController,
                                                       decoration: const InputDecoration(
                                                         labelText: 'Item Name',
                                                         hintText: 'e.g. Dark Almond',
                                                       ),
                                                     ),
                                                   ),
                                                   const SizedBox(width: 8),
                                                   Expanded(
                                                     flex: 3,
                                                     child: TextFormField(
                                                       controller: subItem.imageController,
                                                       onChanged: (_) => setState(() {}),
                                                       decoration: const InputDecoration(
                                                         labelText: 'Image URL',
                                                       ),
                                                     ),
                                                   ),
                                                   IconButton(
                                                     onPressed: () {
                                                       setState(() {
                                                         mix.items.removeAt(subIndex);
                                                       });
                                                     },
                                                     icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                                   ),
                                                 ],
                                               ),
                                             );
                                           }),
                                           Row(
                                             children: [
                                               TextButton.icon(
                                                 onPressed: () {
                                                   setState(() {
                                                     mix.items.add(AdminMixSubItemInput());
                                                   });
                                                 },
                                                 icon: const Icon(Icons.add),
                                                 label: const Text('Add Item'),
                                               ),
                                               const SizedBox(width: 12),
                                               TextButton.icon(
                                                 onPressed: () async {
                                                   final data = await Clipboard.getData(Clipboard.kTextPlain);
                                                   if (data != null && data.text != null && data.text!.isNotEmpty) {
                                                     // ignore: deprecated_member_use
                                                     final parts = data.text!.split(RegExp(r'[,\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                                     if (parts.isNotEmpty) {
                                                       setState(() {
                                                         String? currentName;
                                                         for (final part in parts) {
                                                           if (part.startsWith('http://') || part.startsWith('https://')) {
                                                             if (currentName != null) {
                                                               mix.items.add(AdminMixSubItemInput()
                                                                 ..nameController.text = currentName
                                                                 ..imageController.text = part);
                                                               currentName = null;
                                                             } else {
                                                               mix.items.add(AdminMixSubItemInput()..imageController.text = part);
                                                             }
                                                           } else {
                                                             if (currentName != null) {
                                                               mix.items.add(AdminMixSubItemInput()..nameController.text = currentName);
                                                             }
                                                             currentName = part;
                                                           }
                                                         }
                                                         if (currentName != null) {
                                                           mix.items.add(AdminMixSubItemInput()..nameController.text = currentName);
                                                         }
                                                       });
                                                     }
                                                   }
                                                 },
                                                 icon: const Icon(Icons.paste),
                                                 label: const Text('Paste Items'),
                                               ),
                                               const SizedBox(width: 12),
                                               TextButton.icon(
                                                 onPressed: isUploadingImage
                                                     ? null
                                                     : () => pickAndUploadMultipleImages(
                                                           targetMix: mix,
                                                           folder: 'products/bulk/${mix.nameController.text.trim().isEmpty ? "mix" : mix.nameController.text.trim().toLowerCase()}',
                                                         ),
                                                 icon: const Icon(Icons.upload_file),
                                                 label: Text(
                                                   isUploadingImage ? 'Uploading...' : 'Upload Images',
                                                 ),
                                               ),
                                             ],
                                           ),
                                         ],
                                       ],
                                     ),
                                   ),
                                   const Divider(),
                                 ],
                               ),
                             );
                           }),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              OutlinedButton.icon(
                                onPressed: addMixItem,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Mix Type'),
                              ),
                              Builder(
                                builder: (context) {
                                  double total = 0;
                                  for (final mix in mixItemInputs) {
                                    total += double.tryParse(mix.ratioController.text) ?? 0;
                                  }
                                  final isBalanced = (total - 1.0).abs() < 0.001;

                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Total Ratio: ${(total * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isBalanced ? Colors.green : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (isBalanced)
                                        const Icon(Icons.check_circle, color: Colors.green, size: 16)
                                      else
                                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AdminBulkBoxInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameController.dispose();
    weightController.dispose();
    priceController.dispose();
  }
}

class AdminMixSubItemInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  void dispose() {
    nameController.dispose();
    imageController.dispose();
  }
}

class AdminMixItemInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ratioController = TextEditingController();
  final List<AdminMixSubItemInput> items = [];
  
  bool isCsvMode = false;
  bool csvTitleFirst = true;
  final TextEditingController csvController = TextEditingController();

  void dispose() {
    nameController.dispose();
    ratioController.dispose();
    csvController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }
}

class AdminOptionInput {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valuesController = TextEditingController();

  void dispose() {
    nameController.dispose();
    valuesController.dispose();
  }
}

class AdminVariantInput {
  final String? existingId;
  final String title;
  final Map<String, String> attributes;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController imagesController = TextEditingController();

  AdminVariantInput({
    this.existingId,
    required this.title,
    required this.attributes,
  });

  void dispose() {
    priceController.dispose();
    weightController.dispose();
    stockController.dispose();
    imageController.dispose();
    imagesController.dispose();
  }
}

class _AdminVariantDraft {
  final String? existingId;
  final String price;
  final String weight;
  final String stock;
  final String image;
  final String images;

  const _AdminVariantDraft({
    required this.existingId,
    required this.price,
    required this.weight,
    required this.stock,
    required this.image,
    required this.images,
  });
}
