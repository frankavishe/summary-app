// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'summary_record.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSummaryRecordCollection on Isar {
  IsarCollection<SummaryRecord> get summaryRecords => this.collection();
}

const SummaryRecordSchema = CollectionSchema(
  name: r'SummaryRecord',
  id: -1155353463239893106,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'docType': PropertySchema(
      id: 1,
      name: r'docType',
      type: IsarType.byte,
      enumMap: _SummaryRecorddocTypeEnumValueMap,
    ),
    r'estimatedReadTimeMinutes': PropertySchema(
      id: 2,
      name: r'estimatedReadTimeMinutes',
      type: IsarType.long,
    ),
    r'executiveSummary': PropertySchema(
      id: 3,
      name: r'executiveSummary',
      type: IsarType.string,
    ),
    r'isFavorite': PropertySchema(
      id: 4,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'sections': PropertySchema(
      id: 5,
      name: r'sections',
      type: IsarType.objectList,
      target: r'SectionSummary',
    ),
    r'sourcePathOrUrl': PropertySchema(
      id: 6,
      name: r'sourcePathOrUrl',
      type: IsarType.string,
    ),
    r'title': PropertySchema(
      id: 7,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _summaryRecordEstimateSize,
  serialize: _summaryRecordSerialize,
  deserialize: _summaryRecordDeserialize,
  deserializeProp: _summaryRecordDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'SectionSummary': SectionSummarySchema},
  getId: _summaryRecordGetId,
  getLinks: _summaryRecordGetLinks,
  attach: _summaryRecordAttach,
  version: '3.1.0+1',
);

int _summaryRecordEstimateSize(
  SummaryRecord object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.executiveSummary.length * 3;
  {
    final list = object.sections;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[SectionSummary]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              SectionSummarySchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  bytesCount += 3 + object.sourcePathOrUrl.length * 3;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _summaryRecordSerialize(
  SummaryRecord object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeByte(offsets[1], object.docType.index);
  writer.writeLong(offsets[2], object.estimatedReadTimeMinutes);
  writer.writeString(offsets[3], object.executiveSummary);
  writer.writeBool(offsets[4], object.isFavorite);
  writer.writeObjectList<SectionSummary>(
    offsets[5],
    allOffsets,
    SectionSummarySchema.serialize,
    object.sections,
  );
  writer.writeString(offsets[6], object.sourcePathOrUrl);
  writer.writeString(offsets[7], object.title);
}

SummaryRecord _summaryRecordDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SummaryRecord();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.docType =
      _SummaryRecorddocTypeValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          DocumentType.pdf;
  object.estimatedReadTimeMinutes = reader.readLong(offsets[2]);
  object.executiveSummary = reader.readString(offsets[3]);
  object.id = id;
  object.isFavorite = reader.readBool(offsets[4]);
  object.sections = reader.readObjectList<SectionSummary>(
    offsets[5],
    SectionSummarySchema.deserialize,
    allOffsets,
    SectionSummary(),
  );
  object.sourcePathOrUrl = reader.readString(offsets[6]);
  object.title = reader.readString(offsets[7]);
  return object;
}

P _summaryRecordDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (_SummaryRecorddocTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          DocumentType.pdf) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readObjectList<SectionSummary>(
        offset,
        SectionSummarySchema.deserialize,
        allOffsets,
        SectionSummary(),
      )) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SummaryRecorddocTypeEnumValueMap = {
  'pdf': 0,
  'docx': 1,
  'excel': 2,
  'webArticle': 3,
};
const _SummaryRecorddocTypeValueEnumMap = {
  0: DocumentType.pdf,
  1: DocumentType.docx,
  2: DocumentType.excel,
  3: DocumentType.webArticle,
};

Id _summaryRecordGetId(SummaryRecord object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _summaryRecordGetLinks(SummaryRecord object) {
  return [];
}

void _summaryRecordAttach(
    IsarCollection<dynamic> col, Id id, SummaryRecord object) {
  object.id = id;
}

extension SummaryRecordQueryWhereSort
    on QueryBuilder<SummaryRecord, SummaryRecord, QWhere> {
  QueryBuilder<SummaryRecord, SummaryRecord, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SummaryRecordQueryWhere
    on QueryBuilder<SummaryRecord, SummaryRecord, QWhereClause> {
  QueryBuilder<SummaryRecord, SummaryRecord, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterWhereClause> idBetween(
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
}

extension SummaryRecordQueryFilter
    on QueryBuilder<SummaryRecord, SummaryRecord, QFilterCondition> {
  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      docTypeEqualTo(DocumentType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'docType',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      docTypeGreaterThan(
    DocumentType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'docType',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      docTypeLessThan(
    DocumentType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'docType',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      docTypeBetween(
    DocumentType lower,
    DocumentType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'docType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      estimatedReadTimeMinutesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estimatedReadTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      estimatedReadTimeMinutesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estimatedReadTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      estimatedReadTimeMinutesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estimatedReadTimeMinutes',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      estimatedReadTimeMinutesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estimatedReadTimeMinutes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'executiveSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'executiveSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'executiveSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'executiveSummary',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'executiveSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'executiveSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'executiveSummary',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'executiveSummary',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'executiveSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      executiveSummaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'executiveSummary',
        value: '',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sections',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sections',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sections',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sections',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sections',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sections',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sections',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sections',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePathOrUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourcePathOrUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourcePathOrUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourcePathOrUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourcePathOrUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourcePathOrUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourcePathOrUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourcePathOrUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourcePathOrUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sourcePathOrUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourcePathOrUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
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

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension SummaryRecordQueryObject
    on QueryBuilder<SummaryRecord, SummaryRecord, QFilterCondition> {
  QueryBuilder<SummaryRecord, SummaryRecord, QAfterFilterCondition>
      sectionsElement(FilterQuery<SectionSummary> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'sections');
    });
  }
}

extension SummaryRecordQueryLinks
    on QueryBuilder<SummaryRecord, SummaryRecord, QFilterCondition> {}

extension SummaryRecordQuerySortBy
    on QueryBuilder<SummaryRecord, SummaryRecord, QSortBy> {
  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> sortByDocType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> sortByDocTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortByEstimatedReadTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedReadTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortByEstimatedReadTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedReadTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortByExecutiveSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executiveSummary', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortByExecutiveSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executiveSummary', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortBySourcePathOrUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePathOrUrl', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      sortBySourcePathOrUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePathOrUrl', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SummaryRecordQuerySortThenBy
    on QueryBuilder<SummaryRecord, SummaryRecord, QSortThenBy> {
  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByDocType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByDocTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'docType', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenByEstimatedReadTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedReadTimeMinutes', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenByEstimatedReadTimeMinutesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estimatedReadTimeMinutes', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenByExecutiveSummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executiveSummary', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenByExecutiveSummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'executiveSummary', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenBySourcePathOrUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePathOrUrl', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy>
      thenBySourcePathOrUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourcePathOrUrl', Sort.desc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension SummaryRecordQueryWhereDistinct
    on QueryBuilder<SummaryRecord, SummaryRecord, QDistinct> {
  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct> distinctByDocType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'docType');
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct>
      distinctByEstimatedReadTimeMinutes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estimatedReadTimeMinutes');
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct>
      distinctByExecutiveSummary({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'executiveSummary',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct>
      distinctBySourcePathOrUrl({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourcePathOrUrl',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SummaryRecord, SummaryRecord, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension SummaryRecordQueryProperty
    on QueryBuilder<SummaryRecord, SummaryRecord, QQueryProperty> {
  QueryBuilder<SummaryRecord, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SummaryRecord, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SummaryRecord, DocumentType, QQueryOperations>
      docTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'docType');
    });
  }

  QueryBuilder<SummaryRecord, int, QQueryOperations>
      estimatedReadTimeMinutesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estimatedReadTimeMinutes');
    });
  }

  QueryBuilder<SummaryRecord, String, QQueryOperations>
      executiveSummaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'executiveSummary');
    });
  }

  QueryBuilder<SummaryRecord, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<SummaryRecord, List<SectionSummary>?, QQueryOperations>
      sectionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sections');
    });
  }

  QueryBuilder<SummaryRecord, String, QQueryOperations>
      sourcePathOrUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourcePathOrUrl');
    });
  }

  QueryBuilder<SummaryRecord, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const SectionSummarySchema = Schema(
  name: r'SectionSummary',
  id: -3273202715188360102,
  properties: {
    r'keyPoints': PropertySchema(
      id: 0,
      name: r'keyPoints',
      type: IsarType.stringList,
    ),
    r'sectionTitle': PropertySchema(
      id: 1,
      name: r'sectionTitle',
      type: IsarType.string,
    ),
    r'summaryText': PropertySchema(
      id: 2,
      name: r'summaryText',
      type: IsarType.string,
    )
  },
  estimateSize: _sectionSummaryEstimateSize,
  serialize: _sectionSummarySerialize,
  deserialize: _sectionSummaryDeserialize,
  deserializeProp: _sectionSummaryDeserializeProp,
);

int _sectionSummaryEstimateSize(
  SectionSummary object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.keyPoints;
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
  {
    final value = object.sectionTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.summaryText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sectionSummarySerialize(
  SectionSummary object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.keyPoints);
  writer.writeString(offsets[1], object.sectionTitle);
  writer.writeString(offsets[2], object.summaryText);
}

SectionSummary _sectionSummaryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SectionSummary();
  object.keyPoints = reader.readStringList(offsets[0]);
  object.sectionTitle = reader.readStringOrNull(offsets[1]);
  object.summaryText = reader.readStringOrNull(offsets[2]);
  return object;
}

P _sectionSummaryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension SectionSummaryQueryFilter
    on QueryBuilder<SectionSummary, SectionSummary, QFilterCondition> {
  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'keyPoints',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'keyPoints',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyPoints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'keyPoints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'keyPoints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'keyPoints',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'keyPoints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'keyPoints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'keyPoints',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'keyPoints',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'keyPoints',
        value: '',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'keyPoints',
        value: '',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyPoints',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyPoints',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyPoints',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyPoints',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyPoints',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      keyPointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keyPoints',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sectionTitle',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sectionTitle',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sectionTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sectionTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectionTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      sectionTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sectionTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'summaryText',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'summaryText',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'summaryText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'summaryText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'summaryText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'summaryText',
        value: '',
      ));
    });
  }

  QueryBuilder<SectionSummary, SectionSummary, QAfterFilterCondition>
      summaryTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'summaryText',
        value: '',
      ));
    });
  }
}

extension SectionSummaryQueryObject
    on QueryBuilder<SectionSummary, SectionSummary, QFilterCondition> {}
