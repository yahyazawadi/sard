import 'dart:convert';
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

  final titleArController = TextEditingController();
  final titleEnController = TextEditingController();
  final descriptionArController = TextEditingController();
  final descriptionEnController = TextEditingController();
  final mainImageController = TextEditingController();
  final caloriesController = TextEditingController(text: '0');
  final List<AdminBulkBoxInput> bulkBoxInputs = [];
  final bulkTemplateNameArController = TextEditingController();
  final bulkTemplateNameEnController = TextEditingController();
  final List<AdminMixItemInput> mixItemInputs = [];

  String? selectedCategory;
  final categoryController = TextEditingController();
  bool isDietFriendly = false;
  bool isCustomizable = false;
  bool isNewArrival = false;
  bool isUploadingImage = false;
  List<Map<String, dynamic>> allPreMadeTemplates = [];
  int selectedTemplateIndex = 0;

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

  void _loadProduct(AdminProductModel? product) {
    // Reset lists
    bulkBoxInputs.clear();
    mixItemInputs.clear();
    optionInputs.clear();
    variantInputs.clear();

    if (product == null) {
      bulkBoxInputs.add(AdminBulkBoxInput()
        ..nameArController.text = 'صندوق صغير'
        ..nameEnController.text = 'Small Box'
        ..weightController.text = '500'
        ..priceController.text = '50');
      bulkBoxInputs.add(AdminBulkBoxInput()
        ..nameArController.text = 'صندوق متوسط'
        ..nameEnController.text = 'Medium Box'
        ..weightController.text = '1000'
        ..priceController.text = '90');
      bulkBoxInputs.add(AdminBulkBoxInput()
        ..nameArController.text = 'صندوق كبير'
        ..nameEnController.text = 'Large Box'
        ..weightController.text = '2000'
        ..priceController.text = '160');
      
      allPreMadeTemplates = [{
        'name': 'Default Mix',
        'name_ar': 'ميكس افتراضي',
        'name_en': 'Default Mix',
        'partitions': {
          'mix': {
            'name_ar': 'ميكس',
            'name_en': 'Mix',
            'ratio': 1.0,
            'items': []
          },
        }
      }];
      selectedTemplateIndex = 0;
      
      final template = allPreMadeTemplates[0];
      bulkTemplateNameArController.text = template['name_ar'];
      bulkTemplateNameEnController.text = template['name_en'];
      
      mixItemInputs.clear();
      final partitions = template['partitions'] as Map<String, dynamic>;
      partitions.forEach((key, val) {
        mixItemInputs.add(AdminMixItemInput()
          ..nameEnController.text = val['name_en']
          ..nameArController.text = val['name_ar']
          ..ratioController.text = val['ratio'].toString());
      });

      optionInputs.add(AdminOptionInput());
      return;
    }

    titleArController.text = product.titleAr;
    titleEnController.text = product.titleEn.isNotEmpty ? product.titleEn : product.title;
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
            ..nameArController.text = box.titleAr
            ..nameEnController.text = box.titleEn
            ..weightController.text = box.weightG.toString()
            ..priceController.text = box.price.toString()
        );
      }

      // Load templates and ensure at least one exists
      final templatesFromConfig = bulkConfig.preMadeTemplates;
      allPreMadeTemplates = templatesFromConfig.isNotEmpty 
          ? List<Map<String, dynamic>>.from(templatesFromConfig)
          : [{
              'name': 'Default Mix',
              'name_ar': 'ميكس افتراضي',
              'name_en': 'Default Mix',
              'partitions': {
                'mix': {'name_ar': 'ميكس', 'name_en': 'Mix', 'ratio': 1.0, 'items': []},
              }
            }];
    } else if (selectedCategory == 'bulk') {
      // Fallback for bulk category without specific config
      allPreMadeTemplates = [{
        'name': 'Default Mix',
        'name_ar': 'ميكس افتراضي',
        'name_en': 'Default Mix',
        'partitions': {
          'mix': {'name_ar': 'ميكس', 'name_en': 'Mix', 'ratio': 1.0, 'items': []},
        }
      }];
    }

    if (selectedCategory == 'bulk') {
      selectedTemplateIndex = 0;
      final template = allPreMadeTemplates[selectedTemplateIndex];
        final partitions = Map<String, dynamic>.from(
          template['partitions'] ?? {},
        );

        bulkTemplateNameArController.text = template['name_ar']?.toString() ?? '';
        bulkTemplateNameEnController.text = template['name_en']?.toString() ?? template['name']?.toString() ?? '';
        
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
                  final subItemAr = item['name_ar']?.toString() ?? '';
                  final subItemEn = item['name_en']?.toString() ?? '';
                  final subItemName = item['name']?.toString() ?? '';

                  parsedItems.add(
                    AdminMixSubItemInput()
                      ..nameArController.text = subItemAr.isNotEmpty ? subItemAr : (_isArabic(subItemName) ? subItemName : '')
                      ..nameEnController.text = subItemEn.isNotEmpty ? subItemEn : (!_isArabic(subItemName) ? subItemName : '')
                      ..imageController.text = item['image']?.toString() ?? ''
                  );
                }
              }
            }
          }
          mixItemInputs.add(
            AdminMixItemInput()
              ..nameEnController.text = (value is Map ? value['name_en']?.toString() : null) ?? key
              ..nameArController.text = (value is Map ? value['name_ar']?.toString() : null) ?? ''
              ..ratioController.text = ratio.toString()
              ..items.addAll(parsedItems),
          );
        });
      }

    if (mixItemInputs.isEmpty) {
      mixItemInputs.add(AdminMixItemInput()
        ..nameEnController.text = 'Mix'
        ..nameArController.text = 'ميكس'
        ..ratioController.text = '1.0');
    }

    if (bulkBoxInputs.isEmpty) {
      bulkBoxInputs.add(AdminBulkBoxInput()..nameEnController.text = 'Small Box'..nameArController.text = 'صندوق صغير'..weightController.text = '500'..priceController.text = '50');
    }

    for (final option in product.options) {
      optionInputs.add(
        AdminOptionInput()
          ..nameArController.text = option.nameAr
          ..nameEnController.text = option.nameEn
          ..valuesArController.text = option.valuesAr.join(', ')
          ..valuesEnController.text = option.valuesEn.isNotEmpty 
              ? option.valuesEn.join(', ') 
              : option.values.join(', '),
      );
    }

    for (final variant in product.variants) {
      variantInputs.add(
        _buildVariantInput(
          existingId: variant.id,
          titleAr: variant.titleAr,
          titleEn: variant.titleEn,
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

  void _saveCurrentTemplateToState() {
    if (allPreMadeTemplates.isEmpty) {
       allPreMadeTemplates.add({});
       selectedTemplateIndex = 0;
    }
    
    if (selectedTemplateIndex < 0 || selectedTemplateIndex >= allPreMadeTemplates.length) return;

    allPreMadeTemplates[selectedTemplateIndex] = {
      'name': bulkTemplateNameEnController.text.trim(),
      'name_ar': bulkTemplateNameArController.text.trim(),
      'name_en': bulkTemplateNameEnController.text.trim(),
      'partitions': {
        for (final mix in mixItemInputs)
          mix.nameEnController.text.trim().toLowerCase(): {
            'name_ar': mix.nameArController.text.trim(),
            'name_en': mix.nameEnController.text.trim(),
            'ratio': double.tryParse(mix.ratioController.text.trim()) ?? 0,
            'items': mix.items.map((subItem) => {
              'name': subItem.nameEnController.text.trim().isNotEmpty 
                      ? subItem.nameEnController.text.trim() 
                      : subItem.nameArController.text.trim(),
              'name_ar': subItem.nameArController.text.trim(),
              'name_en': subItem.nameEnController.text.trim(),
              'image': subItem.imageController.text.trim(),
            }).where((item) => (item['image'] as String).isNotEmpty).toList(),
          }
      },
    };
  }

  List<Map<String, dynamic>> _getUpdatedTemplatesList() {
    _saveCurrentTemplateToState();
    return allPreMadeTemplates;
  }

  void _loadTemplateAtIndex(int index) {
    if (index < 0 || index >= allPreMadeTemplates.length) return;
    
    _saveCurrentTemplateToState(); // Save current before switching
    
    setState(() {
      selectedTemplateIndex = index;
      final template = allPreMadeTemplates[selectedTemplateIndex];
      final partitions = Map<String, dynamic>.from(template['partitions'] ?? {});

      bulkTemplateNameArController.text = template['name_ar']?.toString() ?? '';
      bulkTemplateNameEnController.text = template['name_en']?.toString() ?? template['name']?.toString() ?? '';
      
      mixItemInputs.clear();
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
                final subItemAr = item['name_ar']?.toString() ?? '';
                final subItemEn = item['name_en']?.toString() ?? '';
                final subItemName = item['name']?.toString() ?? '';

                parsedItems.add(
                  AdminMixSubItemInput()
                    ..nameArController.text = subItemAr.isNotEmpty ? subItemAr : (_isArabic(subItemName) ? subItemName : '')
                    ..nameEnController.text = subItemEn.isNotEmpty ? subItemEn : (!_isArabic(subItemName) ? subItemName : '')
                    ..imageController.text = item['image']?.toString() ?? ''
                );
              }
            }
          }
        }

        mixItemInputs.add(
          AdminMixItemInput()
            ..nameEnController.text = (value is Map ? value['name_en']?.toString() : null) ?? key
            ..nameArController.text = (value is Map ? value['name_ar']?.toString() : null) ?? ''
            ..ratioController.text = ratio.toString()
            ..items.addAll(parsedItems),
        );
      });

      if (mixItemInputs.isEmpty) {
        mixItemInputs.add(AdminMixItemInput()..nameEnController.text = 'Mix'..nameArController.text = 'ميكس'..ratioController.text = '1.0');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadProduct(widget.existingProduct);
    
    // Add listener to mainImageController to update preview in real-time
    mainImageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    titleArController.dispose();
    titleEnController.dispose();
    descriptionArController.dispose();
    descriptionEnController.dispose();
    categoryController.dispose();
    mainImageController.dispose();
    caloriesController.dispose();
    bulkTemplateNameArController.dispose();
    bulkTemplateNameEnController.dispose();
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
    required String titleAr,
    required String titleEn,
    required Map<String, String> attributes,
    String price = '',
    String weight = '',
    String stock = '0',
    String image = '',
    String images = '',
  }) {
    final input = AdminVariantInput(
      existingId: existingId,
      titleAr: titleAr,
      titleEn: titleEn,
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
    if (!mounted) return;
    try {
      final messenger = ScaffoldMessenger.of(context);
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
    } catch (e) {
      debugPrint('Error showing message: $e');
    }
  }

  Future<String?> pickAndUploadImage({String folder = 'products'}) async {
    try {
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        return null; // User cancelled
      }

      if (mounted) {
        setState(() {
          isUploadingImage = true;
        });
      }

      final bytes = await pickedFile.readAsBytes();

      final url = await imageApi.uploadImageBytes(
        bytes: bytes,
        filename: pickedFile.name,
        folder: folder,
      );

      if (url.isEmpty) {
        throw Exception('Server returned an empty image URL');
      }

      return url;
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

  bool _isArabic(String s) => RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(s);

  void _syncMixItemsToCsv(AdminMixItemInput mix) {
    final buffer = StringBuffer();
    for (final item in mix.items) {
      final ar = item.nameArController.text.trim();
      final en = item.nameEnController.text.trim();
      final u = item.imageController.text.trim();
      
      // Use whichever name is available, prioritize EN for the "Link, Name" format if both exist
      final name = en.isNotEmpty ? en : ar;
      
      if (name.isNotEmpty && u.isNotEmpty) {
        if (mix.csvTitleFirst) {
          buffer.writeln('$name, $u');
        } else {
          buffer.writeln('$u, $name');
        }
      } else if (name.isNotEmpty) {
        buffer.writeln(name);
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
          final subItem = AdminMixSubItemInput()..imageController.text = part;
          if (currentName != null) {
            if (_isArabic(currentName)) {
              subItem.nameArController.text = currentName;
            } else {
              subItem.nameEnController.text = currentName;
            }
            currentName = null;
          }
          mix.items.add(subItem);
        } else {
          if (currentName != null) {
             final subItem = AdminMixSubItemInput();
             if (_isArabic(currentName)) {
               subItem.nameArController.text = currentName;
             } else {
               subItem.nameEnController.text = currentName;
             }
             mix.items.add(subItem);
          }
          currentName = part;
        }
      }
      if (currentName != null) {
        final subItem = AdminMixSubItemInput();
        if (_isArabic(currentName)) {
          subItem.nameArController.text = currentName;
        } else {
          subItem.nameEnController.text = currentName;
        }
        mix.items.add(subItem);
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
          final subItem = AdminMixSubItemInput();
          if (_isArabic(part)) {
            subItem.nameArController.text = part;
          } else {
            subItem.nameEnController.text = part;
          }
          if (currentUrl != null) {
            subItem.imageController.text = currentUrl;
            currentUrl = null;
          }
          mix.items.add(subItem);
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
          final nameAr = input.nameArController.text.trim();
          final nameEn = input.nameEnController.text.trim();
          
          final valuesAr = input.valuesArController.text
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();
              
          final valuesEn = input.valuesEnController.text
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList();

          return AdminProductOption(
            name: nameEn.isNotEmpty ? nameEn : nameAr,
            nameAr: nameAr,
            nameEn: nameEn,
            values: valuesEn.isNotEmpty ? valuesEn : valuesAr,
            valuesAr: valuesAr,
            valuesEn: valuesEn,
          );
        })
        .where((option) => (option.nameEn.isNotEmpty || option.nameAr.isNotEmpty) && (option.valuesAr.isNotEmpty || option.valuesEn.isNotEmpty))
        .toList();
  }

  List<Map<String, dynamic>> generateCombinations(
    List<AdminProductOption> options,
  ) {
    List<Map<String, dynamic>> result = [
      {'attributes': <String, String>{}, 'strAr': '', 'strEn': ''}
    ];

    for (final option in options) {
      final List<Map<String, dynamic>> newResult = [];

      for (final existing in result) {
        final existingAttrs = Map<String, String>.from(existing['attributes']);
        final existingStrAr = existing['strAr'] as String;
        final existingStrEn = existing['strEn'] as String;

        // Ensure we have same number of values if possible, otherwise fallback
        final count = option.valuesEn.length;
        for (int i = 0; i < count; i++) {
          final valEn = option.valuesEn[i];
          final valAr = (i < option.valuesAr.length) ? option.valuesAr[i] : valEn;
          
          final newAttrs = Map<String, String>.from(existingAttrs);
          newAttrs[option.name.toLowerCase().replaceAll(' ', '_')] = valEn;

          newResult.add({
            'attributes': newAttrs,
            'strAr': existingStrAr.isEmpty ? valAr : '$existingStrAr $valAr',
            'strEn': existingStrEn.isEmpty ? valEn : '$existingStrEn $valEn',
          });
        }
        
        // Handle case where valuesEn is empty but values is not (legacy)
        if (count == 0 && option.values.isNotEmpty) {
           for (final val in option.values) {
              final newAttrs = Map<String, String>.from(existingAttrs);
              newAttrs[option.name.toLowerCase().replaceAll(' ', '_')] = val;
              newResult.add({
                'attributes': newAttrs,
                'strAr': existingStrAr.isEmpty ? val : '$existingStrAr $val',
                'strEn': existingStrEn.isEmpty ? val : '$existingStrEn $val',
              });
           }
        }
      }

      if (newResult.isNotEmpty) {
        result = newResult;
      }
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
          ..nameArController.text = 'الحجم'
          ..nameEnController.text = 'Size'
          ..valuesEnController.text = 'Small, Medium, Large'
          ..valuesArController.text = 'صغير، متوسط، كبير',
      );
      final flavorOption = AdminOptionInput();
      flavorOption.nameEnController.text = 'Flavor';
      flavorOption.nameArController.text = 'النكهة';
      flavorOption.valuesEnController.text = 'Mix, Dark, Milk, White';
      flavorOption.valuesArController.text = 'ميكس، داكن، بالحليب، أبيض';
      optionInputs.add(flavorOption);
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
        title: variant.titleEn,
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

    final baseTitleAr = titleArController.text.trim();
    final baseTitleEn = titleEnController.text.trim();

    for (final combination in combinations) {
      final attributes = Map<String, String>.from(combination['attributes'] ?? {});
      final combinationStrAr = combination['strAr'] as String? ?? '';
      final combinationStrEn = combination['strEn'] as String? ?? '';
      
      final generatedTitleAr = attributes.isEmpty
          ? (baseTitleAr.isNotEmpty ? baseTitleAr : 'Default Variant')
          : (baseTitleAr.isNotEmpty ? '$baseTitleAr - $combinationStrAr' : combinationStrAr);
          
      final generatedTitleEn = attributes.isEmpty
          ? (baseTitleEn.isNotEmpty ? baseTitleEn : 'Default Variant')
          : (baseTitleEn.isNotEmpty ? '$baseTitleEn - $combinationStrEn' : combinationStrEn);

      final key = getVariantKey(title: generatedTitleEn, attributes: attributes);
      final draft = existingDrafts[key];

      final dPrice = defaultPriceController.text.trim();
      final dWeight = defaultWeightController.text.trim();
      final dStock = defaultStockController.text.trim();

      variantInputs.add(
        _buildVariantInput(
          existingId: draft?.existingId,
          titleAr: generatedTitleAr,
          titleEn: generatedTitleEn,
          attributes: Map<String, String>.from(combination['attributes'] ?? {}),
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
      debugPrint('Validation failed: No variants generated');
      showMessage('Generate variants before saving');
      return false;
    }

    for (final variant in variantInputs) {
      final price = double.tryParse(variant.priceController.text.trim());
      final weight = double.tryParse(variant.weightController.text.trim());
      final stock = int.tryParse(variant.stockController.text.trim());

      if (price == null || price <= 0) {
        showMessage('${variant.titleEn} needs a valid price');
        return false;
      }

      if (weight == null || weight <= 0) {
        showMessage('${variant.titleEn} needs a valid weight');
        return false;
      }
      if (stock == null || stock < 0) {
        showMessage('${variant.titleEn} needs valid stock quantity');
        return false;
      }
    }

    return true;
  }

  bool validateBulkConfig() {
    if (!needsBulkConfig) return true;
    final errors = _collectValidationErrors();
    return !errors.any((e) => e.contains('Bulk') || e.contains('box'));
  }

  List<String> _collectValidationErrors() {
    final errors = <String>[];
    
    // Form fields validation
    if (titleArController.text.trim().isEmpty) errors.add('Arabic Title is missing');
    if (titleEnController.text.trim().isEmpty) errors.add('English Title is missing');
    if (selectedCategory == null || selectedCategory!.trim().isEmpty) errors.add('Category is not selected');
    if (mainImageController.text.trim().isEmpty) errors.add('Main Image URL is missing');
    
    // Variant validation
    if (selectedCategory != 'bulk') {
      if (variantInputs.isEmpty) {
        errors.add('No variants have been generated');
      } else {
        for (final variant in variantInputs) {
          final price = double.tryParse(variant.priceController.text.trim());
          final weight = double.tryParse(variant.weightController.text.trim());
          if (price == null || price <= 0) errors.add('Variant "${variant.titleEn}" needs a valid price');
          if (weight == null || weight <= 0) errors.add('Variant "${variant.titleEn}" needs a valid weight');
        }
      }
    }
    
    // Bulk validation
    if (needsBulkConfig) {
      if (bulkBoxInputs.isEmpty) {
        errors.add('Bulk products need at least one box size');
      }
      for (final box in bulkBoxInputs) {
        if (box.nameArController.text.trim().isEmpty && box.nameEnController.text.trim().isEmpty) {
          errors.add('All bulk boxes must have a name');
        }
        final price = double.tryParse(box.priceController.text.trim());
        if (price == null || price <= 0) errors.add('Box "${box.nameEnController.text}" needs a valid price');
      }
      
      final templateNameEn = bulkTemplateNameEnController.text.trim();
      if (templateNameEn.isEmpty && bulkTemplateNameArController.text.trim().isEmpty) {
        errors.add('Bulk template name is missing');
      }
      
      double total = 0;
      for (final mix in mixItemInputs) {
        final ratio = double.tryParse(mix.ratioController.text.trim());
        if (ratio == null || ratio < 0) {
          errors.add('Mix ratio for "${mix.nameEnController.text}" is invalid');
        } else {
          total += ratio;
        }
      }
      if ((total - 1.0).abs() > 0.01) {
        errors.add('Bulk template ratios must add up to 1.0 (Current: ${total.toStringAsFixed(2)})');
      }
    }
    
    return errors;
  }

  AdminProductModel? _getCurrentProduct({bool validate = true}) {
    if (validate) {
      if (!formKey.currentState!.validate()) {
        debugPrint('Form validation failed');
        return null;
      }
      if (!validateVariants()) {
        debugPrint('Variant validation failed');
        return null;
      }
      if (!validateBulkConfig()) {
        debugPrint('Bulk config validation failed');
        return null;
      }
    }

    final category = selectedCategory;
    if (validate && (category == null || category.trim().isEmpty)) {
      debugPrint('Validation failed: Category is missing');
      showMessage('Category is required');
      return null;
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
        title: input.titleEn,
        titleAr: input.titleAr,
        titleEn: input.titleEn,
        price: double.tryParse(input.priceController.text.trim()) ?? 0,
        weightG: double.tryParse(input.weightController.text.trim()) ?? 0,
        image: input.imageController.text.trim().isEmpty
            ? null
            : input.imageController.text.trim(),
        images: additionalImages,
        attributes: input.attributes,
        stockQuantity: int.tryParse(input.stockController.text.trim()) ?? 0,
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
              title: box.nameEnController.text.trim(),
              titleAr: box.nameArController.text.trim(),
              titleEn: box.nameEnController.text.trim(),
              weightG: double.tryParse(box.weightController.text.trim()) ?? 0,
              price: double.tryParse(box.priceController.text.trim()) ?? 0,
            )).toList(),
            preMadeTemplates: _getUpdatedTemplatesList(),
          )
        : null;

    return AdminProductModel(
      id: widget.existingProduct?.id ?? generateAdminId(),
      title: titleEnController.text.trim(),
      titleAr: titleArController.text.trim(),
      titleEn: titleEnController.text.trim(),
      category: category ?? '',
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
  }

  void saveProduct() {
    final errors = _collectValidationErrors();
    
    if (errors.isEmpty) {
      final product = _getCurrentProduct(validate: false); // We already validated
      if (product != null) {
        Navigator.pop(context, product);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
              const SizedBox(width: 10),
              const Text('Missing Information'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please fix the following issues before saving:'),
              const SizedBox(height: 16),
              ...errors.map((err) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(err)),
                  ],
                ),
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showJsonView() {
    final product = _getCurrentProduct(validate: false);
    if (product == null) return;

    final jsonStr = const JsonEncoder.withIndent('  ').convert(product.toJson());
    final controller = TextEditingController(text: jsonStr);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product JSON'),
        content: SizedBox(
          width: 800,
          height: 600,
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: controller.text));
              showMessage('Copied to clipboard');
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
          ),
          FilledButton.icon(
            onPressed: () {
              try {
                final Map<String, dynamic> decoded = jsonDecode(controller.text);
                final Map<String, dynamic> productData = decoded.containsKey('product') 
                    ? decoded['product'] 
                    : decoded;
                
                final newProduct = AdminProductModel.fromJson(productData);
                
                setState(() {
                  _loadProduct(newProduct);
                });
                
                Navigator.pop(context);
                showMessage('Changes applied to form');
              } catch (e) {
                showMessage('Invalid JSON: ${e.toString()}');
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Apply Changes'),
          ),
        ],
      ),
    );
  }

  void _importJson() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Product JSON'),
        content: SizedBox(
          width: 600,
          child: TextField(
            controller: controller,
            maxLines: 15,
            decoration: const InputDecoration(
              hintText: 'Paste JSON here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              try {
                final String jsonStr = controller.text;
                if (jsonStr.trim().isEmpty) return;
                
                final Map<String, dynamic> decoded = jsonDecode(jsonStr);
                final Map<String, dynamic> productData = decoded.containsKey('product') 
                    ? decoded['product'] 
                    : decoded;
                
                final newProduct = AdminProductModel.fromJson(productData);
                
                setState(() {
                  _loadProduct(newProduct);
                });
                
                Navigator.pop(context);
                showMessage('Product imported successfully');
              } catch (e) {
                showMessage('Invalid JSON: ${e.toString()}');
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F3EF),
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Product' : 'Product Creator'),
        actions: [
          IconButton(
            onPressed: _importJson,
            icon: const Icon(Icons.file_download),
            tooltip: 'Import JSON',
          ),
          IconButton(
            onPressed: _showJsonView,
            icon: const Icon(Icons.code),
            tooltip: 'View JSON',
          ),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: titleArController,
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            labelText: 'Title (Arabic) | العنوان بالعربي',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              debugPrint('Validation failed: Arabic Title is missing');
                              return 'Arabic title is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: titleEnController,
                          decoration: const InputDecoration(
                            labelText: 'Title (English)',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              debugPrint('Validation failed: English Title is missing');
                              return 'English title is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: descriptionArController,
                          textAlign: TextAlign.end,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description (Arabic) | الوصف بالعربي',
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: descriptionEnController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description (English)',
                          ),
                        ),
                      ),
                    ],
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
                    decoration: InputDecoration(
                      labelText: 'Main Image URL',
                      hintText: 'https://...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (mainImageController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                mainImageController.clear();
                                setState(() {});
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.content_paste),
                            tooltip: 'Paste URL',
                            onPressed: () async {
                              final data = await Clipboard.getData(Clipboard.kTextPlain);
                              if (data?.text != null) {
                                mainImageController.text = data!.text!.trim();
                                setState(() {});
                                showMessage('URL Pasted');
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        debugPrint('Validation failed: Main Image URL is empty');
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
                          GestureDetector(
                            onTap: isUploadingImage
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
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Stack(
                                alignment: Alignment.center,
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
                                  if (isUploadingImage)
                                    const CircularProgressIndicator(),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit, size: 14, color: Colors.white),
                                          SizedBox(width: 4),
                                          Text('Click to Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: option.nameArController,
                                  textAlign: TextAlign.end,
                                  decoration: const InputDecoration(
                                    labelText: 'Name (Arabic) | الاسم بالعربي',
                                    hintText: 'الحجم، نوع الشوكولاتة...',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: option.nameEnController,
                                  decoration: const InputDecoration(
                                    labelText: 'Name (English)',
                                    hintText: 'Size, Chocolate Type...',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: option.valuesArController,
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                              labelText: 'Values (Arabic) | القيم بالعربي',
                              hintText: 'صغير، متوسط، كبير',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: option.valuesEnController,
                            decoration: const InputDecoration(
                              labelText: 'Values (English)',
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
                          Row(
                            children: [
                              Text(
                                variant.titleAr,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                variant.titleEn,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: box.nameArController,
                                    textAlign: TextAlign.end,
                                    decoration: const InputDecoration(
                                      labelText: 'Box (Arabic) | الصندوق بالعربي',
                                      hintText: 'صندوق صغير',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: box.nameEnController,
                                    decoration: const InputDecoration(
                                      labelText: 'Box (English)',
                                      hintText: 'Small Box',
                                    ),
                                  ),
                                ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bulk Templates Management',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown),
                        ),
                        if (allPreMadeTemplates.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.brown.withValues(alpha: 0.2)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: (selectedTemplateIndex >= 0 && selectedTemplateIndex < allPreMadeTemplates.length) 
                                    ? selectedTemplateIndex 
                                    : 0,
                                isExpanded: false,
                                icon: const Icon(Icons.arrow_drop_down, color: Colors.brown),
                                items: allPreMadeTemplates.asMap().entries.map((e) {
                                  final name = e.value['name_ar']?.toString().isNotEmpty == true 
                                      ? e.value['name_ar'] 
                                      : (e.value['name_en'] ?? e.value['name'] ?? 'Template ${e.key + 1}');
                                  return DropdownMenuItem(
                                    value: e.key,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 200),
                                      child: Text(
                                        name.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _loadTemplateAtIndex(val);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              tooltip: 'Add New Template',
                              onPressed: () {
                                 setState(() {
                                    _saveCurrentTemplateToState();
                                    allPreMadeTemplates.add({
                                      'name': 'New Template',
                                      'name_ar': 'قالب جديد',
                                      'name_en': 'New Template',
                                      'partitions': {
                                        'mix': {
                                          'name_ar': 'ميكس',
                                          'name_en': 'Mix',
                                          'ratio': 1.0,
                                          'items': []
                                        }
                                      }
                                    });
                                    _loadTemplateAtIndex(allPreMadeTemplates.length - 1);
                                 });
                              },
                            ),
                            if (allPreMadeTemplates.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                tooltip: 'Delete Current Template',
                                onPressed: () {
                                  setState(() {
                                    allPreMadeTemplates.removeAt(selectedTemplateIndex);
                                    selectedTemplateIndex = 0;
                                    _loadTemplateAtIndex(0);
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: bulkTemplateNameArController,
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                                labelText: 'Template (Arabic) | القالب بالعربي',
                                hintText: 'ميكس كلاسيك...',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: bulkTemplateNameEnController,
                            decoration: const InputDecoration(
                              labelText: 'Template (English)',
                              hintText: 'Signature Mix...',
                            ),
                          ),
                        ),
                      ],
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
                                         flex: 3,
                                         child: Column(
                                           children: [
                                             TextFormField(
                                               controller: mix.nameArController,
                                               textAlign: TextAlign.end,
                                               decoration: const InputDecoration(
                                                  labelText: 'Type (Arabic) | النوع بالعربي',
                                                  hintText: 'داكن',
                                               ),
                                             ),
                                             const SizedBox(height: 8),
                                             TextFormField(
                                               controller: mix.nameEnController,
                                               decoration: const InputDecoration(
                                                 labelText: 'Type (English)',
                                                 hintText: 'Dark',
                                               ),
                                             ),
                                           ],
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
                                             labelText: 'Ratio',
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
                                               '${mix.nameEnController.text.trim().isEmpty ? "Type" : mix.nameEnController.text} Items',
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
                                                     flex: 3,
                                                     child: Column(
                                                       children: [
                                                         TextFormField(
                                                           controller: subItem.nameArController,
                                                           textAlign: TextAlign.end,
                                                           decoration: const InputDecoration(
                                                             labelText: 'Item (Arabic)',
                                                              hintText: 'لوز داكن',
                                                           ),
                                                         ),
                                                         const SizedBox(height: 8),
                                                         TextFormField(
                                                           controller: subItem.nameEnController,
                                                           decoration: const InputDecoration(
                                                             labelText: 'Item (English)',
                                                             hintText: 'Dark Almond',
                                                           ),
                                                         ),
                                                       ],
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
                                                             final newItem = AdminMixSubItemInput()..imageController.text = part;
                                                             if (currentName != null) {
                                                               if (_isArabic(currentName)) {
                                                                 newItem.nameArController.text = currentName;
                                                               } else {
                                                                 newItem.nameEnController.text = currentName;
                                                               }
                                                               currentName = null;
                                                             }
                                                             mix.items.add(newItem);
                                                           } else {
                                                             if (currentName != null) {
                                                               final newItem = AdminMixSubItemInput();
                                                               if (_isArabic(currentName)) {
                                                                 newItem.nameArController.text = currentName;
                                                               } else {
                                                                 newItem.nameEnController.text = currentName;
                                                               }
                                                               mix.items.add(newItem);
                                                             }
                                                             currentName = part;
                                                           }
                                                         }
                                                         if (currentName != null) {
                                                           final newItem = AdminMixSubItemInput();
                                                           if (_isArabic(currentName)) {
                                                             newItem.nameArController.text = currentName;
                                                           } else {
                                                             newItem.nameEnController.text = currentName;
                                                           }
                                                           mix.items.add(newItem);
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
                                                           folder: 'products/bulk/${mix.nameEnController.text.trim().isEmpty ? "mix" : mix.nameEnController.text.trim().toLowerCase()}',
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
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    weightController.dispose();
    priceController.dispose();
  }
}

class AdminMixSubItemInput {
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    imageController.dispose();
  }
}

class AdminMixItemInput {
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController ratioController = TextEditingController();
  final List<AdminMixSubItemInput> items = [];
  
  bool isCsvMode = false;
  bool csvTitleFirst = true;
  final TextEditingController csvController = TextEditingController();

  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    ratioController.dispose();
    csvController.dispose();
    for (final item in items) {
      item.dispose();
    }
  }
}

class AdminOptionInput {
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController valuesArController = TextEditingController();
  final TextEditingController valuesEnController = TextEditingController();

  void dispose() {
    nameArController.dispose();
    nameEnController.dispose();
    valuesArController.dispose();
    valuesEnController.dispose();
  }
}

class AdminVariantInput {
  final String? existingId;
  final String titleAr;
  final String titleEn;
  final Map<String, String> attributes;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController imagesController = TextEditingController();

  AdminVariantInput({
    this.existingId,
    required this.titleAr,
    required this.titleEn,
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
