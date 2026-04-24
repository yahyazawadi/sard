import 'package:isar/isar.dart';

part 'filling.g.dart';

@collection
class Filling {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId;

  late String nameEn;
  late String nameAr;
  late String imageUrl;
  
  // Nuts, Creams, Fruits, Crunchy, Diet
  late String category;

  late bool isAvailable;
}
