import 'dart:convert';

void main() {
  final jsonStr = '''{
    "id": "1778797715220_943200",
    "variants": [
      {
        "id": "1778797715219_165767",
        "title": "Small Milk",
        "attributes": {
          "size": "Small",
          "flavor": "Milk"
        }
      }
    ]
  }''';

  final item = json.decode(jsonStr);
  
  final variants = (item['variants'] as List).map((v) {
    final attrs = v['attributes'];
    String? sizeVal;
    String? typeVal;

    if (attrs is Map) {
      sizeVal = attrs['size']?.toString();
      typeVal = attrs['type']?.toString() ?? attrs['flavor']?.toString();
    }
    
    return {
      'size': sizeVal ?? v['title'] ?? v['label'] ?? 'Default',
      'type': typeVal
    };
  }).toList();

  print(variants);
}
