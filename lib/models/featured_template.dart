import 'package:isar/isar.dart';

part 'featured_template.g.dart';

@collection
class FeaturedTemplate {
  FeaturedTemplate();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId;

  String? titleAr;
  String? titleEn;
  
  // Backward compatibility
  late String title;
  late String subtitle;
  late String bannerUrl;
  
  String? targetProductId;
  String? preselectedVariant;
  
  bool isCustomizable = true;

  List<String>? productIds;

  String getTitle(String lang) {
    if (lang == 'ar' && titleAr != null && titleAr!.isNotEmpty) return titleAr!;
    if (titleEn != null && titleEn!.isNotEmpty) return titleEn!;
    return title;
  }
}

