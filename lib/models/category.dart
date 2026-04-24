import 'package:isar/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId;

  late String nameEn;
  late String nameAr;
  late String imageUrl;
  
  late int displayOrder;
}
