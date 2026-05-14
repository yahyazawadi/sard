import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  final bulkPriceController = TextEditingController(text: '0');
  final bulkMinWeightController = TextEditingController(text: '500');
  final bulkTemplateNameController = TextEditingController();
  final bulkDarkRatioController = TextEditingController(text: '0.33');
  final bulkMilkRatioController = TextEditingController(text: '0.33');
  final bulkWhiteRatioController = TextEditingController(text: '0.34');

  String? selectedCategory;
  final categoryController = TextEditingController();
  bool isDietFriendly = false;
  bool isCustomizable = false;
  bool isNewArrival = false;
  bool isUploadingImage = false;

  final List<AdminOptionInput> optionInputs = [];
  final List<AdminVariantInput> variantInputs = [];

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
      bulkPriceController.text = bulkConfig.pricePerKg.toString();
      bulkMinWeightController.text = bulkConfig.minOrderWeightG.toString();

      if (bulkConfig.preMadeTemplates.isNotEmpty) {
        final template = bulkConfig.preMadeTemplates.first;
        final partitions = Map<String, dynamic>.from(
          template['partitions'] ?? {},
        );

        bulkTemplateNameController.text = template['name']?.toString() ?? '';
        bulkDarkRatioController.text = (partitions['dark'] ?? 0.33).toString();
        bulkMilkRatioController.text = (partitions['milk'] ?? 0.33).toString();
        bulkWhiteRatioController.text = (partitions['white'] ?? 0.34)
            .toString();
      }
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
    bulkPriceController.dispose();
    bulkMinWeightController.dispose();
    bulkTemplateNameController.dispose();
    bulkDarkRatioController.dispose();
    bulkMilkRatioController.dispose();
    bulkWhiteRatioController.dispose();

    for (final option in optionInputs) {
      option.dispose();
    }

    for (final variant in variantInputs) {
      variant.dispose();
    }

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

  void addOption() {
    setState(() {
      optionInputs.add(AdminOptionInput());
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

      variantInputs.add(
        _buildVariantInput(
          existingId: draft?.existingId,
          title: generatedTitle,
          attributes: combination,
          price: draft?.price ?? '',
          weight: draft?.weight ?? '',
          stock: draft?.stock ?? '0',
          image: draft?.image ?? '',
          images: draft?.images ?? '',
        ),
      );
    }

    setState(() {});
  }

  bool validateVariants() {
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

    final pricePerKg = double.tryParse(bulkPriceController.text.trim());
    final minWeight = double.tryParse(bulkMinWeightController.text.trim());
    final templateName = bulkTemplateNameController.text.trim();
    final dark = double.tryParse(bulkDarkRatioController.text.trim());
    final milk = double.tryParse(bulkMilkRatioController.text.trim());
    final white = double.tryParse(bulkWhiteRatioController.text.trim());

    if (pricePerKg == null || pricePerKg <= 0) {
      showMessage('Bulk products need a valid price per KG');
      return false;
    }

    if (minWeight == null || minWeight <= 0) {
      showMessage('Bulk products need a valid minimum order weight');
      return false;
    }

    if (templateName.isEmpty) {
      showMessage('Bulk template name is required');
      return false;
    }

    if (dark == null || milk == null || white == null) {
      showMessage('Bulk template ratios must be valid numbers');
      return false;
    }

    if (dark < 0 || milk < 0 || white < 0) {
      showMessage('Bulk template ratios cannot be negative');
      return false;
    }

    final total = dark + milk + white;
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

    final bulkConfig = needsBulkConfig
        ? AdminBulkConfig(
            pricePerKg: double.parse(bulkPriceController.text.trim()),
            minOrderWeightG: double.parse(bulkMinWeightController.text.trim()),
            preMadeTemplates: [
              {
                'name': bulkTemplateNameController.text.trim(),
                'partitions': {
                  'dark': double.parse(bulkDarkRatioController.text.trim()),
                  'milk': double.parse(bulkMilkRatioController.text.trim()),
                  'white': double.parse(bulkWhiteRatioController.text.trim()),
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
      options: options,
      variants: variants,
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
                                      Colors.brown.withOpacity(0.05),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
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
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: generateVariants,
                      icon: const Icon(Icons.auto_awesome_motion_outlined),
                      label: const Text('Generate Variants'),
                    ),
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
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
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
            if (needsBulkConfig) ...[
              const SizedBox(height: 18),
              AdminSectionCard(
                title: 'Bulk Configuration',
                child: Column(
                  children: [
                    TextFormField(
                      controller: bulkPriceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price Per KG',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: bulkMinWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Minimum Order Weight G',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: bulkTemplateNameController,
                      decoration: const InputDecoration(
                        labelText: 'Template Name',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: bulkDarkRatioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Dark Chocolate Ratio',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: bulkMilkRatioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Milk Chocolate Ratio',
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: bulkWhiteRatioController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'White Chocolate Ratio',
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
