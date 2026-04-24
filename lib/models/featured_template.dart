import 'package:isar/isar.dart';

part 'featured_template.g.dart';

@collection
class FeaturedTemplate {
  FeaturedTemplate();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId; // feat_001

  late String title;
  late String subtitle;
  late String bannerUrl;
  
  String? targetProductId;
  String? preselectedVariant; // e.g., 'Medium'
  
  bool isCustomizable = true;

  List<String>? productIds; // For collections
}
