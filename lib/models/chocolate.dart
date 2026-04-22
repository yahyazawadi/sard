class Chocolate {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Chocolate({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  factory Chocolate.fromJson(Map<String, dynamic> json) {
    return Chocolate(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['imageUrl'],
    );
  }
}
