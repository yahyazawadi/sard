// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'featured_template.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFeaturedTemplateCollection on Isar {
  IsarCollection<FeaturedTemplate> get featuredTemplates => this.collection();
}

const FeaturedTemplateSchema = CollectionSchema(
  name: r'FeaturedTemplate',
  id: -1404379563594707515,
  properties: {
    r'bannerUrl': PropertySchema(
      id: 0,
      name: r'bannerUrl',
      type: IsarType.string,
    ),
    r'isCustomizable': PropertySchema(
      id: 1,
      name: r'isCustomizable',
      type: IsarType.bool,
    ),
    r'preselectedVariant': PropertySchema(
      id: 2,
      name: r'preselectedVariant',
      type: IsarType.string,
    ),
    r'productIds': PropertySchema(
      id: 3,
      name: r'productIds',
      type: IsarType.stringList,
    ),
    r'remoteId': PropertySchema(
      id: 4,
      name: r'remoteId',
      type: IsarType.string,
    ),
    r'subtitle': PropertySchema(
      id: 5,
      name: r'subtitle',
      type: IsarType.string,
    ),
    r'targetProductId': PropertySchema(
      id: 6,
      name: r'targetProductId',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _featuredTemplateEstimateSize,
  serialize: _featuredTemplateSerialize,
  deserialize: _featuredTemplateDeserialize,
  deserializeProp: _featuredTemplateDeserializeProp,
  idName: r'id',
  indexes: {
    r'remoteId': IndexSchema(
      id: 6301175856541681032,
      name: r'remoteId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'remoteId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _featuredTemplateGetId,
  getLinks: _featuredTemplateGetLinks,
  attach: _featuredTemplateAttach,
  version: '3.1.0+1',
);

int _featuredTemplateEstimateSize(
  FeaturedTemplate object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bannerUrl.length * 3;
  {
    final value = object.preselectedVariant;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.productIds;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  bytesCount += 3 + object.remoteId.length * 3;
  bytesCount += 3 + object.subtitle.length * 3;
  {
    final value = object.targetProductId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _featuredTemplateSerialize(
  FeaturedTemplate object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bannerUrl);
  writer.writeBool(offsets[1], object.isCustomizable);
  writer.writeString(offsets[2], object.preselectedVariant);
  writer.writeStringList(offsets[3], object.productIds);
  writer.writeString(offsets[4], object.remoteId);
  writer.writeString(offsets[5], object.subtitle);
  writer.writeString(offsets[6], object.targetProductId);
  writer.writeString(offsets[7], object.title);
}

FeaturedTemplate _featuredTemplateDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FeaturedTemplate();
  object.bannerUrl = reader.readString(offsets[0]);
  object.id = id;
  object.isCustomizable = reader.readBool(offsets[1]);
  object.preselectedVariant = reader.readStringOrNull(offsets[2]);
  object.productIds = reader.readStringList(offsets[3]);
  object.remoteId = reader.readString(offsets[4]);
  object.subtitle = reader.readString(offsets[5]);
  object.targetProductId = reader.readStringOrNull(offsets[6]);
  object.title = reader.readString(offsets[7]);
  return object;
}

P _featuredTemplateDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _featuredTemplateGetId(FeaturedTemplate object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _featuredTemplateGetLinks(FeaturedTemplate object) {
  return [];
}

void _featuredTemplateAttach(
    IsarCollection<dynamic> col, Id id, FeaturedTemplate object) {
  object.id = id;
}

extension FeaturedTemplateByIndex on IsarCollection<FeaturedTemplate> {
  Future<FeaturedTemplate?> getByRemoteId(String remoteId) {
    return getByIndex(r'remoteId', [remoteId]);
  }

  FeaturedTemplate? getByRemoteIdSync(String remoteId) {
    return getByIndexSync(r'remoteId', [remoteId]);
  }

  Future<bool> deleteByRemoteId(String remoteId) {
    return deleteByIndex(r'remoteId', [remoteId]);
  }

  bool deleteByRemoteIdSync(String remoteId) {
    return deleteByIndexSync(r'remoteId', [remoteId]);
  }

  Future<List<FeaturedTemplate?>> getAllByRemoteId(
      List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'remoteId', values);
  }

  List<FeaturedTemplate?> getAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'remoteId', values);
  }

  Future<int> deleteAllByRemoteId(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'remoteId', values);
  }

  int deleteAllByRemoteIdSync(List<String> remoteIdValues) {
    final values = remoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'remoteId', values);
  }

  Future<Id> putByRemoteId(FeaturedTemplate object) {
    return putByIndex(r'remoteId', object);
  }

  Id putByRemoteIdSync(FeaturedTemplate object, {bool saveLinks = true}) {
    return putByIndexSync(r'remoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRemoteId(List<FeaturedTemplate> objects) {
    return putAllByIndex(r'remoteId', objects);
  }

  List<Id> putAllByRemoteIdSync(List<FeaturedTemplate> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'remoteId', objects, saveLinks: saveLinks);
  }
}

extension FeaturedTemplateQueryWhereSort
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QWhere> {
  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FeaturedTemplateQueryWhere
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QWhereClause> {
  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause>
      remoteIdEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'remoteId',
        value: [remoteId],
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterWhereClause>
      remoteIdNotEqualTo(String remoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [],
              upper: [remoteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [remoteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [remoteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'remoteId',
              lower: [],
              upper: [remoteId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension FeaturedTemplateQueryFilter
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QFilterCondition> {
  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bannerUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bannerUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bannerUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bannerUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      bannerUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bannerUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      isCustomizableEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCustomizable',
        value: value,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preselectedVariant',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preselectedVariant',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preselectedVariant',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preselectedVariant',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preselectedVariant',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preselectedVariant',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preselectedVariant',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preselectedVariant',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preselectedVariant',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preselectedVariant',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preselectedVariant',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      preselectedVariantIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preselectedVariant',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productIds',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productIds',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productIds',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productIds',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      productIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'productIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      remoteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subtitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subtitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtitle',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      subtitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subtitle',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetProductId',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetProductId',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetProductId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'targetProductId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'targetProductId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      targetProductIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'targetProductId',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension FeaturedTemplateQueryObject
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QFilterCondition> {}

extension FeaturedTemplateQueryLinks
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QFilterCondition> {}

extension FeaturedTemplateQuerySortBy
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QSortBy> {
  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByBannerUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerUrl', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByBannerUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerUrl', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByIsCustomizable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomizable', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByIsCustomizableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomizable', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByPreselectedVariant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preselectedVariant', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByPreselectedVariantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preselectedVariant', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByTargetProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByTargetProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension FeaturedTemplateQuerySortThenBy
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QSortThenBy> {
  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByBannerUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerUrl', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByBannerUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bannerUrl', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByIsCustomizable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomizable', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByIsCustomizableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCustomizable', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByPreselectedVariant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preselectedVariant', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByPreselectedVariantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preselectedVariant', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenBySubtitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenBySubtitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtitle', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByTargetProductId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByTargetProductIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetProductId', Sort.desc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension FeaturedTemplateQueryWhereDistinct
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct> {
  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctByBannerUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bannerUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctByIsCustomizable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCustomizable');
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctByPreselectedVariant({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preselectedVariant',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctByProductIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productIds');
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctByRemoteId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctBySubtitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct>
      distinctByTargetProductId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetProductId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FeaturedTemplate, FeaturedTemplate, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension FeaturedTemplateQueryProperty
    on QueryBuilder<FeaturedTemplate, FeaturedTemplate, QQueryProperty> {
  QueryBuilder<FeaturedTemplate, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FeaturedTemplate, String, QQueryOperations> bannerUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bannerUrl');
    });
  }

  QueryBuilder<FeaturedTemplate, bool, QQueryOperations>
      isCustomizableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCustomizable');
    });
  }

  QueryBuilder<FeaturedTemplate, String?, QQueryOperations>
      preselectedVariantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preselectedVariant');
    });
  }

  QueryBuilder<FeaturedTemplate, List<String>?, QQueryOperations>
      productIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productIds');
    });
  }

  QueryBuilder<FeaturedTemplate, String, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<FeaturedTemplate, String, QQueryOperations> subtitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtitle');
    });
  }

  QueryBuilder<FeaturedTemplate, String?, QQueryOperations>
      targetProductIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetProductId');
    });
  }

  QueryBuilder<FeaturedTemplate, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
