import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/product.dart';
import '../models/filling.dart';
import '../models/category.dart';

import '../models/featured_template.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar has not been initialized');
});

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [ProductSchema, FillingSchema, CategorySchema, FeaturedTemplateSchema],
    directory: dir.path,
  );
}
