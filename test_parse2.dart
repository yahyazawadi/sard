import 'dart:convert';

void main() {
  final jsonStr = '''{
    "variants": [
      {
        "id": "1778797715219_165767",
        "title": "Small Milk",
        "title_ar": "",
        "title_en": "Small Milk",
        "price": 2.5,
        "weight_g": 30.0,
        "image": "https://sard-products-api.s12219814.workers.dev/images/products/variants/1778797480409-b81e1fd1-milk_small.png",
        "images": [],
        "attributes": {
          "size": "Small",
          "flavor": "Milk"
        },
        "stock_quantity": 50
      }
    ]
  }''';

  final item = jsonDecode(jsonStr);

  if (item['variants'] != null && (item['variants'] as List).isNotEmpty) {
    final variants = (item['variants'] as List).map((v) {
      final attrs = v['attributes'];
      String? sizeVal;
      String? typeVal;

      if (attrs is Map) {
        sizeVal = attrs['size']?.toString();
        typeVal = attrs['type']?.toString() ?? attrs['flavor']?.toString();
      } else if (attrs is List) {
        for (var attr in attrs) {
          if (attr is Map) {
            final name = attr['name']?.toString().toLowerCase();
            final val = attr['value']?.toString();
            if (name == 'size') sizeVal = val;
            if (name == 'type' || name == 'flavor') typeVal = val;
          }
        }
      }

      return {
        'size': sizeVal ?? v['title'] ?? v['label'] ?? 'Default',
        'type': typeVal,
        'imageUrl': v['image']?.toString() ?? v['image_url']?.toString(),
      };
    }).toList();

    print(variants);
  }
}
