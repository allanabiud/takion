// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LibraryItemsTable extends LibraryItems
    with TableInfo<$LibraryItemsTable, LibraryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metronIssueIdMeta = const VerificationMeta(
    'metronIssueId',
  );
  @override
  late final GeneratedColumn<int> metronIssueId = GeneratedColumn<int>(
    'metron_issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metronSeriesIdMeta = const VerificationMeta(
    'metronSeriesId',
  );
  @override
  late final GeneratedColumn<int> metronSeriesId = GeneratedColumn<int>(
    'metron_series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownershipStatusMeta = const VerificationMeta(
    'ownershipStatus',
  );
  @override
  late final GeneratedColumn<String> ownershipStatus = GeneratedColumn<String>(
    'ownership_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<String> purchaseDate = GeneratedColumn<String>(
    'purchase_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePaidMeta = const VerificationMeta(
    'pricePaid',
  );
  @override
  late final GeneratedColumn<double> pricePaid = GeneratedColumn<double>(
    'price_paid',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityOwnedMeta = const VerificationMeta(
    'quantityOwned',
  );
  @override
  late final GeneratedColumn<int> quantityOwned = GeneratedColumn<int>(
    'quantity_owned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstReadAtMeta = const VerificationMeta(
    'firstReadAt',
  );
  @override
  late final GeneratedColumn<String> firstReadAt = GeneratedColumn<String>(
    'first_read_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conditionGradeMeta = const VerificationMeta(
    'conditionGrade',
  );
  @override
  late final GeneratedColumn<String> conditionGrade = GeneratedColumn<String>(
    'condition_grade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _acquiredOnMeta = const VerificationMeta(
    'acquiredOn',
  );
  @override
  late final GeneratedColumn<String> acquiredOn = GeneratedColumn<String>(
    'acquired_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    metronIssueId,
    metronSeriesId,
    ownershipStatus,
    isRead,
    rating,
    purchaseDate,
    pricePaid,
    quantityOwned,
    format,
    firstReadAt,
    conditionGrade,
    acquiredOn,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('metron_issue_id')) {
      context.handle(
        _metronIssueIdMeta,
        metronIssueId.isAcceptableOrUnknown(
          data['metron_issue_id']!,
          _metronIssueIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metronIssueIdMeta);
    }
    if (data.containsKey('metron_series_id')) {
      context.handle(
        _metronSeriesIdMeta,
        metronSeriesId.isAcceptableOrUnknown(
          data['metron_series_id']!,
          _metronSeriesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metronSeriesIdMeta);
    }
    if (data.containsKey('ownership_status')) {
      context.handle(
        _ownershipStatusMeta,
        ownershipStatus.isAcceptableOrUnknown(
          data['ownership_status']!,
          _ownershipStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownershipStatusMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    } else if (isInserting) {
      context.missing(_isReadMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('price_paid')) {
      context.handle(
        _pricePaidMeta,
        pricePaid.isAcceptableOrUnknown(data['price_paid']!, _pricePaidMeta),
      );
    }
    if (data.containsKey('quantity_owned')) {
      context.handle(
        _quantityOwnedMeta,
        quantityOwned.isAcceptableOrUnknown(
          data['quantity_owned']!,
          _quantityOwnedMeta,
        ),
      );
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('first_read_at')) {
      context.handle(
        _firstReadAtMeta,
        firstReadAt.isAcceptableOrUnknown(
          data['first_read_at']!,
          _firstReadAtMeta,
        ),
      );
    }
    if (data.containsKey('condition_grade')) {
      context.handle(
        _conditionGradeMeta,
        conditionGrade.isAcceptableOrUnknown(
          data['condition_grade']!,
          _conditionGradeMeta,
        ),
      );
    }
    if (data.containsKey('acquired_on')) {
      context.handle(
        _acquiredOnMeta,
        acquiredOn.isAcceptableOrUnknown(data['acquired_on']!, _acquiredOnMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      metronIssueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_issue_id'],
      )!,
      metronSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_series_id'],
      )!,
      ownershipStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ownership_status'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_date'],
      ),
      pricePaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_paid'],
      ),
      quantityOwned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_owned'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      firstReadAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_read_at'],
      ),
      conditionGrade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_grade'],
      ),
      acquiredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}acquired_on'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LibraryItemsTable createAlias(String alias) {
    return $LibraryItemsTable(attachedDatabase, alias);
  }
}

class LibraryItem extends DataClass implements Insertable<LibraryItem> {
  final String id;
  final String userId;
  final int metronIssueId;
  final int metronSeriesId;
  final String ownershipStatus;
  final bool isRead;
  final int? rating;
  final String? purchaseDate;
  final double? pricePaid;
  final int quantityOwned;
  final String format;
  final String? firstReadAt;
  final String? conditionGrade;
  final String? acquiredOn;
  final String? notes;
  final String createdAt;
  final String updatedAt;
  const LibraryItem({
    required this.id,
    required this.userId,
    required this.metronIssueId,
    required this.metronSeriesId,
    required this.ownershipStatus,
    required this.isRead,
    this.rating,
    this.purchaseDate,
    this.pricePaid,
    required this.quantityOwned,
    required this.format,
    this.firstReadAt,
    this.conditionGrade,
    this.acquiredOn,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['metron_issue_id'] = Variable<int>(metronIssueId);
    map['metron_series_id'] = Variable<int>(metronSeriesId);
    map['ownership_status'] = Variable<String>(ownershipStatus);
    map['is_read'] = Variable<bool>(isRead);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || purchaseDate != null) {
      map['purchase_date'] = Variable<String>(purchaseDate);
    }
    if (!nullToAbsent || pricePaid != null) {
      map['price_paid'] = Variable<double>(pricePaid);
    }
    map['quantity_owned'] = Variable<int>(quantityOwned);
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || firstReadAt != null) {
      map['first_read_at'] = Variable<String>(firstReadAt);
    }
    if (!nullToAbsent || conditionGrade != null) {
      map['condition_grade'] = Variable<String>(conditionGrade);
    }
    if (!nullToAbsent || acquiredOn != null) {
      map['acquired_on'] = Variable<String>(acquiredOn);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  LibraryItemsCompanion toCompanion(bool nullToAbsent) {
    return LibraryItemsCompanion(
      id: Value(id),
      userId: Value(userId),
      metronIssueId: Value(metronIssueId),
      metronSeriesId: Value(metronSeriesId),
      ownershipStatus: Value(ownershipStatus),
      isRead: Value(isRead),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      purchaseDate: purchaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseDate),
      pricePaid: pricePaid == null && nullToAbsent
          ? const Value.absent()
          : Value(pricePaid),
      quantityOwned: Value(quantityOwned),
      format: Value(format),
      firstReadAt: firstReadAt == null && nullToAbsent
          ? const Value.absent()
          : Value(firstReadAt),
      conditionGrade: conditionGrade == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionGrade),
      acquiredOn: acquiredOn == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredOn),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryItem(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      metronIssueId: serializer.fromJson<int>(json['metronIssueId']),
      metronSeriesId: serializer.fromJson<int>(json['metronSeriesId']),
      ownershipStatus: serializer.fromJson<String>(json['ownershipStatus']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      rating: serializer.fromJson<int?>(json['rating']),
      purchaseDate: serializer.fromJson<String?>(json['purchaseDate']),
      pricePaid: serializer.fromJson<double?>(json['pricePaid']),
      quantityOwned: serializer.fromJson<int>(json['quantityOwned']),
      format: serializer.fromJson<String>(json['format']),
      firstReadAt: serializer.fromJson<String?>(json['firstReadAt']),
      conditionGrade: serializer.fromJson<String?>(json['conditionGrade']),
      acquiredOn: serializer.fromJson<String?>(json['acquiredOn']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'metronIssueId': serializer.toJson<int>(metronIssueId),
      'metronSeriesId': serializer.toJson<int>(metronSeriesId),
      'ownershipStatus': serializer.toJson<String>(ownershipStatus),
      'isRead': serializer.toJson<bool>(isRead),
      'rating': serializer.toJson<int?>(rating),
      'purchaseDate': serializer.toJson<String?>(purchaseDate),
      'pricePaid': serializer.toJson<double?>(pricePaid),
      'quantityOwned': serializer.toJson<int>(quantityOwned),
      'format': serializer.toJson<String>(format),
      'firstReadAt': serializer.toJson<String?>(firstReadAt),
      'conditionGrade': serializer.toJson<String?>(conditionGrade),
      'acquiredOn': serializer.toJson<String?>(acquiredOn),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  LibraryItem copyWith({
    String? id,
    String? userId,
    int? metronIssueId,
    int? metronSeriesId,
    String? ownershipStatus,
    bool? isRead,
    Value<int?> rating = const Value.absent(),
    Value<String?> purchaseDate = const Value.absent(),
    Value<double?> pricePaid = const Value.absent(),
    int? quantityOwned,
    String? format,
    Value<String?> firstReadAt = const Value.absent(),
    Value<String?> conditionGrade = const Value.absent(),
    Value<String?> acquiredOn = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => LibraryItem(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    metronIssueId: metronIssueId ?? this.metronIssueId,
    metronSeriesId: metronSeriesId ?? this.metronSeriesId,
    ownershipStatus: ownershipStatus ?? this.ownershipStatus,
    isRead: isRead ?? this.isRead,
    rating: rating.present ? rating.value : this.rating,
    purchaseDate: purchaseDate.present ? purchaseDate.value : this.purchaseDate,
    pricePaid: pricePaid.present ? pricePaid.value : this.pricePaid,
    quantityOwned: quantityOwned ?? this.quantityOwned,
    format: format ?? this.format,
    firstReadAt: firstReadAt.present ? firstReadAt.value : this.firstReadAt,
    conditionGrade: conditionGrade.present
        ? conditionGrade.value
        : this.conditionGrade,
    acquiredOn: acquiredOn.present ? acquiredOn.value : this.acquiredOn,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryItem copyWithCompanion(LibraryItemsCompanion data) {
    return LibraryItem(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      metronIssueId: data.metronIssueId.present
          ? data.metronIssueId.value
          : this.metronIssueId,
      metronSeriesId: data.metronSeriesId.present
          ? data.metronSeriesId.value
          : this.metronSeriesId,
      ownershipStatus: data.ownershipStatus.present
          ? data.ownershipStatus.value
          : this.ownershipStatus,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      rating: data.rating.present ? data.rating.value : this.rating,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      pricePaid: data.pricePaid.present ? data.pricePaid.value : this.pricePaid,
      quantityOwned: data.quantityOwned.present
          ? data.quantityOwned.value
          : this.quantityOwned,
      format: data.format.present ? data.format.value : this.format,
      firstReadAt: data.firstReadAt.present
          ? data.firstReadAt.value
          : this.firstReadAt,
      conditionGrade: data.conditionGrade.present
          ? data.conditionGrade.value
          : this.conditionGrade,
      acquiredOn: data.acquiredOn.present
          ? data.acquiredOn.value
          : this.acquiredOn,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItem(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('metronIssueId: $metronIssueId, ')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('ownershipStatus: $ownershipStatus, ')
          ..write('isRead: $isRead, ')
          ..write('rating: $rating, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('quantityOwned: $quantityOwned, ')
          ..write('format: $format, ')
          ..write('firstReadAt: $firstReadAt, ')
          ..write('conditionGrade: $conditionGrade, ')
          ..write('acquiredOn: $acquiredOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    metronIssueId,
    metronSeriesId,
    ownershipStatus,
    isRead,
    rating,
    purchaseDate,
    pricePaid,
    quantityOwned,
    format,
    firstReadAt,
    conditionGrade,
    acquiredOn,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryItem &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.metronIssueId == this.metronIssueId &&
          other.metronSeriesId == this.metronSeriesId &&
          other.ownershipStatus == this.ownershipStatus &&
          other.isRead == this.isRead &&
          other.rating == this.rating &&
          other.purchaseDate == this.purchaseDate &&
          other.pricePaid == this.pricePaid &&
          other.quantityOwned == this.quantityOwned &&
          other.format == this.format &&
          other.firstReadAt == this.firstReadAt &&
          other.conditionGrade == this.conditionGrade &&
          other.acquiredOn == this.acquiredOn &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LibraryItemsCompanion extends UpdateCompanion<LibraryItem> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> metronIssueId;
  final Value<int> metronSeriesId;
  final Value<String> ownershipStatus;
  final Value<bool> isRead;
  final Value<int?> rating;
  final Value<String?> purchaseDate;
  final Value<double?> pricePaid;
  final Value<int> quantityOwned;
  final Value<String> format;
  final Value<String?> firstReadAt;
  final Value<String?> conditionGrade;
  final Value<String?> acquiredOn;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const LibraryItemsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.metronIssueId = const Value.absent(),
    this.metronSeriesId = const Value.absent(),
    this.ownershipStatus = const Value.absent(),
    this.isRead = const Value.absent(),
    this.rating = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.quantityOwned = const Value.absent(),
    this.format = const Value.absent(),
    this.firstReadAt = const Value.absent(),
    this.conditionGrade = const Value.absent(),
    this.acquiredOn = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryItemsCompanion.insert({
    required String id,
    required String userId,
    required int metronIssueId,
    required int metronSeriesId,
    required String ownershipStatus,
    required bool isRead,
    this.rating = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.quantityOwned = const Value.absent(),
    required String format,
    this.firstReadAt = const Value.absent(),
    this.conditionGrade = const Value.absent(),
    this.acquiredOn = const Value.absent(),
    this.notes = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       metronIssueId = Value(metronIssueId),
       metronSeriesId = Value(metronSeriesId),
       ownershipStatus = Value(ownershipStatus),
       isRead = Value(isRead),
       format = Value(format),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LibraryItem> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? metronIssueId,
    Expression<int>? metronSeriesId,
    Expression<String>? ownershipStatus,
    Expression<bool>? isRead,
    Expression<int>? rating,
    Expression<String>? purchaseDate,
    Expression<double>? pricePaid,
    Expression<int>? quantityOwned,
    Expression<String>? format,
    Expression<String>? firstReadAt,
    Expression<String>? conditionGrade,
    Expression<String>? acquiredOn,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (metronIssueId != null) 'metron_issue_id': metronIssueId,
      if (metronSeriesId != null) 'metron_series_id': metronSeriesId,
      if (ownershipStatus != null) 'ownership_status': ownershipStatus,
      if (isRead != null) 'is_read': isRead,
      if (rating != null) 'rating': rating,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (pricePaid != null) 'price_paid': pricePaid,
      if (quantityOwned != null) 'quantity_owned': quantityOwned,
      if (format != null) 'format': format,
      if (firstReadAt != null) 'first_read_at': firstReadAt,
      if (conditionGrade != null) 'condition_grade': conditionGrade,
      if (acquiredOn != null) 'acquired_on': acquiredOn,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? metronIssueId,
    Value<int>? metronSeriesId,
    Value<String>? ownershipStatus,
    Value<bool>? isRead,
    Value<int?>? rating,
    Value<String?>? purchaseDate,
    Value<double?>? pricePaid,
    Value<int>? quantityOwned,
    Value<String>? format,
    Value<String?>? firstReadAt,
    Value<String?>? conditionGrade,
    Value<String?>? acquiredOn,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return LibraryItemsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metronIssueId: metronIssueId ?? this.metronIssueId,
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      isRead: isRead ?? this.isRead,
      rating: rating ?? this.rating,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      pricePaid: pricePaid ?? this.pricePaid,
      quantityOwned: quantityOwned ?? this.quantityOwned,
      format: format ?? this.format,
      firstReadAt: firstReadAt ?? this.firstReadAt,
      conditionGrade: conditionGrade ?? this.conditionGrade,
      acquiredOn: acquiredOn ?? this.acquiredOn,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (metronIssueId.present) {
      map['metron_issue_id'] = Variable<int>(metronIssueId.value);
    }
    if (metronSeriesId.present) {
      map['metron_series_id'] = Variable<int>(metronSeriesId.value);
    }
    if (ownershipStatus.present) {
      map['ownership_status'] = Variable<String>(ownershipStatus.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<String>(purchaseDate.value);
    }
    if (pricePaid.present) {
      map['price_paid'] = Variable<double>(pricePaid.value);
    }
    if (quantityOwned.present) {
      map['quantity_owned'] = Variable<int>(quantityOwned.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (firstReadAt.present) {
      map['first_read_at'] = Variable<String>(firstReadAt.value);
    }
    if (conditionGrade.present) {
      map['condition_grade'] = Variable<String>(conditionGrade.value);
    }
    if (acquiredOn.present) {
      map['acquired_on'] = Variable<String>(acquiredOn.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryItemsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('metronIssueId: $metronIssueId, ')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('ownershipStatus: $ownershipStatus, ')
          ..write('isRead: $isRead, ')
          ..write('rating: $rating, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('quantityOwned: $quantityOwned, ')
          ..write('format: $format, ')
          ..write('firstReadAt: $firstReadAt, ')
          ..write('conditionGrade: $conditionGrade, ')
          ..write('acquiredOn: $acquiredOn, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryReadLogsTable extends LibraryReadLogs
    with TableInfo<$LibraryReadLogsTable, LibraryReadLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryReadLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionItemIdMeta = const VerificationMeta(
    'collectionItemId',
  );
  @override
  late final GeneratedColumn<String> collectionItemId = GeneratedColumn<String>(
    'collection_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<String> readAt = GeneratedColumn<String>(
    'read_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    collectionItemId,
    readAt,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_read_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryReadLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('collection_item_id')) {
      context.handle(
        _collectionItemIdMeta,
        collectionItemId.isAcceptableOrUnknown(
          data['collection_item_id']!,
          _collectionItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionItemIdMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    } else if (isInserting) {
      context.missing(_readAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LibraryReadLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryReadLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      collectionItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_item_id'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}read_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LibraryReadLogsTable createAlias(String alias) {
    return $LibraryReadLogsTable(attachedDatabase, alias);
  }
}

class LibraryReadLog extends DataClass implements Insertable<LibraryReadLog> {
  final String id;
  final String userId;
  final String collectionItemId;
  final String readAt;
  final String? notes;
  final String createdAt;
  const LibraryReadLog({
    required this.id,
    required this.userId,
    required this.collectionItemId,
    required this.readAt,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['collection_item_id'] = Variable<String>(collectionItemId);
    map['read_at'] = Variable<String>(readAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  LibraryReadLogsCompanion toCompanion(bool nullToAbsent) {
    return LibraryReadLogsCompanion(
      id: Value(id),
      userId: Value(userId),
      collectionItemId: Value(collectionItemId),
      readAt: Value(readAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory LibraryReadLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryReadLog(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      collectionItemId: serializer.fromJson<String>(json['collectionItemId']),
      readAt: serializer.fromJson<String>(json['readAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'collectionItemId': serializer.toJson<String>(collectionItemId),
      'readAt': serializer.toJson<String>(readAt),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  LibraryReadLog copyWith({
    String? id,
    String? userId,
    String? collectionItemId,
    String? readAt,
    Value<String?> notes = const Value.absent(),
    String? createdAt,
  }) => LibraryReadLog(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    collectionItemId: collectionItemId ?? this.collectionItemId,
    readAt: readAt ?? this.readAt,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  LibraryReadLog copyWithCompanion(LibraryReadLogsCompanion data) {
    return LibraryReadLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      collectionItemId: data.collectionItemId.present
          ? data.collectionItemId.value
          : this.collectionItemId,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryReadLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('collectionItemId: $collectionItemId, ')
          ..write('readAt: $readAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, collectionItemId, readAt, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryReadLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.collectionItemId == this.collectionItemId &&
          other.readAt == this.readAt &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class LibraryReadLogsCompanion extends UpdateCompanion<LibraryReadLog> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> collectionItemId;
  final Value<String> readAt;
  final Value<String?> notes;
  final Value<String> createdAt;
  final Value<int> rowid;
  const LibraryReadLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.collectionItemId = const Value.absent(),
    this.readAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryReadLogsCompanion.insert({
    required String id,
    required String userId,
    required String collectionItemId,
    required String readAt,
    this.notes = const Value.absent(),
    required String createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       collectionItemId = Value(collectionItemId),
       readAt = Value(readAt),
       createdAt = Value(createdAt);
  static Insertable<LibraryReadLog> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? collectionItemId,
    Expression<String>? readAt,
    Expression<String>? notes,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (collectionItemId != null) 'collection_item_id': collectionItemId,
      if (readAt != null) 'read_at': readAt,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryReadLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? collectionItemId,
    Value<String>? readAt,
    Value<String?>? notes,
    Value<String>? createdAt,
    Value<int>? rowid,
  }) {
    return LibraryReadLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      collectionItemId: collectionItemId ?? this.collectionItemId,
      readAt: readAt ?? this.readAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (collectionItemId.present) {
      map['collection_item_id'] = Variable<String>(collectionItemId.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<String>(readAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryReadLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('collectionItemId: $collectionItemId, ')
          ..write('readAt: $readAt, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PullListEntriesTable extends PullListEntries
    with TableInfo<$PullListEntriesTable, PullListEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PullListEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metronIssueIdMeta = const VerificationMeta(
    'metronIssueId',
  );
  @override
  late final GeneratedColumn<int> metronIssueId = GeneratedColumn<int>(
    'metron_issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metronSeriesIdMeta = const VerificationMeta(
    'metronSeriesId',
  );
  @override
  late final GeneratedColumn<int> metronSeriesId = GeneratedColumn<int>(
    'metron_series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryStatusMeta = const VerificationMeta(
    'entryStatus',
  );
  @override
  late final GeneratedColumn<String> entryStatus = GeneratedColumn<String>(
    'entry_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> releaseDate = GeneratedColumn<DateTime>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<String> generatedAt = GeneratedColumn<String>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    metronIssueId,
    metronSeriesId,
    entryStatus,
    releaseDate,
    source,
    generatedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pull_list_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PullListEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('metron_issue_id')) {
      context.handle(
        _metronIssueIdMeta,
        metronIssueId.isAcceptableOrUnknown(
          data['metron_issue_id']!,
          _metronIssueIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metronIssueIdMeta);
    }
    if (data.containsKey('metron_series_id')) {
      context.handle(
        _metronSeriesIdMeta,
        metronSeriesId.isAcceptableOrUnknown(
          data['metron_series_id']!,
          _metronSeriesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metronSeriesIdMeta);
    }
    if (data.containsKey('entry_status')) {
      context.handle(
        _entryStatusMeta,
        entryStatus.isAcceptableOrUnknown(
          data['entry_status']!,
          _entryStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entryStatusMeta);
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PullListEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PullListEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      metronIssueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_issue_id'],
      )!,
      metronSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_series_id'],
      )!,
      entryStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_status'],
      )!,
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}release_date'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generated_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PullListEntriesTable createAlias(String alias) {
    return $PullListEntriesTable(attachedDatabase, alias);
  }
}

class PullListEntry extends DataClass implements Insertable<PullListEntry> {
  final String id;
  final String userId;
  final int metronIssueId;
  final int metronSeriesId;
  final String entryStatus;
  final DateTime? releaseDate;
  final String source;
  final String generatedAt;
  final String createdAt;
  final String updatedAt;
  const PullListEntry({
    required this.id,
    required this.userId,
    required this.metronIssueId,
    required this.metronSeriesId,
    required this.entryStatus,
    this.releaseDate,
    required this.source,
    required this.generatedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['metron_issue_id'] = Variable<int>(metronIssueId);
    map['metron_series_id'] = Variable<int>(metronSeriesId);
    map['entry_status'] = Variable<String>(entryStatus);
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<DateTime>(releaseDate);
    }
    map['source'] = Variable<String>(source);
    map['generated_at'] = Variable<String>(generatedAt);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  PullListEntriesCompanion toCompanion(bool nullToAbsent) {
    return PullListEntriesCompanion(
      id: Value(id),
      userId: Value(userId),
      metronIssueId: Value(metronIssueId),
      metronSeriesId: Value(metronSeriesId),
      entryStatus: Value(entryStatus),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      source: Value(source),
      generatedAt: Value(generatedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PullListEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PullListEntry(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      metronIssueId: serializer.fromJson<int>(json['metronIssueId']),
      metronSeriesId: serializer.fromJson<int>(json['metronSeriesId']),
      entryStatus: serializer.fromJson<String>(json['entryStatus']),
      releaseDate: serializer.fromJson<DateTime?>(json['releaseDate']),
      source: serializer.fromJson<String>(json['source']),
      generatedAt: serializer.fromJson<String>(json['generatedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'metronIssueId': serializer.toJson<int>(metronIssueId),
      'metronSeriesId': serializer.toJson<int>(metronSeriesId),
      'entryStatus': serializer.toJson<String>(entryStatus),
      'releaseDate': serializer.toJson<DateTime?>(releaseDate),
      'source': serializer.toJson<String>(source),
      'generatedAt': serializer.toJson<String>(generatedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  PullListEntry copyWith({
    String? id,
    String? userId,
    int? metronIssueId,
    int? metronSeriesId,
    String? entryStatus,
    Value<DateTime?> releaseDate = const Value.absent(),
    String? source,
    String? generatedAt,
    String? createdAt,
    String? updatedAt,
  }) => PullListEntry(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    metronIssueId: metronIssueId ?? this.metronIssueId,
    metronSeriesId: metronSeriesId ?? this.metronSeriesId,
    entryStatus: entryStatus ?? this.entryStatus,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    source: source ?? this.source,
    generatedAt: generatedAt ?? this.generatedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PullListEntry copyWithCompanion(PullListEntriesCompanion data) {
    return PullListEntry(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      metronIssueId: data.metronIssueId.present
          ? data.metronIssueId.value
          : this.metronIssueId,
      metronSeriesId: data.metronSeriesId.present
          ? data.metronSeriesId.value
          : this.metronSeriesId,
      entryStatus: data.entryStatus.present
          ? data.entryStatus.value
          : this.entryStatus,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      source: data.source.present ? data.source.value : this.source,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PullListEntry(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('metronIssueId: $metronIssueId, ')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('entryStatus: $entryStatus, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('source: $source, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    metronIssueId,
    metronSeriesId,
    entryStatus,
    releaseDate,
    source,
    generatedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PullListEntry &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.metronIssueId == this.metronIssueId &&
          other.metronSeriesId == this.metronSeriesId &&
          other.entryStatus == this.entryStatus &&
          other.releaseDate == this.releaseDate &&
          other.source == this.source &&
          other.generatedAt == this.generatedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PullListEntriesCompanion extends UpdateCompanion<PullListEntry> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> metronIssueId;
  final Value<int> metronSeriesId;
  final Value<String> entryStatus;
  final Value<DateTime?> releaseDate;
  final Value<String> source;
  final Value<String> generatedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const PullListEntriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.metronIssueId = const Value.absent(),
    this.metronSeriesId = const Value.absent(),
    this.entryStatus = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.source = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PullListEntriesCompanion.insert({
    required String id,
    required String userId,
    required int metronIssueId,
    required int metronSeriesId,
    required String entryStatus,
    this.releaseDate = const Value.absent(),
    required String source,
    required String generatedAt,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       metronIssueId = Value(metronIssueId),
       metronSeriesId = Value(metronSeriesId),
       entryStatus = Value(entryStatus),
       source = Value(source),
       generatedAt = Value(generatedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PullListEntry> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? metronIssueId,
    Expression<int>? metronSeriesId,
    Expression<String>? entryStatus,
    Expression<DateTime>? releaseDate,
    Expression<String>? source,
    Expression<String>? generatedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (metronIssueId != null) 'metron_issue_id': metronIssueId,
      if (metronSeriesId != null) 'metron_series_id': metronSeriesId,
      if (entryStatus != null) 'entry_status': entryStatus,
      if (releaseDate != null) 'release_date': releaseDate,
      if (source != null) 'source': source,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PullListEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? metronIssueId,
    Value<int>? metronSeriesId,
    Value<String>? entryStatus,
    Value<DateTime?>? releaseDate,
    Value<String>? source,
    Value<String>? generatedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return PullListEntriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metronIssueId: metronIssueId ?? this.metronIssueId,
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      entryStatus: entryStatus ?? this.entryStatus,
      releaseDate: releaseDate ?? this.releaseDate,
      source: source ?? this.source,
      generatedAt: generatedAt ?? this.generatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (metronIssueId.present) {
      map['metron_issue_id'] = Variable<int>(metronIssueId.value);
    }
    if (metronSeriesId.present) {
      map['metron_series_id'] = Variable<int>(metronSeriesId.value);
    }
    if (entryStatus.present) {
      map['entry_status'] = Variable<String>(entryStatus.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<DateTime>(releaseDate.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<String>(generatedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PullListEntriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('metronIssueId: $metronIssueId, ')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('entryStatus: $entryStatus, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('source: $source, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesSubscriptionsTable extends SeriesSubscriptions
    with TableInfo<$SeriesSubscriptionsTable, SeriesSubscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesSubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metronSeriesIdMeta = const VerificationMeta(
    'metronSeriesId',
  );
  @override
  late final GeneratedColumn<int> metronSeriesId = GeneratedColumn<int>(
    'metron_series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _autoAddPullMeta = const VerificationMeta(
    'autoAddPull',
  );
  @override
  late final GeneratedColumn<bool> autoAddPull = GeneratedColumn<bool>(
    'auto_add_pull',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_add_pull" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _subscribedAtMeta = const VerificationMeta(
    'subscribedAt',
  );
  @override
  late final GeneratedColumn<String> subscribedAt = GeneratedColumn<String>(
    'subscribed_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    metronSeriesId,
    isActive,
    autoAddPull,
    subscribedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesSubscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('metron_series_id')) {
      context.handle(
        _metronSeriesIdMeta,
        metronSeriesId.isAcceptableOrUnknown(
          data['metron_series_id']!,
          _metronSeriesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_metronSeriesIdMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('auto_add_pull')) {
      context.handle(
        _autoAddPullMeta,
        autoAddPull.isAcceptableOrUnknown(
          data['auto_add_pull']!,
          _autoAddPullMeta,
        ),
      );
    }
    if (data.containsKey('subscribed_at')) {
      context.handle(
        _subscribedAtMeta,
        subscribedAt.isAcceptableOrUnknown(
          data['subscribed_at']!,
          _subscribedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscribedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesSubscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesSubscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      metronSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_series_id'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      autoAddPull: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_add_pull'],
      )!,
      subscribedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscribed_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SeriesSubscriptionsTable createAlias(String alias) {
    return $SeriesSubscriptionsTable(attachedDatabase, alias);
  }
}

class SeriesSubscription extends DataClass
    implements Insertable<SeriesSubscription> {
  final String id;
  final String userId;
  final int metronSeriesId;
  final bool isActive;
  final bool autoAddPull;
  final String subscribedAt;
  final String createdAt;
  final String updatedAt;
  const SeriesSubscription({
    required this.id,
    required this.userId,
    required this.metronSeriesId,
    required this.isActive,
    required this.autoAddPull,
    required this.subscribedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['metron_series_id'] = Variable<int>(metronSeriesId);
    map['is_active'] = Variable<bool>(isActive);
    map['auto_add_pull'] = Variable<bool>(autoAddPull);
    map['subscribed_at'] = Variable<String>(subscribedAt);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  SeriesSubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SeriesSubscriptionsCompanion(
      id: Value(id),
      userId: Value(userId),
      metronSeriesId: Value(metronSeriesId),
      isActive: Value(isActive),
      autoAddPull: Value(autoAddPull),
      subscribedAt: Value(subscribedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SeriesSubscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesSubscription(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      metronSeriesId: serializer.fromJson<int>(json['metronSeriesId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      autoAddPull: serializer.fromJson<bool>(json['autoAddPull']),
      subscribedAt: serializer.fromJson<String>(json['subscribedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'metronSeriesId': serializer.toJson<int>(metronSeriesId),
      'isActive': serializer.toJson<bool>(isActive),
      'autoAddPull': serializer.toJson<bool>(autoAddPull),
      'subscribedAt': serializer.toJson<String>(subscribedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  SeriesSubscription copyWith({
    String? id,
    String? userId,
    int? metronSeriesId,
    bool? isActive,
    bool? autoAddPull,
    String? subscribedAt,
    String? createdAt,
    String? updatedAt,
  }) => SeriesSubscription(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    metronSeriesId: metronSeriesId ?? this.metronSeriesId,
    isActive: isActive ?? this.isActive,
    autoAddPull: autoAddPull ?? this.autoAddPull,
    subscribedAt: subscribedAt ?? this.subscribedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SeriesSubscription copyWithCompanion(SeriesSubscriptionsCompanion data) {
    return SeriesSubscription(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      metronSeriesId: data.metronSeriesId.present
          ? data.metronSeriesId.value
          : this.metronSeriesId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      autoAddPull: data.autoAddPull.present
          ? data.autoAddPull.value
          : this.autoAddPull,
      subscribedAt: data.subscribedAt.present
          ? data.subscribedAt.value
          : this.subscribedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesSubscription(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('isActive: $isActive, ')
          ..write('autoAddPull: $autoAddPull, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    metronSeriesId,
    isActive,
    autoAddPull,
    subscribedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesSubscription &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.metronSeriesId == this.metronSeriesId &&
          other.isActive == this.isActive &&
          other.autoAddPull == this.autoAddPull &&
          other.subscribedAt == this.subscribedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SeriesSubscriptionsCompanion extends UpdateCompanion<SeriesSubscription> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int> metronSeriesId;
  final Value<bool> isActive;
  final Value<bool> autoAddPull;
  final Value<String> subscribedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const SeriesSubscriptionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.metronSeriesId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoAddPull = const Value.absent(),
    this.subscribedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesSubscriptionsCompanion.insert({
    required String id,
    required String userId,
    required int metronSeriesId,
    required bool isActive,
    this.autoAddPull = const Value.absent(),
    required String subscribedAt,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       metronSeriesId = Value(metronSeriesId),
       isActive = Value(isActive),
       subscribedAt = Value(subscribedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SeriesSubscription> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? metronSeriesId,
    Expression<bool>? isActive,
    Expression<bool>? autoAddPull,
    Expression<String>? subscribedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (metronSeriesId != null) 'metron_series_id': metronSeriesId,
      if (isActive != null) 'is_active': isActive,
      if (autoAddPull != null) 'auto_add_pull': autoAddPull,
      if (subscribedAt != null) 'subscribed_at': subscribedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesSubscriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int>? metronSeriesId,
    Value<bool>? isActive,
    Value<bool>? autoAddPull,
    Value<String>? subscribedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return SeriesSubscriptionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      isActive: isActive ?? this.isActive,
      autoAddPull: autoAddPull ?? this.autoAddPull,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (metronSeriesId.present) {
      map['metron_series_id'] = Variable<int>(metronSeriesId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (autoAddPull.present) {
      map['auto_add_pull'] = Variable<bool>(autoAddPull.value);
    }
    if (subscribedAt.present) {
      map['subscribed_at'] = Variable<String>(subscribedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesSubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('isActive: $isActive, ')
          ..write('autoAddPull: $autoAddPull, ')
          ..write('subscribedAt: $subscribedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesNameMeta = const VerificationMeta(
    'seriesName',
  );
  @override
  late final GeneratedColumn<String> seriesName = GeneratedColumn<String>(
    'series_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueNumberMeta = const VerificationMeta(
    'issueNumber',
  );
  @override
  late final GeneratedColumn<String> issueNumber = GeneratedColumn<String>(
    'issue_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<String> timestamp = GeneratedColumn<String>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    seriesId,
    issueId,
    eventType,
    seriesName,
    issueNumber,
    imageUrl,
    metadata,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('series_name')) {
      context.handle(
        _seriesNameMeta,
        seriesName.isAcceptableOrUnknown(data['series_name']!, _seriesNameMeta),
      );
    }
    if (data.containsKey('issue_number')) {
      context.handle(
        _issueNumberMeta,
        issueNumber.isAcceptableOrUnknown(
          data['issue_number']!,
          _issueNumberMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      ),
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      ),
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      seriesName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_name'],
      ),
      issueNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_number'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }
}

class ActivityEvent extends DataClass implements Insertable<ActivityEvent> {
  final String id;
  final String userId;
  final int? seriesId;
  final int? issueId;
  final String eventType;
  final String? seriesName;
  final String? issueNumber;
  final String? imageUrl;
  final String? metadata;
  final String timestamp;
  const ActivityEvent({
    required this.id,
    required this.userId,
    this.seriesId,
    this.issueId,
    required this.eventType,
    this.seriesName,
    this.issueNumber,
    this.imageUrl,
    this.metadata,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    if (!nullToAbsent || issueId != null) {
      map['issue_id'] = Variable<int>(issueId);
    }
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || seriesName != null) {
      map['series_name'] = Variable<String>(seriesName);
    }
    if (!nullToAbsent || issueNumber != null) {
      map['issue_number'] = Variable<String>(issueNumber);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    map['timestamp'] = Variable<String>(timestamp);
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      issueId: issueId == null && nullToAbsent
          ? const Value.absent()
          : Value(issueId),
      eventType: Value(eventType),
      seriesName: seriesName == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesName),
      issueNumber: issueNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(issueNumber),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
      timestamp: Value(timestamp),
    );
  }

  factory ActivityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEvent(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      seriesId: serializer.fromJson<int?>(json['seriesId']),
      issueId: serializer.fromJson<int?>(json['issueId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      seriesName: serializer.fromJson<String?>(json['seriesName']),
      issueNumber: serializer.fromJson<String?>(json['issueNumber']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      metadata: serializer.fromJson<String?>(json['metadata']),
      timestamp: serializer.fromJson<String>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'seriesId': serializer.toJson<int?>(seriesId),
      'issueId': serializer.toJson<int?>(issueId),
      'eventType': serializer.toJson<String>(eventType),
      'seriesName': serializer.toJson<String?>(seriesName),
      'issueNumber': serializer.toJson<String?>(issueNumber),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'metadata': serializer.toJson<String?>(metadata),
      'timestamp': serializer.toJson<String>(timestamp),
    };
  }

  ActivityEvent copyWith({
    String? id,
    String? userId,
    Value<int?> seriesId = const Value.absent(),
    Value<int?> issueId = const Value.absent(),
    String? eventType,
    Value<String?> seriesName = const Value.absent(),
    Value<String?> issueNumber = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> metadata = const Value.absent(),
    String? timestamp,
  }) => ActivityEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    issueId: issueId.present ? issueId.value : this.issueId,
    eventType: eventType ?? this.eventType,
    seriesName: seriesName.present ? seriesName.value : this.seriesName,
    issueNumber: issueNumber.present ? issueNumber.value : this.issueNumber,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    metadata: metadata.present ? metadata.value : this.metadata,
    timestamp: timestamp ?? this.timestamp,
  );
  ActivityEvent copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      seriesName: data.seriesName.present
          ? data.seriesName.value
          : this.seriesName,
      issueNumber: data.issueNumber.present
          ? data.issueNumber.value
          : this.issueNumber,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('seriesId: $seriesId, ')
          ..write('issueId: $issueId, ')
          ..write('eventType: $eventType, ')
          ..write('seriesName: $seriesName, ')
          ..write('issueNumber: $issueNumber, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('metadata: $metadata, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    seriesId,
    issueId,
    eventType,
    seriesName,
    issueNumber,
    imageUrl,
    metadata,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.seriesId == this.seriesId &&
          other.issueId == this.issueId &&
          other.eventType == this.eventType &&
          other.seriesName == this.seriesName &&
          other.issueNumber == this.issueNumber &&
          other.imageUrl == this.imageUrl &&
          other.metadata == this.metadata &&
          other.timestamp == this.timestamp);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<String> id;
  final Value<String> userId;
  final Value<int?> seriesId;
  final Value<int?> issueId;
  final Value<String> eventType;
  final Value<String?> seriesName;
  final Value<String?> issueNumber;
  final Value<String?> imageUrl;
  final Value<String?> metadata;
  final Value<String> timestamp;
  final Value<int> rowid;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.issueId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.seriesName = const Value.absent(),
    this.issueNumber = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.metadata = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    required String id,
    required String userId,
    this.seriesId = const Value.absent(),
    this.issueId = const Value.absent(),
    required String eventType,
    this.seriesName = const Value.absent(),
    this.issueNumber = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.metadata = const Value.absent(),
    required String timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       eventType = Value(eventType),
       timestamp = Value(timestamp);
  static Insertable<ActivityEvent> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<int>? seriesId,
    Expression<int>? issueId,
    Expression<String>? eventType,
    Expression<String>? seriesName,
    Expression<String>? issueNumber,
    Expression<String>? imageUrl,
    Expression<String>? metadata,
    Expression<String>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (seriesId != null) 'series_id': seriesId,
      if (issueId != null) 'issue_id': issueId,
      if (eventType != null) 'event_type': eventType,
      if (seriesName != null) 'series_name': seriesName,
      if (issueNumber != null) 'issue_number': issueNumber,
      if (imageUrl != null) 'image_url': imageUrl,
      if (metadata != null) 'metadata': metadata,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<int?>? seriesId,
    Value<int?>? issueId,
    Value<String>? eventType,
    Value<String?>? seriesName,
    Value<String?>? issueNumber,
    Value<String?>? imageUrl,
    Value<String?>? metadata,
    Value<String>? timestamp,
    Value<int>? rowid,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      seriesId: seriesId ?? this.seriesId,
      issueId: issueId ?? this.issueId,
      eventType: eventType ?? this.eventType,
      seriesName: seriesName ?? this.seriesName,
      issueNumber: issueNumber ?? this.issueNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (seriesName.present) {
      map['series_name'] = Variable<String>(seriesName.value);
    }
    if (issueNumber.present) {
      map['issue_number'] = Variable<String>(issueNumber.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<String>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('seriesId: $seriesId, ')
          ..write('issueId: $issueId, ')
          ..write('eventType: $eventType, ')
          ..write('seriesName: $seriesName, ')
          ..write('issueNumber: $issueNumber, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('metadata: $metadata, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingListsTable extends ReadingLists
    with TableInfo<$ReadingListsTable, ReadingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOrderedMeta = const VerificationMeta(
    'isOrdered',
  );
  @override
  late final GeneratedColumn<bool> isOrdered = GeneratedColumn<bool>(
    'is_ordered',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ordered" IN (0, 1))',
    ),
  );
  static const VerificationMeta _contentTypeMeta = const VerificationMeta(
    'contentType',
  );
  @override
  late final GeneratedColumn<String> contentType = GeneratedColumn<String>(
    'content_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metronSourceIdMeta = const VerificationMeta(
    'metronSourceId',
  );
  @override
  late final GeneratedColumn<int> metronSourceId = GeneratedColumn<int>(
    'metron_source_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metronAttributionSourceMeta =
      const VerificationMeta('metronAttributionSource');
  @override
  late final GeneratedColumn<String> metronAttributionSource =
      GeneratedColumn<String>(
        'metron_attribution_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _metronAttributionUrlMeta =
      const VerificationMeta('metronAttributionUrl');
  @override
  late final GeneratedColumn<String> metronAttributionUrl =
      GeneratedColumn<String>(
        'metron_attribution_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _metronImageUrlMeta = const VerificationMeta(
    'metronImageUrl',
  );
  @override
  late final GeneratedColumn<String> metronImageUrl = GeneratedColumn<String>(
    'metron_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metronListTypeMeta = const VerificationMeta(
    'metronListType',
  );
  @override
  late final GeneratedColumn<String> metronListType = GeneratedColumn<String>(
    'metron_list_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<String> lastSyncedAt = GeneratedColumn<String>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    isOrdered,
    contentType,
    itemsJson,
    metronSourceId,
    metronAttributionSource,
    metronAttributionUrl,
    metronImageUrl,
    metronListType,
    lastSyncedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('is_ordered')) {
      context.handle(
        _isOrderedMeta,
        isOrdered.isAcceptableOrUnknown(data['is_ordered']!, _isOrderedMeta),
      );
    } else if (isInserting) {
      context.missing(_isOrderedMeta);
    }
    if (data.containsKey('content_type')) {
      context.handle(
        _contentTypeMeta,
        contentType.isAcceptableOrUnknown(
          data['content_type']!,
          _contentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTypeMeta);
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('metron_source_id')) {
      context.handle(
        _metronSourceIdMeta,
        metronSourceId.isAcceptableOrUnknown(
          data['metron_source_id']!,
          _metronSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('metron_attribution_source')) {
      context.handle(
        _metronAttributionSourceMeta,
        metronAttributionSource.isAcceptableOrUnknown(
          data['metron_attribution_source']!,
          _metronAttributionSourceMeta,
        ),
      );
    }
    if (data.containsKey('metron_attribution_url')) {
      context.handle(
        _metronAttributionUrlMeta,
        metronAttributionUrl.isAcceptableOrUnknown(
          data['metron_attribution_url']!,
          _metronAttributionUrlMeta,
        ),
      );
    }
    if (data.containsKey('metron_image_url')) {
      context.handle(
        _metronImageUrlMeta,
        metronImageUrl.isAcceptableOrUnknown(
          data['metron_image_url']!,
          _metronImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('metron_list_type')) {
      context.handle(
        _metronListTypeMeta,
        metronListType.isAcceptableOrUnknown(
          data['metron_list_type']!,
          _metronListTypeMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isOrdered: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ordered'],
      )!,
      contentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_type'],
      )!,
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      metronSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_source_id'],
      ),
      metronAttributionSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metron_attribution_source'],
      ),
      metronAttributionUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metron_attribution_url'],
      ),
      metronImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metron_image_url'],
      ),
      metronListType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metron_list_type'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_synced_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReadingListsTable createAlias(String alias) {
    return $ReadingListsTable(attachedDatabase, alias);
  }
}

class ReadingList extends DataClass implements Insertable<ReadingList> {
  final String id;
  final String title;
  final String description;
  final bool isOrdered;
  final String contentType;
  final String itemsJson;
  final int? metronSourceId;
  final String? metronAttributionSource;
  final String? metronAttributionUrl;
  final String? metronImageUrl;
  final String? metronListType;
  final String? lastSyncedAt;
  final String createdAt;
  final String updatedAt;
  const ReadingList({
    required this.id,
    required this.title,
    required this.description,
    required this.isOrdered,
    required this.contentType,
    required this.itemsJson,
    this.metronSourceId,
    this.metronAttributionSource,
    this.metronAttributionUrl,
    this.metronImageUrl,
    this.metronListType,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['is_ordered'] = Variable<bool>(isOrdered);
    map['content_type'] = Variable<String>(contentType);
    map['items_json'] = Variable<String>(itemsJson);
    if (!nullToAbsent || metronSourceId != null) {
      map['metron_source_id'] = Variable<int>(metronSourceId);
    }
    if (!nullToAbsent || metronAttributionSource != null) {
      map['metron_attribution_source'] = Variable<String>(
        metronAttributionSource,
      );
    }
    if (!nullToAbsent || metronAttributionUrl != null) {
      map['metron_attribution_url'] = Variable<String>(metronAttributionUrl);
    }
    if (!nullToAbsent || metronImageUrl != null) {
      map['metron_image_url'] = Variable<String>(metronImageUrl);
    }
    if (!nullToAbsent || metronListType != null) {
      map['metron_list_type'] = Variable<String>(metronListType);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  ReadingListsCompanion toCompanion(bool nullToAbsent) {
    return ReadingListsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      isOrdered: Value(isOrdered),
      contentType: Value(contentType),
      itemsJson: Value(itemsJson),
      metronSourceId: metronSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(metronSourceId),
      metronAttributionSource: metronAttributionSource == null && nullToAbsent
          ? const Value.absent()
          : Value(metronAttributionSource),
      metronAttributionUrl: metronAttributionUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(metronAttributionUrl),
      metronImageUrl: metronImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(metronImageUrl),
      metronListType: metronListType == null && nullToAbsent
          ? const Value.absent()
          : Value(metronListType),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingList(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      isOrdered: serializer.fromJson<bool>(json['isOrdered']),
      contentType: serializer.fromJson<String>(json['contentType']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      metronSourceId: serializer.fromJson<int?>(json['metronSourceId']),
      metronAttributionSource: serializer.fromJson<String?>(
        json['metronAttributionSource'],
      ),
      metronAttributionUrl: serializer.fromJson<String?>(
        json['metronAttributionUrl'],
      ),
      metronImageUrl: serializer.fromJson<String?>(json['metronImageUrl']),
      metronListType: serializer.fromJson<String?>(json['metronListType']),
      lastSyncedAt: serializer.fromJson<String?>(json['lastSyncedAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'isOrdered': serializer.toJson<bool>(isOrdered),
      'contentType': serializer.toJson<String>(contentType),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'metronSourceId': serializer.toJson<int?>(metronSourceId),
      'metronAttributionSource': serializer.toJson<String?>(
        metronAttributionSource,
      ),
      'metronAttributionUrl': serializer.toJson<String?>(metronAttributionUrl),
      'metronImageUrl': serializer.toJson<String?>(metronImageUrl),
      'metronListType': serializer.toJson<String?>(metronListType),
      'lastSyncedAt': serializer.toJson<String?>(lastSyncedAt),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  ReadingList copyWith({
    String? id,
    String? title,
    String? description,
    bool? isOrdered,
    String? contentType,
    String? itemsJson,
    Value<int?> metronSourceId = const Value.absent(),
    Value<String?> metronAttributionSource = const Value.absent(),
    Value<String?> metronAttributionUrl = const Value.absent(),
    Value<String?> metronImageUrl = const Value.absent(),
    Value<String?> metronListType = const Value.absent(),
    Value<String?> lastSyncedAt = const Value.absent(),
    String? createdAt,
    String? updatedAt,
  }) => ReadingList(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    isOrdered: isOrdered ?? this.isOrdered,
    contentType: contentType ?? this.contentType,
    itemsJson: itemsJson ?? this.itemsJson,
    metronSourceId: metronSourceId.present
        ? metronSourceId.value
        : this.metronSourceId,
    metronAttributionSource: metronAttributionSource.present
        ? metronAttributionSource.value
        : this.metronAttributionSource,
    metronAttributionUrl: metronAttributionUrl.present
        ? metronAttributionUrl.value
        : this.metronAttributionUrl,
    metronImageUrl: metronImageUrl.present
        ? metronImageUrl.value
        : this.metronImageUrl,
    metronListType: metronListType.present
        ? metronListType.value
        : this.metronListType,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingList copyWithCompanion(ReadingListsCompanion data) {
    return ReadingList(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      isOrdered: data.isOrdered.present ? data.isOrdered.value : this.isOrdered,
      contentType: data.contentType.present
          ? data.contentType.value
          : this.contentType,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      metronSourceId: data.metronSourceId.present
          ? data.metronSourceId.value
          : this.metronSourceId,
      metronAttributionSource: data.metronAttributionSource.present
          ? data.metronAttributionSource.value
          : this.metronAttributionSource,
      metronAttributionUrl: data.metronAttributionUrl.present
          ? data.metronAttributionUrl.value
          : this.metronAttributionUrl,
      metronImageUrl: data.metronImageUrl.present
          ? data.metronImageUrl.value
          : this.metronImageUrl,
      metronListType: data.metronListType.present
          ? data.metronListType.value
          : this.metronListType,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingList(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isOrdered: $isOrdered, ')
          ..write('contentType: $contentType, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('metronSourceId: $metronSourceId, ')
          ..write('metronAttributionSource: $metronAttributionSource, ')
          ..write('metronAttributionUrl: $metronAttributionUrl, ')
          ..write('metronImageUrl: $metronImageUrl, ')
          ..write('metronListType: $metronListType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    isOrdered,
    contentType,
    itemsJson,
    metronSourceId,
    metronAttributionSource,
    metronAttributionUrl,
    metronImageUrl,
    metronListType,
    lastSyncedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingList &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.isOrdered == this.isOrdered &&
          other.contentType == this.contentType &&
          other.itemsJson == this.itemsJson &&
          other.metronSourceId == this.metronSourceId &&
          other.metronAttributionSource == this.metronAttributionSource &&
          other.metronAttributionUrl == this.metronAttributionUrl &&
          other.metronImageUrl == this.metronImageUrl &&
          other.metronListType == this.metronListType &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReadingListsCompanion extends UpdateCompanion<ReadingList> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<bool> isOrdered;
  final Value<String> contentType;
  final Value<String> itemsJson;
  final Value<int?> metronSourceId;
  final Value<String?> metronAttributionSource;
  final Value<String?> metronAttributionUrl;
  final Value<String?> metronImageUrl;
  final Value<String?> metronListType;
  final Value<String?> lastSyncedAt;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const ReadingListsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.isOrdered = const Value.absent(),
    this.contentType = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.metronSourceId = const Value.absent(),
    this.metronAttributionSource = const Value.absent(),
    this.metronAttributionUrl = const Value.absent(),
    this.metronImageUrl = const Value.absent(),
    this.metronListType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingListsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required bool isOrdered,
    required String contentType,
    required String itemsJson,
    this.metronSourceId = const Value.absent(),
    this.metronAttributionSource = const Value.absent(),
    this.metronAttributionUrl = const Value.absent(),
    this.metronImageUrl = const Value.absent(),
    this.metronListType = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       isOrdered = Value(isOrdered),
       contentType = Value(contentType),
       itemsJson = Value(itemsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ReadingList> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<bool>? isOrdered,
    Expression<String>? contentType,
    Expression<String>? itemsJson,
    Expression<int>? metronSourceId,
    Expression<String>? metronAttributionSource,
    Expression<String>? metronAttributionUrl,
    Expression<String>? metronImageUrl,
    Expression<String>? metronListType,
    Expression<String>? lastSyncedAt,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isOrdered != null) 'is_ordered': isOrdered,
      if (contentType != null) 'content_type': contentType,
      if (itemsJson != null) 'items_json': itemsJson,
      if (metronSourceId != null) 'metron_source_id': metronSourceId,
      if (metronAttributionSource != null)
        'metron_attribution_source': metronAttributionSource,
      if (metronAttributionUrl != null)
        'metron_attribution_url': metronAttributionUrl,
      if (metronImageUrl != null) 'metron_image_url': metronImageUrl,
      if (metronListType != null) 'metron_list_type': metronListType,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingListsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<bool>? isOrdered,
    Value<String>? contentType,
    Value<String>? itemsJson,
    Value<int?>? metronSourceId,
    Value<String?>? metronAttributionSource,
    Value<String?>? metronAttributionUrl,
    Value<String?>? metronImageUrl,
    Value<String?>? metronListType,
    Value<String?>? lastSyncedAt,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReadingListsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isOrdered: isOrdered ?? this.isOrdered,
      contentType: contentType ?? this.contentType,
      itemsJson: itemsJson ?? this.itemsJson,
      metronSourceId: metronSourceId ?? this.metronSourceId,
      metronAttributionSource:
          metronAttributionSource ?? this.metronAttributionSource,
      metronAttributionUrl: metronAttributionUrl ?? this.metronAttributionUrl,
      metronImageUrl: metronImageUrl ?? this.metronImageUrl,
      metronListType: metronListType ?? this.metronListType,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isOrdered.present) {
      map['is_ordered'] = Variable<bool>(isOrdered.value);
    }
    if (contentType.present) {
      map['content_type'] = Variable<String>(contentType.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (metronSourceId.present) {
      map['metron_source_id'] = Variable<int>(metronSourceId.value);
    }
    if (metronAttributionSource.present) {
      map['metron_attribution_source'] = Variable<String>(
        metronAttributionSource.value,
      );
    }
    if (metronAttributionUrl.present) {
      map['metron_attribution_url'] = Variable<String>(
        metronAttributionUrl.value,
      );
    }
    if (metronImageUrl.present) {
      map['metron_image_url'] = Variable<String>(metronImageUrl.value);
    }
    if (metronListType.present) {
      map['metron_list_type'] = Variable<String>(metronListType.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<String>(lastSyncedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingListsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('isOrdered: $isOrdered, ')
          ..write('contentType: $contentType, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('metronSourceId: $metronSourceId, ')
          ..write('metronAttributionSource: $metronAttributionSource, ')
          ..write('metronAttributionUrl: $metronAttributionUrl, ')
          ..write('metronImageUrl: $metronImageUrl, ')
          ..write('metronListType: $metronListType, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingListItemsTable extends ReadingListItems
    with TableInfo<$ReadingListItemsTable, ReadingListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSeriesMeta = const VerificationMeta(
    'isSeries',
  );
  @override
  late final GeneratedColumn<bool> isSeries = GeneratedColumn<bool>(
    'is_series',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_series" IN (0, 1))',
    ),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    targetId,
    isSeries,
    role,
    isRead,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingListItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('is_series')) {
      context.handle(
        _isSeriesMeta,
        isSeries.isAcceptableOrUnknown(data['is_series']!, _isSeriesMeta),
      );
    } else if (isInserting) {
      context.missing(_isSeriesMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    } else if (isInserting) {
      context.missing(_isReadMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingListItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      isSeries: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_series'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ReadingListItemsTable createAlias(String alias) {
    return $ReadingListItemsTable(attachedDatabase, alias);
  }
}

class ReadingListItem extends DataClass implements Insertable<ReadingListItem> {
  final String id;
  final String listId;
  final String targetId;
  final bool isSeries;
  final String role;
  final bool isRead;
  final int sortOrder;
  const ReadingListItem({
    required this.id,
    required this.listId,
    required this.targetId,
    required this.isSeries,
    required this.role,
    required this.isRead,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['target_id'] = Variable<String>(targetId);
    map['is_series'] = Variable<bool>(isSeries);
    map['role'] = Variable<String>(role);
    map['is_read'] = Variable<bool>(isRead);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ReadingListItemsCompanion toCompanion(bool nullToAbsent) {
    return ReadingListItemsCompanion(
      id: Value(id),
      listId: Value(listId),
      targetId: Value(targetId),
      isSeries: Value(isSeries),
      role: Value(role),
      isRead: Value(isRead),
      sortOrder: Value(sortOrder),
    );
  }

  factory ReadingListItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingListItem(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      targetId: serializer.fromJson<String>(json['targetId']),
      isSeries: serializer.fromJson<bool>(json['isSeries']),
      role: serializer.fromJson<String>(json['role']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'targetId': serializer.toJson<String>(targetId),
      'isSeries': serializer.toJson<bool>(isSeries),
      'role': serializer.toJson<String>(role),
      'isRead': serializer.toJson<bool>(isRead),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ReadingListItem copyWith({
    String? id,
    String? listId,
    String? targetId,
    bool? isSeries,
    String? role,
    bool? isRead,
    int? sortOrder,
  }) => ReadingListItem(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    targetId: targetId ?? this.targetId,
    isSeries: isSeries ?? this.isSeries,
    role: role ?? this.role,
    isRead: isRead ?? this.isRead,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ReadingListItem copyWithCompanion(ReadingListItemsCompanion data) {
    return ReadingListItem(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      isSeries: data.isSeries.present ? data.isSeries.value : this.isSeries,
      role: data.role.present ? data.role.value : this.role,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingListItem(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('targetId: $targetId, ')
          ..write('isSeries: $isSeries, ')
          ..write('role: $role, ')
          ..write('isRead: $isRead, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, listId, targetId, isSeries, role, isRead, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingListItem &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.targetId == this.targetId &&
          other.isSeries == this.isSeries &&
          other.role == this.role &&
          other.isRead == this.isRead &&
          other.sortOrder == this.sortOrder);
}

class ReadingListItemsCompanion extends UpdateCompanion<ReadingListItem> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> targetId;
  final Value<bool> isSeries;
  final Value<String> role;
  final Value<bool> isRead;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const ReadingListItemsCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.isSeries = const Value.absent(),
    this.role = const Value.absent(),
    this.isRead = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingListItemsCompanion.insert({
    required String id,
    required String listId,
    required String targetId,
    required bool isSeries,
    required String role,
    required bool isRead,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       targetId = Value(targetId),
       isSeries = Value(isSeries),
       role = Value(role),
       isRead = Value(isRead),
       sortOrder = Value(sortOrder);
  static Insertable<ReadingListItem> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? targetId,
    Expression<bool>? isSeries,
    Expression<String>? role,
    Expression<bool>? isRead,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (targetId != null) 'target_id': targetId,
      if (isSeries != null) 'is_series': isSeries,
      if (role != null) 'role': role,
      if (isRead != null) 'is_read': isRead,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingListItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? targetId,
    Value<bool>? isSeries,
    Value<String>? role,
    Value<bool>? isRead,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return ReadingListItemsCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      targetId: targetId ?? this.targetId,
      isSeries: isSeries ?? this.isSeries,
      role: role ?? this.role,
      isRead: isRead ?? this.isRead,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (isSeries.present) {
      map['is_series'] = Variable<bool>(isSeries.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingListItemsCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('targetId: $targetId, ')
          ..write('isSeries: $isSeries, ')
          ..write('role: $role, ')
          ..write('isRead: $isRead, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteSeriesTable extends FavoriteSeries
    with TableInfo<$FavoriteSeriesTable, FavoriteSery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metronSeriesIdMeta = const VerificationMeta(
    'metronSeriesId',
  );
  @override
  late final GeneratedColumn<int> metronSeriesId = GeneratedColumn<int>(
    'metron_series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [metronSeriesId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteSery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('metron_series_id')) {
      context.handle(
        _metronSeriesIdMeta,
        metronSeriesId.isAcceptableOrUnknown(
          data['metron_series_id']!,
          _metronSeriesIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metronSeriesId};
  @override
  FavoriteSery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteSery(
      metronSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_series_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteSeriesTable createAlias(String alias) {
    return $FavoriteSeriesTable(attachedDatabase, alias);
  }
}

class FavoriteSery extends DataClass implements Insertable<FavoriteSery> {
  final int metronSeriesId;
  final String createdAt;
  final String updatedAt;
  const FavoriteSery({
    required this.metronSeriesId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['metron_series_id'] = Variable<int>(metronSeriesId);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FavoriteSeriesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteSeriesCompanion(
      metronSeriesId: Value(metronSeriesId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteSery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteSery(
      metronSeriesId: serializer.fromJson<int>(json['metronSeriesId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metronSeriesId': serializer.toJson<int>(metronSeriesId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FavoriteSery copyWith({
    int? metronSeriesId,
    String? createdAt,
    String? updatedAt,
  }) => FavoriteSery(
    metronSeriesId: metronSeriesId ?? this.metronSeriesId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteSery copyWithCompanion(FavoriteSeriesCompanion data) {
    return FavoriteSery(
      metronSeriesId: data.metronSeriesId.present
          ? data.metronSeriesId.value
          : this.metronSeriesId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteSery(')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metronSeriesId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteSery &&
          other.metronSeriesId == this.metronSeriesId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteSeriesCompanion extends UpdateCompanion<FavoriteSery> {
  final Value<int> metronSeriesId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FavoriteSeriesCompanion({
    this.metronSeriesId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FavoriteSeriesCompanion.insert({
    this.metronSeriesId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteSery> custom({
    Expression<int>? metronSeriesId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (metronSeriesId != null) 'metron_series_id': metronSeriesId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FavoriteSeriesCompanion copyWith({
    Value<int>? metronSeriesId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FavoriteSeriesCompanion(
      metronSeriesId: metronSeriesId ?? this.metronSeriesId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metronSeriesId.present) {
      map['metron_series_id'] = Variable<int>(metronSeriesId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteSeriesCompanion(')
          ..write('metronSeriesId: $metronSeriesId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoriteIssuesTable extends FavoriteIssues
    with TableInfo<$FavoriteIssuesTable, FavoriteIssue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteIssuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metronIssueIdMeta = const VerificationMeta(
    'metronIssueId',
  );
  @override
  late final GeneratedColumn<int> metronIssueId = GeneratedColumn<int>(
    'metron_issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [metronIssueId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_issues';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteIssue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('metron_issue_id')) {
      context.handle(
        _metronIssueIdMeta,
        metronIssueId.isAcceptableOrUnknown(
          data['metron_issue_id']!,
          _metronIssueIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metronIssueId};
  @override
  FavoriteIssue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteIssue(
      metronIssueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_issue_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteIssuesTable createAlias(String alias) {
    return $FavoriteIssuesTable(attachedDatabase, alias);
  }
}

class FavoriteIssue extends DataClass implements Insertable<FavoriteIssue> {
  final int metronIssueId;
  final String createdAt;
  final String updatedAt;
  const FavoriteIssue({
    required this.metronIssueId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['metron_issue_id'] = Variable<int>(metronIssueId);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FavoriteIssuesCompanion toCompanion(bool nullToAbsent) {
    return FavoriteIssuesCompanion(
      metronIssueId: Value(metronIssueId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteIssue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteIssue(
      metronIssueId: serializer.fromJson<int>(json['metronIssueId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metronIssueId': serializer.toJson<int>(metronIssueId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FavoriteIssue copyWith({
    int? metronIssueId,
    String? createdAt,
    String? updatedAt,
  }) => FavoriteIssue(
    metronIssueId: metronIssueId ?? this.metronIssueId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteIssue copyWithCompanion(FavoriteIssuesCompanion data) {
    return FavoriteIssue(
      metronIssueId: data.metronIssueId.present
          ? data.metronIssueId.value
          : this.metronIssueId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteIssue(')
          ..write('metronIssueId: $metronIssueId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metronIssueId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteIssue &&
          other.metronIssueId == this.metronIssueId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteIssuesCompanion extends UpdateCompanion<FavoriteIssue> {
  final Value<int> metronIssueId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FavoriteIssuesCompanion({
    this.metronIssueId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FavoriteIssuesCompanion.insert({
    this.metronIssueId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteIssue> custom({
    Expression<int>? metronIssueId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (metronIssueId != null) 'metron_issue_id': metronIssueId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FavoriteIssuesCompanion copyWith({
    Value<int>? metronIssueId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FavoriteIssuesCompanion(
      metronIssueId: metronIssueId ?? this.metronIssueId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metronIssueId.present) {
      map['metron_issue_id'] = Variable<int>(metronIssueId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteIssuesCompanion(')
          ..write('metronIssueId: $metronIssueId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoriteCharactersTable extends FavoriteCharacters
    with TableInfo<$FavoriteCharactersTable, FavoriteCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteCharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metronCharacterIdMeta = const VerificationMeta(
    'metronCharacterId',
  );
  @override
  late final GeneratedColumn<int> metronCharacterId = GeneratedColumn<int>(
    'metron_character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    metronCharacterId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('metron_character_id')) {
      context.handle(
        _metronCharacterIdMeta,
        metronCharacterId.isAcceptableOrUnknown(
          data['metron_character_id']!,
          _metronCharacterIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metronCharacterId};
  @override
  FavoriteCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteCharacter(
      metronCharacterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_character_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteCharactersTable createAlias(String alias) {
    return $FavoriteCharactersTable(attachedDatabase, alias);
  }
}

class FavoriteCharacter extends DataClass
    implements Insertable<FavoriteCharacter> {
  final int metronCharacterId;
  final String createdAt;
  final String updatedAt;
  const FavoriteCharacter({
    required this.metronCharacterId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['metron_character_id'] = Variable<int>(metronCharacterId);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FavoriteCharactersCompanion toCompanion(bool nullToAbsent) {
    return FavoriteCharactersCompanion(
      metronCharacterId: Value(metronCharacterId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteCharacter(
      metronCharacterId: serializer.fromJson<int>(json['metronCharacterId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metronCharacterId': serializer.toJson<int>(metronCharacterId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FavoriteCharacter copyWith({
    int? metronCharacterId,
    String? createdAt,
    String? updatedAt,
  }) => FavoriteCharacter(
    metronCharacterId: metronCharacterId ?? this.metronCharacterId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteCharacter copyWithCompanion(FavoriteCharactersCompanion data) {
    return FavoriteCharacter(
      metronCharacterId: data.metronCharacterId.present
          ? data.metronCharacterId.value
          : this.metronCharacterId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteCharacter(')
          ..write('metronCharacterId: $metronCharacterId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metronCharacterId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteCharacter &&
          other.metronCharacterId == this.metronCharacterId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteCharactersCompanion extends UpdateCompanion<FavoriteCharacter> {
  final Value<int> metronCharacterId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FavoriteCharactersCompanion({
    this.metronCharacterId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FavoriteCharactersCompanion.insert({
    this.metronCharacterId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteCharacter> custom({
    Expression<int>? metronCharacterId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (metronCharacterId != null) 'metron_character_id': metronCharacterId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FavoriteCharactersCompanion copyWith({
    Value<int>? metronCharacterId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FavoriteCharactersCompanion(
      metronCharacterId: metronCharacterId ?? this.metronCharacterId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metronCharacterId.present) {
      map['metron_character_id'] = Variable<int>(metronCharacterId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteCharactersCompanion(')
          ..write('metronCharacterId: $metronCharacterId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoriteCreatorsTable extends FavoriteCreators
    with TableInfo<$FavoriteCreatorsTable, FavoriteCreator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteCreatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metronCreatorIdMeta = const VerificationMeta(
    'metronCreatorId',
  );
  @override
  late final GeneratedColumn<int> metronCreatorId = GeneratedColumn<int>(
    'metron_creator_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [metronCreatorId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_creators';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteCreator> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('metron_creator_id')) {
      context.handle(
        _metronCreatorIdMeta,
        metronCreatorId.isAcceptableOrUnknown(
          data['metron_creator_id']!,
          _metronCreatorIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metronCreatorId};
  @override
  FavoriteCreator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteCreator(
      metronCreatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}metron_creator_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteCreatorsTable createAlias(String alias) {
    return $FavoriteCreatorsTable(attachedDatabase, alias);
  }
}

class FavoriteCreator extends DataClass implements Insertable<FavoriteCreator> {
  final int metronCreatorId;
  final String createdAt;
  final String updatedAt;
  const FavoriteCreator({
    required this.metronCreatorId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['metron_creator_id'] = Variable<int>(metronCreatorId);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FavoriteCreatorsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteCreatorsCompanion(
      metronCreatorId: Value(metronCreatorId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteCreator.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteCreator(
      metronCreatorId: serializer.fromJson<int>(json['metronCreatorId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metronCreatorId': serializer.toJson<int>(metronCreatorId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FavoriteCreator copyWith({
    int? metronCreatorId,
    String? createdAt,
    String? updatedAt,
  }) => FavoriteCreator(
    metronCreatorId: metronCreatorId ?? this.metronCreatorId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteCreator copyWithCompanion(FavoriteCreatorsCompanion data) {
    return FavoriteCreator(
      metronCreatorId: data.metronCreatorId.present
          ? data.metronCreatorId.value
          : this.metronCreatorId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteCreator(')
          ..write('metronCreatorId: $metronCreatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metronCreatorId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteCreator &&
          other.metronCreatorId == this.metronCreatorId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteCreatorsCompanion extends UpdateCompanion<FavoriteCreator> {
  final Value<int> metronCreatorId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const FavoriteCreatorsCompanion({
    this.metronCreatorId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FavoriteCreatorsCompanion.insert({
    this.metronCreatorId = const Value.absent(),
    required String createdAt,
    required String updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteCreator> custom({
    Expression<int>? metronCreatorId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (metronCreatorId != null) 'metron_creator_id': metronCreatorId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FavoriteCreatorsCompanion copyWith({
    Value<int>? metronCreatorId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return FavoriteCreatorsCompanion(
      metronCreatorId: metronCreatorId ?? this.metronCreatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metronCreatorId.present) {
      map['metron_creator_id'] = Variable<int>(metronCreatorId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteCreatorsCompanion(')
          ..write('metronCreatorId: $metronCreatorId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FavoriteReadingListsTable extends FavoriteReadingLists
    with TableInfo<$FavoriteReadingListsTable, FavoriteReadingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteReadingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingListIdMeta = const VerificationMeta(
    'readingListId',
  );
  @override
  late final GeneratedColumn<String> readingListId = GeneratedColumn<String>(
    'reading_list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [readingListId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_reading_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteReadingList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('reading_list_id')) {
      context.handle(
        _readingListIdMeta,
        readingListId.isAcceptableOrUnknown(
          data['reading_list_id']!,
          _readingListIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingListIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingListId};
  @override
  FavoriteReadingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteReadingList(
      readingListId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_list_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FavoriteReadingListsTable createAlias(String alias) {
    return $FavoriteReadingListsTable(attachedDatabase, alias);
  }
}

class FavoriteReadingList extends DataClass
    implements Insertable<FavoriteReadingList> {
  final String readingListId;
  final String createdAt;
  final String updatedAt;
  const FavoriteReadingList({
    required this.readingListId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['reading_list_id'] = Variable<String>(readingListId);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  FavoriteReadingListsCompanion toCompanion(bool nullToAbsent) {
    return FavoriteReadingListsCompanion(
      readingListId: Value(readingListId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FavoriteReadingList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteReadingList(
      readingListId: serializer.fromJson<String>(json['readingListId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingListId': serializer.toJson<String>(readingListId),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  FavoriteReadingList copyWith({
    String? readingListId,
    String? createdAt,
    String? updatedAt,
  }) => FavoriteReadingList(
    readingListId: readingListId ?? this.readingListId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FavoriteReadingList copyWithCompanion(FavoriteReadingListsCompanion data) {
    return FavoriteReadingList(
      readingListId: data.readingListId.present
          ? data.readingListId.value
          : this.readingListId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteReadingList(')
          ..write('readingListId: $readingListId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(readingListId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteReadingList &&
          other.readingListId == this.readingListId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FavoriteReadingListsCompanion
    extends UpdateCompanion<FavoriteReadingList> {
  final Value<String> readingListId;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const FavoriteReadingListsCompanion({
    this.readingListId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteReadingListsCompanion.insert({
    required String readingListId,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  }) : readingListId = Value(readingListId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FavoriteReadingList> custom({
    Expression<String>? readingListId,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (readingListId != null) 'reading_list_id': readingListId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteReadingListsCompanion copyWith({
    Value<String>? readingListId,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<int>? rowid,
  }) {
    return FavoriteReadingListsCompanion(
      readingListId: readingListId ?? this.readingListId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingListId.present) {
      map['reading_list_id'] = Variable<String>(readingListId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteReadingListsCompanion(')
          ..write('readingListId: $readingListId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetronIssuesTable extends MetronIssues
    with TableInfo<$MetronIssuesTable, MetronIssue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronIssuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverDateMeta = const VerificationMeta(
    'coverDate',
  );
  @override
  late final GeneratedColumn<String> coverDate = GeneratedColumn<String>(
    'cover_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storeDateMeta = const VerificationMeta(
    'storeDate',
  );
  @override
  late final GeneratedColumn<String> storeDate = GeneratedColumn<String>(
    'store_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _focDateMeta = const VerificationMeta(
    'focDate',
  );
  @override
  late final GeneratedColumn<String> focDate = GeneratedColumn<String>(
    'foc_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<String> price = GeneratedColumn<String>(
    'price',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _upcMeta = const VerificationMeta('upc');
  @override
  late final GeneratedColumn<String> upc = GeneratedColumn<String>(
    'upc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverHashMeta = const VerificationMeta(
    'coverHash',
  );
  @override
  late final GeneratedColumn<String> coverHash = GeneratedColumn<String>(
    'cover_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherIdMeta = const VerificationMeta(
    'publisherId',
  );
  @override
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
    'publisher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imprintIdMeta = const VerificationMeta(
    'imprintId',
  );
  @override
  late final GeneratedColumn<int> imprintId = GeneratedColumn<int>(
    'imprint_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    seriesId,
    coverDate,
    storeDate,
    focDate,
    imageUrl,
    description,
    pageCount,
    price,
    sku,
    upc,
    isbn,
    coverHash,
    publisherId,
    imprintId,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_issues';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronIssue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    }
    if (data.containsKey('cover_date')) {
      context.handle(
        _coverDateMeta,
        coverDate.isAcceptableOrUnknown(data['cover_date']!, _coverDateMeta),
      );
    }
    if (data.containsKey('store_date')) {
      context.handle(
        _storeDateMeta,
        storeDate.isAcceptableOrUnknown(data['store_date']!, _storeDateMeta),
      );
    }
    if (data.containsKey('foc_date')) {
      context.handle(
        _focDateMeta,
        focDate.isAcceptableOrUnknown(data['foc_date']!, _focDateMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('upc')) {
      context.handle(
        _upcMeta,
        upc.isAcceptableOrUnknown(data['upc']!, _upcMeta),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('cover_hash')) {
      context.handle(
        _coverHashMeta,
        coverHash.isAcceptableOrUnknown(data['cover_hash']!, _coverHashMeta),
      );
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
        _publisherIdMeta,
        publisherId.isAcceptableOrUnknown(
          data['publisher_id']!,
          _publisherIdMeta,
        ),
      );
    }
    if (data.containsKey('imprint_id')) {
      context.handle(
        _imprintIdMeta,
        imprintId.isAcceptableOrUnknown(data['imprint_id']!, _imprintIdMeta),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronIssue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronIssue(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      ),
      coverDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_date'],
      ),
      storeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}store_date'],
      ),
      focDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foc_date'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}price'],
      ),
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      upc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upc'],
      ),
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      ),
      coverHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_hash'],
      ),
      publisherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publisher_id'],
      ),
      imprintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imprint_id'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronIssuesTable createAlias(String alias) {
    return $MetronIssuesTable(attachedDatabase, alias);
  }
}

class MetronIssue extends DataClass implements Insertable<MetronIssue> {
  final int id;
  final String number;
  final int? seriesId;
  final String? coverDate;
  final String? storeDate;
  final String? focDate;
  final String? imageUrl;
  final String? description;
  final int? pageCount;
  final String? price;
  final String? sku;
  final String? upc;
  final String? isbn;
  final String? coverHash;
  final int? publisherId;
  final int? imprintId;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronIssue({
    required this.id,
    required this.number,
    this.seriesId,
    this.coverDate,
    this.storeDate,
    this.focDate,
    this.imageUrl,
    this.description,
    this.pageCount,
    this.price,
    this.sku,
    this.upc,
    this.isbn,
    this.coverHash,
    this.publisherId,
    this.imprintId,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<String>(number);
    if (!nullToAbsent || seriesId != null) {
      map['series_id'] = Variable<int>(seriesId);
    }
    if (!nullToAbsent || coverDate != null) {
      map['cover_date'] = Variable<String>(coverDate);
    }
    if (!nullToAbsent || storeDate != null) {
      map['store_date'] = Variable<String>(storeDate);
    }
    if (!nullToAbsent || focDate != null) {
      map['foc_date'] = Variable<String>(focDate);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || price != null) {
      map['price'] = Variable<String>(price);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || upc != null) {
      map['upc'] = Variable<String>(upc);
    }
    if (!nullToAbsent || isbn != null) {
      map['isbn'] = Variable<String>(isbn);
    }
    if (!nullToAbsent || coverHash != null) {
      map['cover_hash'] = Variable<String>(coverHash);
    }
    if (!nullToAbsent || publisherId != null) {
      map['publisher_id'] = Variable<int>(publisherId);
    }
    if (!nullToAbsent || imprintId != null) {
      map['imprint_id'] = Variable<int>(imprintId);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronIssuesCompanion toCompanion(bool nullToAbsent) {
    return MetronIssuesCompanion(
      id: Value(id),
      number: Value(number),
      seriesId: seriesId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesId),
      coverDate: coverDate == null && nullToAbsent
          ? const Value.absent()
          : Value(coverDate),
      storeDate: storeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(storeDate),
      focDate: focDate == null && nullToAbsent
          ? const Value.absent()
          : Value(focDate),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      price: price == null && nullToAbsent
          ? const Value.absent()
          : Value(price),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      upc: upc == null && nullToAbsent ? const Value.absent() : Value(upc),
      isbn: isbn == null && nullToAbsent ? const Value.absent() : Value(isbn),
      coverHash: coverHash == null && nullToAbsent
          ? const Value.absent()
          : Value(coverHash),
      publisherId: publisherId == null && nullToAbsent
          ? const Value.absent()
          : Value(publisherId),
      imprintId: imprintId == null && nullToAbsent
          ? const Value.absent()
          : Value(imprintId),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronIssue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronIssue(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<String>(json['number']),
      seriesId: serializer.fromJson<int?>(json['seriesId']),
      coverDate: serializer.fromJson<String?>(json['coverDate']),
      storeDate: serializer.fromJson<String?>(json['storeDate']),
      focDate: serializer.fromJson<String?>(json['focDate']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      price: serializer.fromJson<String?>(json['price']),
      sku: serializer.fromJson<String?>(json['sku']),
      upc: serializer.fromJson<String?>(json['upc']),
      isbn: serializer.fromJson<String?>(json['isbn']),
      coverHash: serializer.fromJson<String?>(json['coverHash']),
      publisherId: serializer.fromJson<int?>(json['publisherId']),
      imprintId: serializer.fromJson<int?>(json['imprintId']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<String>(number),
      'seriesId': serializer.toJson<int?>(seriesId),
      'coverDate': serializer.toJson<String?>(coverDate),
      'storeDate': serializer.toJson<String?>(storeDate),
      'focDate': serializer.toJson<String?>(focDate),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'pageCount': serializer.toJson<int?>(pageCount),
      'price': serializer.toJson<String?>(price),
      'sku': serializer.toJson<String?>(sku),
      'upc': serializer.toJson<String?>(upc),
      'isbn': serializer.toJson<String?>(isbn),
      'coverHash': serializer.toJson<String?>(coverHash),
      'publisherId': serializer.toJson<int?>(publisherId),
      'imprintId': serializer.toJson<int?>(imprintId),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronIssue copyWith({
    int? id,
    String? number,
    Value<int?> seriesId = const Value.absent(),
    Value<String?> coverDate = const Value.absent(),
    Value<String?> storeDate = const Value.absent(),
    Value<String?> focDate = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> price = const Value.absent(),
    Value<String?> sku = const Value.absent(),
    Value<String?> upc = const Value.absent(),
    Value<String?> isbn = const Value.absent(),
    Value<String?> coverHash = const Value.absent(),
    Value<int?> publisherId = const Value.absent(),
    Value<int?> imprintId = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronIssue(
    id: id ?? this.id,
    number: number ?? this.number,
    seriesId: seriesId.present ? seriesId.value : this.seriesId,
    coverDate: coverDate.present ? coverDate.value : this.coverDate,
    storeDate: storeDate.present ? storeDate.value : this.storeDate,
    focDate: focDate.present ? focDate.value : this.focDate,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    price: price.present ? price.value : this.price,
    sku: sku.present ? sku.value : this.sku,
    upc: upc.present ? upc.value : this.upc,
    isbn: isbn.present ? isbn.value : this.isbn,
    coverHash: coverHash.present ? coverHash.value : this.coverHash,
    publisherId: publisherId.present ? publisherId.value : this.publisherId,
    imprintId: imprintId.present ? imprintId.value : this.imprintId,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronIssue copyWithCompanion(MetronIssuesCompanion data) {
    return MetronIssue(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      coverDate: data.coverDate.present ? data.coverDate.value : this.coverDate,
      storeDate: data.storeDate.present ? data.storeDate.value : this.storeDate,
      focDate: data.focDate.present ? data.focDate.value : this.focDate,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      price: data.price.present ? data.price.value : this.price,
      sku: data.sku.present ? data.sku.value : this.sku,
      upc: data.upc.present ? data.upc.value : this.upc,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      coverHash: data.coverHash.present ? data.coverHash.value : this.coverHash,
      publisherId: data.publisherId.present
          ? data.publisherId.value
          : this.publisherId,
      imprintId: data.imprintId.present ? data.imprintId.value : this.imprintId,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronIssue(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('seriesId: $seriesId, ')
          ..write('coverDate: $coverDate, ')
          ..write('storeDate: $storeDate, ')
          ..write('focDate: $focDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('pageCount: $pageCount, ')
          ..write('price: $price, ')
          ..write('sku: $sku, ')
          ..write('upc: $upc, ')
          ..write('isbn: $isbn, ')
          ..write('coverHash: $coverHash, ')
          ..write('publisherId: $publisherId, ')
          ..write('imprintId: $imprintId, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    number,
    seriesId,
    coverDate,
    storeDate,
    focDate,
    imageUrl,
    description,
    pageCount,
    price,
    sku,
    upc,
    isbn,
    coverHash,
    publisherId,
    imprintId,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronIssue &&
          other.id == this.id &&
          other.number == this.number &&
          other.seriesId == this.seriesId &&
          other.coverDate == this.coverDate &&
          other.storeDate == this.storeDate &&
          other.focDate == this.focDate &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.pageCount == this.pageCount &&
          other.price == this.price &&
          other.sku == this.sku &&
          other.upc == this.upc &&
          other.isbn == this.isbn &&
          other.coverHash == this.coverHash &&
          other.publisherId == this.publisherId &&
          other.imprintId == this.imprintId &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronIssuesCompanion extends UpdateCompanion<MetronIssue> {
  final Value<int> id;
  final Value<String> number;
  final Value<int?> seriesId;
  final Value<String?> coverDate;
  final Value<String?> storeDate;
  final Value<String?> focDate;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<int?> pageCount;
  final Value<String?> price;
  final Value<String?> sku;
  final Value<String?> upc;
  final Value<String?> isbn;
  final Value<String?> coverHash;
  final Value<int?> publisherId;
  final Value<int?> imprintId;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronIssuesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.coverDate = const Value.absent(),
    this.storeDate = const Value.absent(),
    this.focDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.price = const Value.absent(),
    this.sku = const Value.absent(),
    this.upc = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverHash = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronIssuesCompanion.insert({
    this.id = const Value.absent(),
    required String number,
    this.seriesId = const Value.absent(),
    this.coverDate = const Value.absent(),
    this.storeDate = const Value.absent(),
    this.focDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.price = const Value.absent(),
    this.sku = const Value.absent(),
    this.upc = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverHash = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : number = Value(number);
  static Insertable<MetronIssue> custom({
    Expression<int>? id,
    Expression<String>? number,
    Expression<int>? seriesId,
    Expression<String>? coverDate,
    Expression<String>? storeDate,
    Expression<String>? focDate,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<int>? pageCount,
    Expression<String>? price,
    Expression<String>? sku,
    Expression<String>? upc,
    Expression<String>? isbn,
    Expression<String>? coverHash,
    Expression<int>? publisherId,
    Expression<int>? imprintId,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (seriesId != null) 'series_id': seriesId,
      if (coverDate != null) 'cover_date': coverDate,
      if (storeDate != null) 'store_date': storeDate,
      if (focDate != null) 'foc_date': focDate,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (pageCount != null) 'page_count': pageCount,
      if (price != null) 'price': price,
      if (sku != null) 'sku': sku,
      if (upc != null) 'upc': upc,
      if (isbn != null) 'isbn': isbn,
      if (coverHash != null) 'cover_hash': coverHash,
      if (publisherId != null) 'publisher_id': publisherId,
      if (imprintId != null) 'imprint_id': imprintId,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronIssuesCompanion copyWith({
    Value<int>? id,
    Value<String>? number,
    Value<int?>? seriesId,
    Value<String?>? coverDate,
    Value<String?>? storeDate,
    Value<String?>? focDate,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<int?>? pageCount,
    Value<String?>? price,
    Value<String?>? sku,
    Value<String?>? upc,
    Value<String?>? isbn,
    Value<String?>? coverHash,
    Value<int?>? publisherId,
    Value<int?>? imprintId,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronIssuesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      seriesId: seriesId ?? this.seriesId,
      coverDate: coverDate ?? this.coverDate,
      storeDate: storeDate ?? this.storeDate,
      focDate: focDate ?? this.focDate,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      pageCount: pageCount ?? this.pageCount,
      price: price ?? this.price,
      sku: sku ?? this.sku,
      upc: upc ?? this.upc,
      isbn: isbn ?? this.isbn,
      coverHash: coverHash ?? this.coverHash,
      publisherId: publisherId ?? this.publisherId,
      imprintId: imprintId ?? this.imprintId,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (coverDate.present) {
      map['cover_date'] = Variable<String>(coverDate.value);
    }
    if (storeDate.present) {
      map['store_date'] = Variable<String>(storeDate.value);
    }
    if (focDate.present) {
      map['foc_date'] = Variable<String>(focDate.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (price.present) {
      map['price'] = Variable<String>(price.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (upc.present) {
      map['upc'] = Variable<String>(upc.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (coverHash.present) {
      map['cover_hash'] = Variable<String>(coverHash.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (imprintId.present) {
      map['imprint_id'] = Variable<int>(imprintId.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronIssuesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('seriesId: $seriesId, ')
          ..write('coverDate: $coverDate, ')
          ..write('storeDate: $storeDate, ')
          ..write('focDate: $focDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('pageCount: $pageCount, ')
          ..write('price: $price, ')
          ..write('sku: $sku, ')
          ..write('upc: $upc, ')
          ..write('isbn: $isbn, ')
          ..write('coverHash: $coverHash, ')
          ..write('publisherId: $publisherId, ')
          ..write('imprintId: $imprintId, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronSeriesTable extends MetronSeries
    with TableInfo<$MetronSeriesTable, MetronSery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortNameMeta = const VerificationMeta(
    'sortName',
  );
  @override
  late final GeneratedColumn<String> sortName = GeneratedColumn<String>(
    'sort_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<int> volume = GeneratedColumn<int>(
    'volume',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesTypeIdMeta = const VerificationMeta(
    'seriesTypeId',
  );
  @override
  late final GeneratedColumn<int> seriesTypeId = GeneratedColumn<int>(
    'series_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherIdMeta = const VerificationMeta(
    'publisherId',
  );
  @override
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
    'publisher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imprintIdMeta = const VerificationMeta(
    'imprintId',
  );
  @override
  late final GeneratedColumn<int> imprintId = GeneratedColumn<int>(
    'imprint_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearBeganMeta = const VerificationMeta(
    'yearBegan',
  );
  @override
  late final GeneratedColumn<int> yearBegan = GeneratedColumn<int>(
    'year_began',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearEndMeta = const VerificationMeta(
    'yearEnd',
  );
  @override
  late final GeneratedColumn<int> yearEnd = GeneratedColumn<int>(
    'year_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueCountMeta = const VerificationMeta(
    'issueCount',
  );
  @override
  late final GeneratedColumn<int> issueCount = GeneratedColumn<int>(
    'issue_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _computedCoverUrlMeta = const VerificationMeta(
    'computedCoverUrl',
  );
  @override
  late final GeneratedColumn<String> computedCoverUrl = GeneratedColumn<String>(
    'computed_cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sortName,
    volume,
    seriesTypeId,
    status,
    publisherId,
    imprintId,
    yearBegan,
    yearEnd,
    description,
    issueCount,
    computedCoverUrl,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronSery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_name')) {
      context.handle(
        _sortNameMeta,
        sortName.isAcceptableOrUnknown(data['sort_name']!, _sortNameMeta),
      );
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    }
    if (data.containsKey('series_type_id')) {
      context.handle(
        _seriesTypeIdMeta,
        seriesTypeId.isAcceptableOrUnknown(
          data['series_type_id']!,
          _seriesTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
        _publisherIdMeta,
        publisherId.isAcceptableOrUnknown(
          data['publisher_id']!,
          _publisherIdMeta,
        ),
      );
    }
    if (data.containsKey('imprint_id')) {
      context.handle(
        _imprintIdMeta,
        imprintId.isAcceptableOrUnknown(data['imprint_id']!, _imprintIdMeta),
      );
    }
    if (data.containsKey('year_began')) {
      context.handle(
        _yearBeganMeta,
        yearBegan.isAcceptableOrUnknown(data['year_began']!, _yearBeganMeta),
      );
    }
    if (data.containsKey('year_end')) {
      context.handle(
        _yearEndMeta,
        yearEnd.isAcceptableOrUnknown(data['year_end']!, _yearEndMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('issue_count')) {
      context.handle(
        _issueCountMeta,
        issueCount.isAcceptableOrUnknown(data['issue_count']!, _issueCountMeta),
      );
    }
    if (data.containsKey('computed_cover_url')) {
      context.handle(
        _computedCoverUrlMeta,
        computedCoverUrl.isAcceptableOrUnknown(
          data['computed_cover_url']!,
          _computedCoverUrlMeta,
        ),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronSery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronSery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sort_name'],
      ),
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}volume'],
      ),
      seriesTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_type_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      ),
      publisherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publisher_id'],
      ),
      imprintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imprint_id'],
      ),
      yearBegan: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_began'],
      ),
      yearEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_end'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      issueCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_count'],
      ),
      computedCoverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}computed_cover_url'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronSeriesTable createAlias(String alias) {
    return $MetronSeriesTable(attachedDatabase, alias);
  }
}

class MetronSery extends DataClass implements Insertable<MetronSery> {
  final int id;
  final String name;
  final String? sortName;
  final int? volume;
  final int? seriesTypeId;
  final String? status;
  final int? publisherId;
  final int? imprintId;
  final int? yearBegan;
  final int? yearEnd;
  final String? description;
  final int? issueCount;
  final String? computedCoverUrl;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronSery({
    required this.id,
    required this.name,
    this.sortName,
    this.volume,
    this.seriesTypeId,
    this.status,
    this.publisherId,
    this.imprintId,
    this.yearBegan,
    this.yearEnd,
    this.description,
    this.issueCount,
    this.computedCoverUrl,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sortName != null) {
      map['sort_name'] = Variable<String>(sortName);
    }
    if (!nullToAbsent || volume != null) {
      map['volume'] = Variable<int>(volume);
    }
    if (!nullToAbsent || seriesTypeId != null) {
      map['series_type_id'] = Variable<int>(seriesTypeId);
    }
    if (!nullToAbsent || status != null) {
      map['status'] = Variable<String>(status);
    }
    if (!nullToAbsent || publisherId != null) {
      map['publisher_id'] = Variable<int>(publisherId);
    }
    if (!nullToAbsent || imprintId != null) {
      map['imprint_id'] = Variable<int>(imprintId);
    }
    if (!nullToAbsent || yearBegan != null) {
      map['year_began'] = Variable<int>(yearBegan);
    }
    if (!nullToAbsent || yearEnd != null) {
      map['year_end'] = Variable<int>(yearEnd);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || issueCount != null) {
      map['issue_count'] = Variable<int>(issueCount);
    }
    if (!nullToAbsent || computedCoverUrl != null) {
      map['computed_cover_url'] = Variable<String>(computedCoverUrl);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronSeriesCompanion toCompanion(bool nullToAbsent) {
    return MetronSeriesCompanion(
      id: Value(id),
      name: Value(name),
      sortName: sortName == null && nullToAbsent
          ? const Value.absent()
          : Value(sortName),
      volume: volume == null && nullToAbsent
          ? const Value.absent()
          : Value(volume),
      seriesTypeId: seriesTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesTypeId),
      status: status == null && nullToAbsent
          ? const Value.absent()
          : Value(status),
      publisherId: publisherId == null && nullToAbsent
          ? const Value.absent()
          : Value(publisherId),
      imprintId: imprintId == null && nullToAbsent
          ? const Value.absent()
          : Value(imprintId),
      yearBegan: yearBegan == null && nullToAbsent
          ? const Value.absent()
          : Value(yearBegan),
      yearEnd: yearEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(yearEnd),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      issueCount: issueCount == null && nullToAbsent
          ? const Value.absent()
          : Value(issueCount),
      computedCoverUrl: computedCoverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(computedCoverUrl),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronSery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronSery(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortName: serializer.fromJson<String?>(json['sortName']),
      volume: serializer.fromJson<int?>(json['volume']),
      seriesTypeId: serializer.fromJson<int?>(json['seriesTypeId']),
      status: serializer.fromJson<String?>(json['status']),
      publisherId: serializer.fromJson<int?>(json['publisherId']),
      imprintId: serializer.fromJson<int?>(json['imprintId']),
      yearBegan: serializer.fromJson<int?>(json['yearBegan']),
      yearEnd: serializer.fromJson<int?>(json['yearEnd']),
      description: serializer.fromJson<String?>(json['description']),
      issueCount: serializer.fromJson<int?>(json['issueCount']),
      computedCoverUrl: serializer.fromJson<String?>(json['computedCoverUrl']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortName': serializer.toJson<String?>(sortName),
      'volume': serializer.toJson<int?>(volume),
      'seriesTypeId': serializer.toJson<int?>(seriesTypeId),
      'status': serializer.toJson<String?>(status),
      'publisherId': serializer.toJson<int?>(publisherId),
      'imprintId': serializer.toJson<int?>(imprintId),
      'yearBegan': serializer.toJson<int?>(yearBegan),
      'yearEnd': serializer.toJson<int?>(yearEnd),
      'description': serializer.toJson<String?>(description),
      'issueCount': serializer.toJson<int?>(issueCount),
      'computedCoverUrl': serializer.toJson<String?>(computedCoverUrl),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronSery copyWith({
    int? id,
    String? name,
    Value<String?> sortName = const Value.absent(),
    Value<int?> volume = const Value.absent(),
    Value<int?> seriesTypeId = const Value.absent(),
    Value<String?> status = const Value.absent(),
    Value<int?> publisherId = const Value.absent(),
    Value<int?> imprintId = const Value.absent(),
    Value<int?> yearBegan = const Value.absent(),
    Value<int?> yearEnd = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> issueCount = const Value.absent(),
    Value<String?> computedCoverUrl = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronSery(
    id: id ?? this.id,
    name: name ?? this.name,
    sortName: sortName.present ? sortName.value : this.sortName,
    volume: volume.present ? volume.value : this.volume,
    seriesTypeId: seriesTypeId.present ? seriesTypeId.value : this.seriesTypeId,
    status: status.present ? status.value : this.status,
    publisherId: publisherId.present ? publisherId.value : this.publisherId,
    imprintId: imprintId.present ? imprintId.value : this.imprintId,
    yearBegan: yearBegan.present ? yearBegan.value : this.yearBegan,
    yearEnd: yearEnd.present ? yearEnd.value : this.yearEnd,
    description: description.present ? description.value : this.description,
    issueCount: issueCount.present ? issueCount.value : this.issueCount,
    computedCoverUrl: computedCoverUrl.present
        ? computedCoverUrl.value
        : this.computedCoverUrl,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronSery copyWithCompanion(MetronSeriesCompanion data) {
    return MetronSery(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortName: data.sortName.present ? data.sortName.value : this.sortName,
      volume: data.volume.present ? data.volume.value : this.volume,
      seriesTypeId: data.seriesTypeId.present
          ? data.seriesTypeId.value
          : this.seriesTypeId,
      status: data.status.present ? data.status.value : this.status,
      publisherId: data.publisherId.present
          ? data.publisherId.value
          : this.publisherId,
      imprintId: data.imprintId.present ? data.imprintId.value : this.imprintId,
      yearBegan: data.yearBegan.present ? data.yearBegan.value : this.yearBegan,
      yearEnd: data.yearEnd.present ? data.yearEnd.value : this.yearEnd,
      description: data.description.present
          ? data.description.value
          : this.description,
      issueCount: data.issueCount.present
          ? data.issueCount.value
          : this.issueCount,
      computedCoverUrl: data.computedCoverUrl.present
          ? data.computedCoverUrl.value
          : this.computedCoverUrl,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronSery(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('volume: $volume, ')
          ..write('seriesTypeId: $seriesTypeId, ')
          ..write('status: $status, ')
          ..write('publisherId: $publisherId, ')
          ..write('imprintId: $imprintId, ')
          ..write('yearBegan: $yearBegan, ')
          ..write('yearEnd: $yearEnd, ')
          ..write('description: $description, ')
          ..write('issueCount: $issueCount, ')
          ..write('computedCoverUrl: $computedCoverUrl, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sortName,
    volume,
    seriesTypeId,
    status,
    publisherId,
    imprintId,
    yearBegan,
    yearEnd,
    description,
    issueCount,
    computedCoverUrl,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronSery &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortName == this.sortName &&
          other.volume == this.volume &&
          other.seriesTypeId == this.seriesTypeId &&
          other.status == this.status &&
          other.publisherId == this.publisherId &&
          other.imprintId == this.imprintId &&
          other.yearBegan == this.yearBegan &&
          other.yearEnd == this.yearEnd &&
          other.description == this.description &&
          other.issueCount == this.issueCount &&
          other.computedCoverUrl == this.computedCoverUrl &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronSeriesCompanion extends UpdateCompanion<MetronSery> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> sortName;
  final Value<int?> volume;
  final Value<int?> seriesTypeId;
  final Value<String?> status;
  final Value<int?> publisherId;
  final Value<int?> imprintId;
  final Value<int?> yearBegan;
  final Value<int?> yearEnd;
  final Value<String?> description;
  final Value<int?> issueCount;
  final Value<String?> computedCoverUrl;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronSeriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortName = const Value.absent(),
    this.volume = const Value.absent(),
    this.seriesTypeId = const Value.absent(),
    this.status = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.yearBegan = const Value.absent(),
    this.yearEnd = const Value.absent(),
    this.description = const Value.absent(),
    this.issueCount = const Value.absent(),
    this.computedCoverUrl = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronSeriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.sortName = const Value.absent(),
    this.volume = const Value.absent(),
    this.seriesTypeId = const Value.absent(),
    this.status = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.yearBegan = const Value.absent(),
    this.yearEnd = const Value.absent(),
    this.description = const Value.absent(),
    this.issueCount = const Value.absent(),
    this.computedCoverUrl = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronSery> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sortName,
    Expression<int>? volume,
    Expression<int>? seriesTypeId,
    Expression<String>? status,
    Expression<int>? publisherId,
    Expression<int>? imprintId,
    Expression<int>? yearBegan,
    Expression<int>? yearEnd,
    Expression<String>? description,
    Expression<int>? issueCount,
    Expression<String>? computedCoverUrl,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortName != null) 'sort_name': sortName,
      if (volume != null) 'volume': volume,
      if (seriesTypeId != null) 'series_type_id': seriesTypeId,
      if (status != null) 'status': status,
      if (publisherId != null) 'publisher_id': publisherId,
      if (imprintId != null) 'imprint_id': imprintId,
      if (yearBegan != null) 'year_began': yearBegan,
      if (yearEnd != null) 'year_end': yearEnd,
      if (description != null) 'description': description,
      if (issueCount != null) 'issue_count': issueCount,
      if (computedCoverUrl != null) 'computed_cover_url': computedCoverUrl,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronSeriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? sortName,
    Value<int?>? volume,
    Value<int?>? seriesTypeId,
    Value<String?>? status,
    Value<int?>? publisherId,
    Value<int?>? imprintId,
    Value<int?>? yearBegan,
    Value<int?>? yearEnd,
    Value<String?>? description,
    Value<int?>? issueCount,
    Value<String?>? computedCoverUrl,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronSeriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortName: sortName ?? this.sortName,
      volume: volume ?? this.volume,
      seriesTypeId: seriesTypeId ?? this.seriesTypeId,
      status: status ?? this.status,
      publisherId: publisherId ?? this.publisherId,
      imprintId: imprintId ?? this.imprintId,
      yearBegan: yearBegan ?? this.yearBegan,
      yearEnd: yearEnd ?? this.yearEnd,
      description: description ?? this.description,
      issueCount: issueCount ?? this.issueCount,
      computedCoverUrl: computedCoverUrl ?? this.computedCoverUrl,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortName.present) {
      map['sort_name'] = Variable<String>(sortName.value);
    }
    if (volume.present) {
      map['volume'] = Variable<int>(volume.value);
    }
    if (seriesTypeId.present) {
      map['series_type_id'] = Variable<int>(seriesTypeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (imprintId.present) {
      map['imprint_id'] = Variable<int>(imprintId.value);
    }
    if (yearBegan.present) {
      map['year_began'] = Variable<int>(yearBegan.value);
    }
    if (yearEnd.present) {
      map['year_end'] = Variable<int>(yearEnd.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (issueCount.present) {
      map['issue_count'] = Variable<int>(issueCount.value);
    }
    if (computedCoverUrl.present) {
      map['computed_cover_url'] = Variable<String>(computedCoverUrl.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronSeriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortName: $sortName, ')
          ..write('volume: $volume, ')
          ..write('seriesTypeId: $seriesTypeId, ')
          ..write('status: $status, ')
          ..write('publisherId: $publisherId, ')
          ..write('imprintId: $imprintId, ')
          ..write('yearBegan: $yearBegan, ')
          ..write('yearEnd: $yearEnd, ')
          ..write('description: $description, ')
          ..write('issueCount: $issueCount, ')
          ..write('computedCoverUrl: $computedCoverUrl, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronCreatorsTable extends MetronCreators
    with TableInfo<$MetronCreatorsTable, MetronCreator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronCreatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthMeta = const VerificationMeta('birth');
  @override
  late final GeneratedColumn<String> birth = GeneratedColumn<String>(
    'birth',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deathMeta = const VerificationMeta('death');
  @override
  late final GeneratedColumn<String> death = GeneratedColumn<String>(
    'death',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasJsonMeta = const VerificationMeta(
    'aliasJson',
  );
  @override
  late final GeneratedColumn<String> aliasJson = GeneratedColumn<String>(
    'alias_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    description,
    birth,
    death,
    aliasJson,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_creators';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronCreator> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('birth')) {
      context.handle(
        _birthMeta,
        birth.isAcceptableOrUnknown(data['birth']!, _birthMeta),
      );
    }
    if (data.containsKey('death')) {
      context.handle(
        _deathMeta,
        death.isAcceptableOrUnknown(data['death']!, _deathMeta),
      );
    }
    if (data.containsKey('alias_json')) {
      context.handle(
        _aliasJsonMeta,
        aliasJson.isAcceptableOrUnknown(data['alias_json']!, _aliasJsonMeta),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronCreator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronCreator(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      birth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth'],
      ),
      death: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}death'],
      ),
      aliasJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_json'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronCreatorsTable createAlias(String alias) {
    return $MetronCreatorsTable(attachedDatabase, alias);
  }
}

class MetronCreator extends DataClass implements Insertable<MetronCreator> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? description;
  final String? birth;
  final String? death;
  final String? aliasJson;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronCreator({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.birth,
    this.death,
    this.aliasJson,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || birth != null) {
      map['birth'] = Variable<String>(birth);
    }
    if (!nullToAbsent || death != null) {
      map['death'] = Variable<String>(death);
    }
    if (!nullToAbsent || aliasJson != null) {
      map['alias_json'] = Variable<String>(aliasJson);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronCreatorsCompanion toCompanion(bool nullToAbsent) {
    return MetronCreatorsCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      birth: birth == null && nullToAbsent
          ? const Value.absent()
          : Value(birth),
      death: death == null && nullToAbsent
          ? const Value.absent()
          : Value(death),
      aliasJson: aliasJson == null && nullToAbsent
          ? const Value.absent()
          : Value(aliasJson),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronCreator.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronCreator(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      birth: serializer.fromJson<String?>(json['birth']),
      death: serializer.fromJson<String?>(json['death']),
      aliasJson: serializer.fromJson<String?>(json['aliasJson']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'birth': serializer.toJson<String?>(birth),
      'death': serializer.toJson<String?>(death),
      'aliasJson': serializer.toJson<String?>(aliasJson),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronCreator copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> birth = const Value.absent(),
    Value<String?> death = const Value.absent(),
    Value<String?> aliasJson = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronCreator(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    birth: birth.present ? birth.value : this.birth,
    death: death.present ? death.value : this.death,
    aliasJson: aliasJson.present ? aliasJson.value : this.aliasJson,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronCreator copyWithCompanion(MetronCreatorsCompanion data) {
    return MetronCreator(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      birth: data.birth.present ? data.birth.value : this.birth,
      death: data.death.present ? data.death.value : this.death,
      aliasJson: data.aliasJson.present ? data.aliasJson.value : this.aliasJson,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronCreator(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('birth: $birth, ')
          ..write('death: $death, ')
          ..write('aliasJson: $aliasJson, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    description,
    birth,
    death,
    aliasJson,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronCreator &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.birth == this.birth &&
          other.death == this.death &&
          other.aliasJson == this.aliasJson &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronCreatorsCompanion extends UpdateCompanion<MetronCreator> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<String?> birth;
  final Value<String?> death;
  final Value<String?> aliasJson;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronCreatorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.birth = const Value.absent(),
    this.death = const Value.absent(),
    this.aliasJson = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronCreatorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.birth = const Value.absent(),
    this.death = const Value.absent(),
    this.aliasJson = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronCreator> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<String>? birth,
    Expression<String>? death,
    Expression<String>? aliasJson,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (birth != null) 'birth': birth,
      if (death != null) 'death': death,
      if (aliasJson != null) 'alias_json': aliasJson,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronCreatorsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<String?>? birth,
    Value<String?>? death,
    Value<String?>? aliasJson,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronCreatorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      birth: birth ?? this.birth,
      death: death ?? this.death,
      aliasJson: aliasJson ?? this.aliasJson,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (birth.present) {
      map['birth'] = Variable<String>(birth.value);
    }
    if (death.present) {
      map['death'] = Variable<String>(death.value);
    }
    if (aliasJson.present) {
      map['alias_json'] = Variable<String>(aliasJson.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronCreatorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('birth: $birth, ')
          ..write('death: $death, ')
          ..write('aliasJson: $aliasJson, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronCharactersTable extends MetronCharacters
    with TableInfo<$MetronCharactersTable, MetronCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronCharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasJsonMeta = const VerificationMeta(
    'aliasJson',
  );
  @override
  late final GeneratedColumn<String> aliasJson = GeneratedColumn<String>(
    'alias_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    description,
    aliasJson,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('alias_json')) {
      context.handle(
        _aliasJsonMeta,
        aliasJson.isAcceptableOrUnknown(data['alias_json']!, _aliasJsonMeta),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronCharacter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      aliasJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias_json'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronCharactersTable createAlias(String alias) {
    return $MetronCharactersTable(attachedDatabase, alias);
  }
}

class MetronCharacter extends DataClass implements Insertable<MetronCharacter> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? description;
  final String? aliasJson;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronCharacter({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.aliasJson,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || aliasJson != null) {
      map['alias_json'] = Variable<String>(aliasJson);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronCharactersCompanion toCompanion(bool nullToAbsent) {
    return MetronCharactersCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      aliasJson: aliasJson == null && nullToAbsent
          ? const Value.absent()
          : Value(aliasJson),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronCharacter(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      aliasJson: serializer.fromJson<String?>(json['aliasJson']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'aliasJson': serializer.toJson<String?>(aliasJson),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronCharacter copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> aliasJson = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronCharacter(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    aliasJson: aliasJson.present ? aliasJson.value : this.aliasJson,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronCharacter copyWithCompanion(MetronCharactersCompanion data) {
    return MetronCharacter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      aliasJson: data.aliasJson.present ? data.aliasJson.value : this.aliasJson,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronCharacter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('aliasJson: $aliasJson, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    description,
    aliasJson,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronCharacter &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.aliasJson == this.aliasJson &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronCharactersCompanion extends UpdateCompanion<MetronCharacter> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<String?> aliasJson;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronCharactersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.aliasJson = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronCharactersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.aliasJson = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronCharacter> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<String>? aliasJson,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (aliasJson != null) 'alias_json': aliasJson,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronCharactersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<String?>? aliasJson,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronCharactersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      aliasJson: aliasJson ?? this.aliasJson,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (aliasJson.present) {
      map['alias_json'] = Variable<String>(aliasJson.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronCharactersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('aliasJson: $aliasJson, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronArcsTable extends MetronArcs
    with TableInfo<$MetronArcsTable, MetronArc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronArcsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    description,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_arcs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronArc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronArc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronArc(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronArcsTable createAlias(String alias) {
    return $MetronArcsTable(attachedDatabase, alias);
  }
}

class MetronArc extends DataClass implements Insertable<MetronArc> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? description;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronArc({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronArcsCompanion toCompanion(bool nullToAbsent) {
    return MetronArcsCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronArc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronArc(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronArc copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronArc(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronArc copyWithCompanion(MetronArcsCompanion data) {
    return MetronArc(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronArc(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    description,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronArc &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronArcsCompanion extends UpdateCompanion<MetronArc> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronArcsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronArcsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronArc> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronArcsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronArcsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronArcsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronTeamsTable extends MetronTeams
    with TableInfo<$MetronTeamsTable, MetronTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    description,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronTeam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronTeamsTable createAlias(String alias) {
    return $MetronTeamsTable(attachedDatabase, alias);
  }
}

class MetronTeam extends DataClass implements Insertable<MetronTeam> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? description;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronTeam({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronTeamsCompanion toCompanion(bool nullToAbsent) {
    return MetronTeamsCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronTeam(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronTeam copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronTeam(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronTeam copyWithCompanion(MetronTeamsCompanion data) {
    return MetronTeam(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronTeam(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    description,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronTeam &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronTeamsCompanion extends UpdateCompanion<MetronTeam> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronTeamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronTeamsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronTeam> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronTeamsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronTeamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronTeamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronUniversesTable extends MetronUniverses
    with TableInfo<$MetronUniversesTable, MetronUniverse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronUniversesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _designationMeta = const VerificationMeta(
    'designation',
  );
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
    'designation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherIdMeta = const VerificationMeta(
    'publisherId',
  );
  @override
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
    'publisher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    designation,
    publisherId,
    imageUrl,
    description,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_universes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronUniverse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('designation')) {
      context.handle(
        _designationMeta,
        designation.isAcceptableOrUnknown(
          data['designation']!,
          _designationMeta,
        ),
      );
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
        _publisherIdMeta,
        publisherId.isAcceptableOrUnknown(
          data['publisher_id']!,
          _publisherIdMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronUniverse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronUniverse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      designation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation'],
      ),
      publisherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publisher_id'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronUniversesTable createAlias(String alias) {
    return $MetronUniversesTable(attachedDatabase, alias);
  }
}

class MetronUniverse extends DataClass implements Insertable<MetronUniverse> {
  final int id;
  final String name;
  final String? designation;
  final int? publisherId;
  final String? imageUrl;
  final String? description;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronUniverse({
    required this.id,
    required this.name,
    this.designation,
    this.publisherId,
    this.imageUrl,
    this.description,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    if (!nullToAbsent || publisherId != null) {
      map['publisher_id'] = Variable<int>(publisherId);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronUniversesCompanion toCompanion(bool nullToAbsent) {
    return MetronUniversesCompanion(
      id: Value(id),
      name: Value(name),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      publisherId: publisherId == null && nullToAbsent
          ? const Value.absent()
          : Value(publisherId),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronUniverse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronUniverse(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      designation: serializer.fromJson<String?>(json['designation']),
      publisherId: serializer.fromJson<int?>(json['publisherId']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'designation': serializer.toJson<String?>(designation),
      'publisherId': serializer.toJson<int?>(publisherId),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronUniverse copyWith({
    int? id,
    String? name,
    Value<String?> designation = const Value.absent(),
    Value<int?> publisherId = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronUniverse(
    id: id ?? this.id,
    name: name ?? this.name,
    designation: designation.present ? designation.value : this.designation,
    publisherId: publisherId.present ? publisherId.value : this.publisherId,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronUniverse copyWithCompanion(MetronUniversesCompanion data) {
    return MetronUniverse(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      designation: data.designation.present
          ? data.designation.value
          : this.designation,
      publisherId: data.publisherId.present
          ? data.publisherId.value
          : this.publisherId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronUniverse(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('designation: $designation, ')
          ..write('publisherId: $publisherId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    designation,
    publisherId,
    imageUrl,
    description,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronUniverse &&
          other.id == this.id &&
          other.name == this.name &&
          other.designation == this.designation &&
          other.publisherId == this.publisherId &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronUniversesCompanion extends UpdateCompanion<MetronUniverse> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> designation;
  final Value<int?> publisherId;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronUniversesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.designation = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronUniversesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.designation = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronUniverse> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? designation,
    Expression<int>? publisherId,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (designation != null) 'designation': designation,
      if (publisherId != null) 'publisher_id': publisherId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronUniversesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? designation,
    Value<int?>? publisherId,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronUniversesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      publisherId: publisherId ?? this.publisherId,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronUniversesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('designation: $designation, ')
          ..write('publisherId: $publisherId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronPublishersTable extends MetronPublishers
    with TableInfo<$MetronPublishersTable, MetronPublisher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronPublishersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundedMeta = const VerificationMeta(
    'founded',
  );
  @override
  late final GeneratedColumn<int> founded = GeneratedColumn<int>(
    'founded',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    imageUrl,
    description,
    country,
    founded,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_publishers';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronPublisher> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('founded')) {
      context.handle(
        _foundedMeta,
        founded.isAcceptableOrUnknown(data['founded']!, _foundedMeta),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronPublisher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronPublisher(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      founded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}founded'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronPublishersTable createAlias(String alias) {
    return $MetronPublishersTable(attachedDatabase, alias);
  }
}

class MetronPublisher extends DataClass implements Insertable<MetronPublisher> {
  final int id;
  final String name;
  final String? imageUrl;
  final String? description;
  final String? country;
  final int? founded;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronPublisher({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.country,
    this.founded,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || founded != null) {
      map['founded'] = Variable<int>(founded);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronPublishersCompanion toCompanion(bool nullToAbsent) {
    return MetronPublishersCompanion(
      id: Value(id),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      founded: founded == null && nullToAbsent
          ? const Value.absent()
          : Value(founded),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronPublisher.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronPublisher(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      country: serializer.fromJson<String?>(json['country']),
      founded: serializer.fromJson<int?>(json['founded']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'country': serializer.toJson<String?>(country),
      'founded': serializer.toJson<int?>(founded),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronPublisher copyWith({
    int? id,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<int?> founded = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronPublisher(
    id: id ?? this.id,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    country: country.present ? country.value : this.country,
    founded: founded.present ? founded.value : this.founded,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronPublisher copyWithCompanion(MetronPublishersCompanion data) {
    return MetronPublisher(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      country: data.country.present ? data.country.value : this.country,
      founded: data.founded.present ? data.founded.value : this.founded,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronPublisher(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('country: $country, ')
          ..write('founded: $founded, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    imageUrl,
    description,
    country,
    founded,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronPublisher &&
          other.id == this.id &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.country == this.country &&
          other.founded == this.founded &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronPublishersCompanion extends UpdateCompanion<MetronPublisher> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<String?> country;
  final Value<int?> founded;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronPublishersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.country = const Value.absent(),
    this.founded = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronPublishersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.country = const Value.absent(),
    this.founded = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronPublisher> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<String>? country,
    Expression<int>? founded,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (country != null) 'country': country,
      if (founded != null) 'founded': founded,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronPublishersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<String?>? country,
    Value<int?>? founded,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronPublishersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      country: country ?? this.country,
      founded: founded ?? this.founded,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (founded.present) {
      map['founded'] = Variable<int>(founded.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronPublishersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('country: $country, ')
          ..write('founded: $founded, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronImprintsTable extends MetronImprints
    with TableInfo<$MetronImprintsTable, MetronImprint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronImprintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publisherIdMeta = const VerificationMeta(
    'publisherId',
  );
  @override
  late final GeneratedColumn<int> publisherId = GeneratedColumn<int>(
    'publisher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foundedMeta = const VerificationMeta(
    'founded',
  );
  @override
  late final GeneratedColumn<int> founded = GeneratedColumn<int>(
    'founded',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cvIdMeta = const VerificationMeta('cvId');
  @override
  late final GeneratedColumn<int> cvId = GeneratedColumn<int>(
    'cv_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gcdIdMeta = const VerificationMeta('gcdId');
  @override
  late final GeneratedColumn<int> gcdId = GeneratedColumn<int>(
    'gcd_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    publisherId,
    imageUrl,
    description,
    founded,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_imprints';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronImprint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('publisher_id')) {
      context.handle(
        _publisherIdMeta,
        publisherId.isAcceptableOrUnknown(
          data['publisher_id']!,
          _publisherIdMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('founded')) {
      context.handle(
        _foundedMeta,
        founded.isAcceptableOrUnknown(data['founded']!, _foundedMeta),
      );
    }
    if (data.containsKey('cv_id')) {
      context.handle(
        _cvIdMeta,
        cvId.isAcceptableOrUnknown(data['cv_id']!, _cvIdMeta),
      );
    }
    if (data.containsKey('gcd_id')) {
      context.handle(
        _gcdIdMeta,
        gcdId.isAcceptableOrUnknown(data['gcd_id']!, _gcdIdMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronImprint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronImprint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      publisherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}publisher_id'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      founded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}founded'],
      ),
      cvId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cv_id'],
      ),
      gcdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gcd_id'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronImprintsTable createAlias(String alias) {
    return $MetronImprintsTable(attachedDatabase, alias);
  }
}

class MetronImprint extends DataClass implements Insertable<MetronImprint> {
  final int id;
  final String name;
  final int? publisherId;
  final String? imageUrl;
  final String? description;
  final int? founded;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronImprint({
    required this.id,
    required this.name,
    this.publisherId,
    this.imageUrl,
    this.description,
    this.founded,
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || publisherId != null) {
      map['publisher_id'] = Variable<int>(publisherId);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || founded != null) {
      map['founded'] = Variable<int>(founded);
    }
    if (!nullToAbsent || cvId != null) {
      map['cv_id'] = Variable<int>(cvId);
    }
    if (!nullToAbsent || gcdId != null) {
      map['gcd_id'] = Variable<int>(gcdId);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronImprintsCompanion toCompanion(bool nullToAbsent) {
    return MetronImprintsCompanion(
      id: Value(id),
      name: Value(name),
      publisherId: publisherId == null && nullToAbsent
          ? const Value.absent()
          : Value(publisherId),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      founded: founded == null && nullToAbsent
          ? const Value.absent()
          : Value(founded),
      cvId: cvId == null && nullToAbsent ? const Value.absent() : Value(cvId),
      gcdId: gcdId == null && nullToAbsent
          ? const Value.absent()
          : Value(gcdId),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronImprint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronImprint(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      publisherId: serializer.fromJson<int?>(json['publisherId']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      description: serializer.fromJson<String?>(json['description']),
      founded: serializer.fromJson<int?>(json['founded']),
      cvId: serializer.fromJson<int?>(json['cvId']),
      gcdId: serializer.fromJson<int?>(json['gcdId']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'publisherId': serializer.toJson<int?>(publisherId),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'description': serializer.toJson<String?>(description),
      'founded': serializer.toJson<int?>(founded),
      'cvId': serializer.toJson<int?>(cvId),
      'gcdId': serializer.toJson<int?>(gcdId),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronImprint copyWith({
    int? id,
    String? name,
    Value<int?> publisherId = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> founded = const Value.absent(),
    Value<int?> cvId = const Value.absent(),
    Value<int?> gcdId = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronImprint(
    id: id ?? this.id,
    name: name ?? this.name,
    publisherId: publisherId.present ? publisherId.value : this.publisherId,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    description: description.present ? description.value : this.description,
    founded: founded.present ? founded.value : this.founded,
    cvId: cvId.present ? cvId.value : this.cvId,
    gcdId: gcdId.present ? gcdId.value : this.gcdId,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronImprint copyWithCompanion(MetronImprintsCompanion data) {
    return MetronImprint(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      publisherId: data.publisherId.present
          ? data.publisherId.value
          : this.publisherId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      founded: data.founded.present ? data.founded.value : this.founded,
      cvId: data.cvId.present ? data.cvId.value : this.cvId,
      gcdId: data.gcdId.present ? data.gcdId.value : this.gcdId,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronImprint(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('publisherId: $publisherId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('founded: $founded, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    publisherId,
    imageUrl,
    description,
    founded,
    cvId,
    gcdId,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronImprint &&
          other.id == this.id &&
          other.name == this.name &&
          other.publisherId == this.publisherId &&
          other.imageUrl == this.imageUrl &&
          other.description == this.description &&
          other.founded == this.founded &&
          other.cvId == this.cvId &&
          other.gcdId == this.gcdId &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronImprintsCompanion extends UpdateCompanion<MetronImprint> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> publisherId;
  final Value<String?> imageUrl;
  final Value<String?> description;
  final Value<int?> founded;
  final Value<int?> cvId;
  final Value<int?> gcdId;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronImprintsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.publisherId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.founded = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronImprintsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.publisherId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.founded = const Value.absent(),
    this.cvId = const Value.absent(),
    this.gcdId = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronImprint> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? publisherId,
    Expression<String>? imageUrl,
    Expression<String>? description,
    Expression<int>? founded,
    Expression<int>? cvId,
    Expression<int>? gcdId,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (publisherId != null) 'publisher_id': publisherId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (description != null) 'description': description,
      if (founded != null) 'founded': founded,
      if (cvId != null) 'cv_id': cvId,
      if (gcdId != null) 'gcd_id': gcdId,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronImprintsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? publisherId,
    Value<String?>? imageUrl,
    Value<String?>? description,
    Value<int?>? founded,
    Value<int?>? cvId,
    Value<int?>? gcdId,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronImprintsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      publisherId: publisherId ?? this.publisherId,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      founded: founded ?? this.founded,
      cvId: cvId ?? this.cvId,
      gcdId: gcdId ?? this.gcdId,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (publisherId.present) {
      map['publisher_id'] = Variable<int>(publisherId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (founded.present) {
      map['founded'] = Variable<int>(founded.value);
    }
    if (cvId.present) {
      map['cv_id'] = Variable<int>(cvId.value);
    }
    if (gcdId.present) {
      map['gcd_id'] = Variable<int>(gcdId.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronImprintsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('publisherId: $publisherId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('description: $description, ')
          ..write('founded: $founded, ')
          ..write('cvId: $cvId, ')
          ..write('gcdId: $gcdId, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $MetronReadingListsTable extends MetronReadingLists
    with TableInfo<$MetronReadingListsTable, MetronReadingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronReadingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _listTypeMeta = const VerificationMeta(
    'listType',
  );
  @override
  late final GeneratedColumn<String> listType = GeneratedColumn<String>(
    'list_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
  );
  static const VerificationMeta _attributionSourceMeta = const VerificationMeta(
    'attributionSource',
  );
  @override
  late final GeneratedColumn<String> attributionSource =
      GeneratedColumn<String>(
        'attribution_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _attributionUrlMeta = const VerificationMeta(
    'attributionUrl',
  );
  @override
  late final GeneratedColumn<String> attributionUrl = GeneratedColumn<String>(
    'attribution_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageRatingMeta = const VerificationMeta(
    'averageRating',
  );
  @override
  late final GeneratedColumn<double> averageRating = GeneratedColumn<double>(
    'average_rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingCountMeta = const VerificationMeta(
    'ratingCount',
  );
  @override
  late final GeneratedColumn<int> ratingCount = GeneratedColumn<int>(
    'rating_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsUrlMeta = const VerificationMeta(
    'itemsUrl',
  );
  @override
  late final GeneratedColumn<String> itemsUrl = GeneratedColumn<String>(
    'items_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resourceUrlMeta = const VerificationMeta(
    'resourceUrl',
  );
  @override
  late final GeneratedColumn<String> resourceUrl = GeneratedColumn<String>(
    'resource_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modifiedMeta = const VerificationMeta(
    'modified',
  );
  @override
  late final GeneratedColumn<String> modified = GeneratedColumn<String>(
    'modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullyHydratedMeta = const VerificationMeta(
    'isFullyHydrated',
  );
  @override
  late final GeneratedColumn<bool> isFullyHydrated = GeneratedColumn<bool>(
    'is_fully_hydrated',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_fully_hydrated" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    slug,
    userId,
    description,
    imageUrl,
    listType,
    isPrivate,
    attributionSource,
    attributionUrl,
    averageRating,
    ratingCount,
    itemsUrl,
    resourceUrl,
    modified,
    isFullyHydrated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_reading_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronReadingList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('list_type')) {
      context.handle(
        _listTypeMeta,
        listType.isAcceptableOrUnknown(data['list_type']!, _listTypeMeta),
      );
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    if (data.containsKey('attribution_source')) {
      context.handle(
        _attributionSourceMeta,
        attributionSource.isAcceptableOrUnknown(
          data['attribution_source']!,
          _attributionSourceMeta,
        ),
      );
    }
    if (data.containsKey('attribution_url')) {
      context.handle(
        _attributionUrlMeta,
        attributionUrl.isAcceptableOrUnknown(
          data['attribution_url']!,
          _attributionUrlMeta,
        ),
      );
    }
    if (data.containsKey('average_rating')) {
      context.handle(
        _averageRatingMeta,
        averageRating.isAcceptableOrUnknown(
          data['average_rating']!,
          _averageRatingMeta,
        ),
      );
    }
    if (data.containsKey('rating_count')) {
      context.handle(
        _ratingCountMeta,
        ratingCount.isAcceptableOrUnknown(
          data['rating_count']!,
          _ratingCountMeta,
        ),
      );
    }
    if (data.containsKey('items_url')) {
      context.handle(
        _itemsUrlMeta,
        itemsUrl.isAcceptableOrUnknown(data['items_url']!, _itemsUrlMeta),
      );
    }
    if (data.containsKey('resource_url')) {
      context.handle(
        _resourceUrlMeta,
        resourceUrl.isAcceptableOrUnknown(
          data['resource_url']!,
          _resourceUrlMeta,
        ),
      );
    }
    if (data.containsKey('modified')) {
      context.handle(
        _modifiedMeta,
        modified.isAcceptableOrUnknown(data['modified']!, _modifiedMeta),
      );
    }
    if (data.containsKey('is_fully_hydrated')) {
      context.handle(
        _isFullyHydratedMeta,
        isFullyHydrated.isAcceptableOrUnknown(
          data['is_fully_hydrated']!,
          _isFullyHydratedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MetronReadingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronReadingList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      listType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_type'],
      ),
      isPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private'],
      ),
      attributionSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution_source'],
      ),
      attributionUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribution_url'],
      ),
      averageRating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_rating'],
      ),
      ratingCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating_count'],
      ),
      itemsUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_url'],
      ),
      resourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_url'],
      ),
      modified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified'],
      ),
      isFullyHydrated: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_fully_hydrated'],
      )!,
    );
  }

  @override
  $MetronReadingListsTable createAlias(String alias) {
    return $MetronReadingListsTable(attachedDatabase, alias);
  }
}

class MetronReadingList extends DataClass
    implements Insertable<MetronReadingList> {
  final int id;
  final String name;
  final String? slug;
  final int? userId;
  final String? description;
  final String? imageUrl;
  final String? listType;
  final bool? isPrivate;
  final String? attributionSource;
  final String? attributionUrl;
  final double? averageRating;
  final int? ratingCount;
  final String? itemsUrl;
  final String? resourceUrl;
  final String? modified;
  final bool isFullyHydrated;
  const MetronReadingList({
    required this.id,
    required this.name,
    this.slug,
    this.userId,
    this.description,
    this.imageUrl,
    this.listType,
    this.isPrivate,
    this.attributionSource,
    this.attributionUrl,
    this.averageRating,
    this.ratingCount,
    this.itemsUrl,
    this.resourceUrl,
    this.modified,
    required this.isFullyHydrated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || slug != null) {
      map['slug'] = Variable<String>(slug);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || listType != null) {
      map['list_type'] = Variable<String>(listType);
    }
    if (!nullToAbsent || isPrivate != null) {
      map['is_private'] = Variable<bool>(isPrivate);
    }
    if (!nullToAbsent || attributionSource != null) {
      map['attribution_source'] = Variable<String>(attributionSource);
    }
    if (!nullToAbsent || attributionUrl != null) {
      map['attribution_url'] = Variable<String>(attributionUrl);
    }
    if (!nullToAbsent || averageRating != null) {
      map['average_rating'] = Variable<double>(averageRating);
    }
    if (!nullToAbsent || ratingCount != null) {
      map['rating_count'] = Variable<int>(ratingCount);
    }
    if (!nullToAbsent || itemsUrl != null) {
      map['items_url'] = Variable<String>(itemsUrl);
    }
    if (!nullToAbsent || resourceUrl != null) {
      map['resource_url'] = Variable<String>(resourceUrl);
    }
    if (!nullToAbsent || modified != null) {
      map['modified'] = Variable<String>(modified);
    }
    map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated);
    return map;
  }

  MetronReadingListsCompanion toCompanion(bool nullToAbsent) {
    return MetronReadingListsCompanion(
      id: Value(id),
      name: Value(name),
      slug: slug == null && nullToAbsent ? const Value.absent() : Value(slug),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      listType: listType == null && nullToAbsent
          ? const Value.absent()
          : Value(listType),
      isPrivate: isPrivate == null && nullToAbsent
          ? const Value.absent()
          : Value(isPrivate),
      attributionSource: attributionSource == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionSource),
      attributionUrl: attributionUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(attributionUrl),
      averageRating: averageRating == null && nullToAbsent
          ? const Value.absent()
          : Value(averageRating),
      ratingCount: ratingCount == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingCount),
      itemsUrl: itemsUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(itemsUrl),
      resourceUrl: resourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceUrl),
      modified: modified == null && nullToAbsent
          ? const Value.absent()
          : Value(modified),
      isFullyHydrated: Value(isFullyHydrated),
    );
  }

  factory MetronReadingList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronReadingList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      slug: serializer.fromJson<String?>(json['slug']),
      userId: serializer.fromJson<int?>(json['userId']),
      description: serializer.fromJson<String?>(json['description']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      listType: serializer.fromJson<String?>(json['listType']),
      isPrivate: serializer.fromJson<bool?>(json['isPrivate']),
      attributionSource: serializer.fromJson<String?>(
        json['attributionSource'],
      ),
      attributionUrl: serializer.fromJson<String?>(json['attributionUrl']),
      averageRating: serializer.fromJson<double?>(json['averageRating']),
      ratingCount: serializer.fromJson<int?>(json['ratingCount']),
      itemsUrl: serializer.fromJson<String?>(json['itemsUrl']),
      resourceUrl: serializer.fromJson<String?>(json['resourceUrl']),
      modified: serializer.fromJson<String?>(json['modified']),
      isFullyHydrated: serializer.fromJson<bool>(json['isFullyHydrated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'slug': serializer.toJson<String?>(slug),
      'userId': serializer.toJson<int?>(userId),
      'description': serializer.toJson<String?>(description),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'listType': serializer.toJson<String?>(listType),
      'isPrivate': serializer.toJson<bool?>(isPrivate),
      'attributionSource': serializer.toJson<String?>(attributionSource),
      'attributionUrl': serializer.toJson<String?>(attributionUrl),
      'averageRating': serializer.toJson<double?>(averageRating),
      'ratingCount': serializer.toJson<int?>(ratingCount),
      'itemsUrl': serializer.toJson<String?>(itemsUrl),
      'resourceUrl': serializer.toJson<String?>(resourceUrl),
      'modified': serializer.toJson<String?>(modified),
      'isFullyHydrated': serializer.toJson<bool>(isFullyHydrated),
    };
  }

  MetronReadingList copyWith({
    int? id,
    String? name,
    Value<String?> slug = const Value.absent(),
    Value<int?> userId = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> listType = const Value.absent(),
    Value<bool?> isPrivate = const Value.absent(),
    Value<String?> attributionSource = const Value.absent(),
    Value<String?> attributionUrl = const Value.absent(),
    Value<double?> averageRating = const Value.absent(),
    Value<int?> ratingCount = const Value.absent(),
    Value<String?> itemsUrl = const Value.absent(),
    Value<String?> resourceUrl = const Value.absent(),
    Value<String?> modified = const Value.absent(),
    bool? isFullyHydrated,
  }) => MetronReadingList(
    id: id ?? this.id,
    name: name ?? this.name,
    slug: slug.present ? slug.value : this.slug,
    userId: userId.present ? userId.value : this.userId,
    description: description.present ? description.value : this.description,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    listType: listType.present ? listType.value : this.listType,
    isPrivate: isPrivate.present ? isPrivate.value : this.isPrivate,
    attributionSource: attributionSource.present
        ? attributionSource.value
        : this.attributionSource,
    attributionUrl: attributionUrl.present
        ? attributionUrl.value
        : this.attributionUrl,
    averageRating: averageRating.present
        ? averageRating.value
        : this.averageRating,
    ratingCount: ratingCount.present ? ratingCount.value : this.ratingCount,
    itemsUrl: itemsUrl.present ? itemsUrl.value : this.itemsUrl,
    resourceUrl: resourceUrl.present ? resourceUrl.value : this.resourceUrl,
    modified: modified.present ? modified.value : this.modified,
    isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
  );
  MetronReadingList copyWithCompanion(MetronReadingListsCompanion data) {
    return MetronReadingList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      slug: data.slug.present ? data.slug.value : this.slug,
      userId: data.userId.present ? data.userId.value : this.userId,
      description: data.description.present
          ? data.description.value
          : this.description,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      listType: data.listType.present ? data.listType.value : this.listType,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
      attributionSource: data.attributionSource.present
          ? data.attributionSource.value
          : this.attributionSource,
      attributionUrl: data.attributionUrl.present
          ? data.attributionUrl.value
          : this.attributionUrl,
      averageRating: data.averageRating.present
          ? data.averageRating.value
          : this.averageRating,
      ratingCount: data.ratingCount.present
          ? data.ratingCount.value
          : this.ratingCount,
      itemsUrl: data.itemsUrl.present ? data.itemsUrl.value : this.itemsUrl,
      resourceUrl: data.resourceUrl.present
          ? data.resourceUrl.value
          : this.resourceUrl,
      modified: data.modified.present ? data.modified.value : this.modified,
      isFullyHydrated: data.isFullyHydrated.present
          ? data.isFullyHydrated.value
          : this.isFullyHydrated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronReadingList(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('userId: $userId, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('listType: $listType, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('attributionSource: $attributionSource, ')
          ..write('attributionUrl: $attributionUrl, ')
          ..write('averageRating: $averageRating, ')
          ..write('ratingCount: $ratingCount, ')
          ..write('itemsUrl: $itemsUrl, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    slug,
    userId,
    description,
    imageUrl,
    listType,
    isPrivate,
    attributionSource,
    attributionUrl,
    averageRating,
    ratingCount,
    itemsUrl,
    resourceUrl,
    modified,
    isFullyHydrated,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronReadingList &&
          other.id == this.id &&
          other.name == this.name &&
          other.slug == this.slug &&
          other.userId == this.userId &&
          other.description == this.description &&
          other.imageUrl == this.imageUrl &&
          other.listType == this.listType &&
          other.isPrivate == this.isPrivate &&
          other.attributionSource == this.attributionSource &&
          other.attributionUrl == this.attributionUrl &&
          other.averageRating == this.averageRating &&
          other.ratingCount == this.ratingCount &&
          other.itemsUrl == this.itemsUrl &&
          other.resourceUrl == this.resourceUrl &&
          other.modified == this.modified &&
          other.isFullyHydrated == this.isFullyHydrated);
}

class MetronReadingListsCompanion extends UpdateCompanion<MetronReadingList> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> slug;
  final Value<int?> userId;
  final Value<String?> description;
  final Value<String?> imageUrl;
  final Value<String?> listType;
  final Value<bool?> isPrivate;
  final Value<String?> attributionSource;
  final Value<String?> attributionUrl;
  final Value<double?> averageRating;
  final Value<int?> ratingCount;
  final Value<String?> itemsUrl;
  final Value<String?> resourceUrl;
  final Value<String?> modified;
  final Value<bool> isFullyHydrated;
  const MetronReadingListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.slug = const Value.absent(),
    this.userId = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.listType = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.attributionSource = const Value.absent(),
    this.attributionUrl = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.ratingCount = const Value.absent(),
    this.itemsUrl = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  });
  MetronReadingListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.slug = const Value.absent(),
    this.userId = const Value.absent(),
    this.description = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.listType = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.attributionSource = const Value.absent(),
    this.attributionUrl = const Value.absent(),
    this.averageRating = const Value.absent(),
    this.ratingCount = const Value.absent(),
    this.itemsUrl = const Value.absent(),
    this.resourceUrl = const Value.absent(),
    this.modified = const Value.absent(),
    this.isFullyHydrated = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MetronReadingList> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? slug,
    Expression<int>? userId,
    Expression<String>? description,
    Expression<String>? imageUrl,
    Expression<String>? listType,
    Expression<bool>? isPrivate,
    Expression<String>? attributionSource,
    Expression<String>? attributionUrl,
    Expression<double>? averageRating,
    Expression<int>? ratingCount,
    Expression<String>? itemsUrl,
    Expression<String>? resourceUrl,
    Expression<String>? modified,
    Expression<bool>? isFullyHydrated,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (slug != null) 'slug': slug,
      if (userId != null) 'user_id': userId,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
      if (listType != null) 'list_type': listType,
      if (isPrivate != null) 'is_private': isPrivate,
      if (attributionSource != null) 'attribution_source': attributionSource,
      if (attributionUrl != null) 'attribution_url': attributionUrl,
      if (averageRating != null) 'average_rating': averageRating,
      if (ratingCount != null) 'rating_count': ratingCount,
      if (itemsUrl != null) 'items_url': itemsUrl,
      if (resourceUrl != null) 'resource_url': resourceUrl,
      if (modified != null) 'modified': modified,
      if (isFullyHydrated != null) 'is_fully_hydrated': isFullyHydrated,
    });
  }

  MetronReadingListsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? slug,
    Value<int?>? userId,
    Value<String?>? description,
    Value<String?>? imageUrl,
    Value<String?>? listType,
    Value<bool?>? isPrivate,
    Value<String?>? attributionSource,
    Value<String?>? attributionUrl,
    Value<double?>? averageRating,
    Value<int?>? ratingCount,
    Value<String?>? itemsUrl,
    Value<String?>? resourceUrl,
    Value<String?>? modified,
    Value<bool>? isFullyHydrated,
  }) {
    return MetronReadingListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      listType: listType ?? this.listType,
      isPrivate: isPrivate ?? this.isPrivate,
      attributionSource: attributionSource ?? this.attributionSource,
      attributionUrl: attributionUrl ?? this.attributionUrl,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      itemsUrl: itemsUrl ?? this.itemsUrl,
      resourceUrl: resourceUrl ?? this.resourceUrl,
      modified: modified ?? this.modified,
      isFullyHydrated: isFullyHydrated ?? this.isFullyHydrated,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (listType.present) {
      map['list_type'] = Variable<String>(listType.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (attributionSource.present) {
      map['attribution_source'] = Variable<String>(attributionSource.value);
    }
    if (attributionUrl.present) {
      map['attribution_url'] = Variable<String>(attributionUrl.value);
    }
    if (averageRating.present) {
      map['average_rating'] = Variable<double>(averageRating.value);
    }
    if (ratingCount.present) {
      map['rating_count'] = Variable<int>(ratingCount.value);
    }
    if (itemsUrl.present) {
      map['items_url'] = Variable<String>(itemsUrl.value);
    }
    if (resourceUrl.present) {
      map['resource_url'] = Variable<String>(resourceUrl.value);
    }
    if (modified.present) {
      map['modified'] = Variable<String>(modified.value);
    }
    if (isFullyHydrated.present) {
      map['is_fully_hydrated'] = Variable<bool>(isFullyHydrated.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronReadingListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('slug: $slug, ')
          ..write('userId: $userId, ')
          ..write('description: $description, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('listType: $listType, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('attributionSource: $attributionSource, ')
          ..write('attributionUrl: $attributionUrl, ')
          ..write('averageRating: $averageRating, ')
          ..write('ratingCount: $ratingCount, ')
          ..write('itemsUrl: $itemsUrl, ')
          ..write('resourceUrl: $resourceUrl, ')
          ..write('modified: $modified, ')
          ..write('isFullyHydrated: $isFullyHydrated')
          ..write(')'))
        .toString();
  }
}

class $IssueCreatorsTable extends IssueCreators
    with TableInfo<$IssueCreatorsTable, IssueCreator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueCreatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [issueId, creatorId, role, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_creators';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueCreator> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {issueId, creatorId};
  @override
  IssueCreator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueCreator(
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $IssueCreatorsTable createAlias(String alias) {
    return $IssueCreatorsTable(attachedDatabase, alias);
  }
}

class IssueCreator extends DataClass implements Insertable<IssueCreator> {
  final int issueId;
  final int creatorId;
  final String? role;
  final int? sortOrder;
  const IssueCreator({
    required this.issueId,
    required this.creatorId,
    this.role,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['issue_id'] = Variable<int>(issueId);
    map['creator_id'] = Variable<int>(creatorId);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  IssueCreatorsCompanion toCompanion(bool nullToAbsent) {
    return IssueCreatorsCompanion(
      issueId: Value(issueId),
      creatorId: Value(creatorId),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory IssueCreator.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueCreator(
      issueId: serializer.fromJson<int>(json['issueId']),
      creatorId: serializer.fromJson<int>(json['creatorId']),
      role: serializer.fromJson<String?>(json['role']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'issueId': serializer.toJson<int>(issueId),
      'creatorId': serializer.toJson<int>(creatorId),
      'role': serializer.toJson<String?>(role),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  IssueCreator copyWith({
    int? issueId,
    int? creatorId,
    Value<String?> role = const Value.absent(),
    Value<int?> sortOrder = const Value.absent(),
  }) => IssueCreator(
    issueId: issueId ?? this.issueId,
    creatorId: creatorId ?? this.creatorId,
    role: role.present ? role.value : this.role,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  IssueCreator copyWithCompanion(IssueCreatorsCompanion data) {
    return IssueCreator(
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      role: data.role.present ? data.role.value : this.role,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueCreator(')
          ..write('issueId: $issueId, ')
          ..write('creatorId: $creatorId, ')
          ..write('role: $role, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(issueId, creatorId, role, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueCreator &&
          other.issueId == this.issueId &&
          other.creatorId == this.creatorId &&
          other.role == this.role &&
          other.sortOrder == this.sortOrder);
}

class IssueCreatorsCompanion extends UpdateCompanion<IssueCreator> {
  final Value<int> issueId;
  final Value<int> creatorId;
  final Value<String?> role;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const IssueCreatorsCompanion({
    this.issueId = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.role = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueCreatorsCompanion.insert({
    required int issueId,
    required int creatorId,
    this.role = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : issueId = Value(issueId),
       creatorId = Value(creatorId);
  static Insertable<IssueCreator> custom({
    Expression<int>? issueId,
    Expression<int>? creatorId,
    Expression<String>? role,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (issueId != null) 'issue_id': issueId,
      if (creatorId != null) 'creator_id': creatorId,
      if (role != null) 'role': role,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueCreatorsCompanion copyWith({
    Value<int>? issueId,
    Value<int>? creatorId,
    Value<String?>? role,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return IssueCreatorsCompanion(
      issueId: issueId ?? this.issueId,
      creatorId: creatorId ?? this.creatorId,
      role: role ?? this.role,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueCreatorsCompanion(')
          ..write('issueId: $issueId, ')
          ..write('creatorId: $creatorId, ')
          ..write('role: $role, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueCharactersTable extends IssueCharacters
    with TableInfo<$IssueCharactersTable, IssueCharacter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueCharactersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [issueId, characterId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_characters';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueCharacter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {issueId, characterId};
  @override
  IssueCharacter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueCharacter(
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      )!,
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $IssueCharactersTable createAlias(String alias) {
    return $IssueCharactersTable(attachedDatabase, alias);
  }
}

class IssueCharacter extends DataClass implements Insertable<IssueCharacter> {
  final int issueId;
  final int characterId;
  final int? sortOrder;
  const IssueCharacter({
    required this.issueId,
    required this.characterId,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['issue_id'] = Variable<int>(issueId);
    map['character_id'] = Variable<int>(characterId);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  IssueCharactersCompanion toCompanion(bool nullToAbsent) {
    return IssueCharactersCompanion(
      issueId: Value(issueId),
      characterId: Value(characterId),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory IssueCharacter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueCharacter(
      issueId: serializer.fromJson<int>(json['issueId']),
      characterId: serializer.fromJson<int>(json['characterId']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'issueId': serializer.toJson<int>(issueId),
      'characterId': serializer.toJson<int>(characterId),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  IssueCharacter copyWith({
    int? issueId,
    int? characterId,
    Value<int?> sortOrder = const Value.absent(),
  }) => IssueCharacter(
    issueId: issueId ?? this.issueId,
    characterId: characterId ?? this.characterId,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  IssueCharacter copyWithCompanion(IssueCharactersCompanion data) {
    return IssueCharacter(
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueCharacter(')
          ..write('issueId: $issueId, ')
          ..write('characterId: $characterId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(issueId, characterId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueCharacter &&
          other.issueId == this.issueId &&
          other.characterId == this.characterId &&
          other.sortOrder == this.sortOrder);
}

class IssueCharactersCompanion extends UpdateCompanion<IssueCharacter> {
  final Value<int> issueId;
  final Value<int> characterId;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const IssueCharactersCompanion({
    this.issueId = const Value.absent(),
    this.characterId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueCharactersCompanion.insert({
    required int issueId,
    required int characterId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : issueId = Value(issueId),
       characterId = Value(characterId);
  static Insertable<IssueCharacter> custom({
    Expression<int>? issueId,
    Expression<int>? characterId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (issueId != null) 'issue_id': issueId,
      if (characterId != null) 'character_id': characterId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueCharactersCompanion copyWith({
    Value<int>? issueId,
    Value<int>? characterId,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return IssueCharactersCompanion(
      issueId: issueId ?? this.issueId,
      characterId: characterId ?? this.characterId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueCharactersCompanion(')
          ..write('issueId: $issueId, ')
          ..write('characterId: $characterId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueArcsTable extends IssueArcs
    with TableInfo<$IssueArcsTable, IssueArc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueArcsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arcIdMeta = const VerificationMeta('arcId');
  @override
  late final GeneratedColumn<int> arcId = GeneratedColumn<int>(
    'arc_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [issueId, arcId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_arcs';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueArc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('arc_id')) {
      context.handle(
        _arcIdMeta,
        arcId.isAcceptableOrUnknown(data['arc_id']!, _arcIdMeta),
      );
    } else if (isInserting) {
      context.missing(_arcIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {issueId, arcId};
  @override
  IssueArc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueArc(
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      )!,
      arcId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arc_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $IssueArcsTable createAlias(String alias) {
    return $IssueArcsTable(attachedDatabase, alias);
  }
}

class IssueArc extends DataClass implements Insertable<IssueArc> {
  final int issueId;
  final int arcId;
  final int? sortOrder;
  const IssueArc({required this.issueId, required this.arcId, this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['issue_id'] = Variable<int>(issueId);
    map['arc_id'] = Variable<int>(arcId);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  IssueArcsCompanion toCompanion(bool nullToAbsent) {
    return IssueArcsCompanion(
      issueId: Value(issueId),
      arcId: Value(arcId),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory IssueArc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueArc(
      issueId: serializer.fromJson<int>(json['issueId']),
      arcId: serializer.fromJson<int>(json['arcId']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'issueId': serializer.toJson<int>(issueId),
      'arcId': serializer.toJson<int>(arcId),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  IssueArc copyWith({
    int? issueId,
    int? arcId,
    Value<int?> sortOrder = const Value.absent(),
  }) => IssueArc(
    issueId: issueId ?? this.issueId,
    arcId: arcId ?? this.arcId,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  IssueArc copyWithCompanion(IssueArcsCompanion data) {
    return IssueArc(
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      arcId: data.arcId.present ? data.arcId.value : this.arcId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueArc(')
          ..write('issueId: $issueId, ')
          ..write('arcId: $arcId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(issueId, arcId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueArc &&
          other.issueId == this.issueId &&
          other.arcId == this.arcId &&
          other.sortOrder == this.sortOrder);
}

class IssueArcsCompanion extends UpdateCompanion<IssueArc> {
  final Value<int> issueId;
  final Value<int> arcId;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const IssueArcsCompanion({
    this.issueId = const Value.absent(),
    this.arcId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueArcsCompanion.insert({
    required int issueId,
    required int arcId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : issueId = Value(issueId),
       arcId = Value(arcId);
  static Insertable<IssueArc> custom({
    Expression<int>? issueId,
    Expression<int>? arcId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (issueId != null) 'issue_id': issueId,
      if (arcId != null) 'arc_id': arcId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueArcsCompanion copyWith({
    Value<int>? issueId,
    Value<int>? arcId,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return IssueArcsCompanion(
      issueId: issueId ?? this.issueId,
      arcId: arcId ?? this.arcId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (arcId.present) {
      map['arc_id'] = Variable<int>(arcId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueArcsCompanion(')
          ..write('issueId: $issueId, ')
          ..write('arcId: $arcId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueTeamsTable extends IssueTeams
    with TableInfo<$IssueTeamsTable, IssueTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [issueId, teamId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {issueId, teamId};
  @override
  IssueTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueTeam(
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $IssueTeamsTable createAlias(String alias) {
    return $IssueTeamsTable(attachedDatabase, alias);
  }
}

class IssueTeam extends DataClass implements Insertable<IssueTeam> {
  final int issueId;
  final int teamId;
  final int? sortOrder;
  const IssueTeam({
    required this.issueId,
    required this.teamId,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['issue_id'] = Variable<int>(issueId);
    map['team_id'] = Variable<int>(teamId);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  IssueTeamsCompanion toCompanion(bool nullToAbsent) {
    return IssueTeamsCompanion(
      issueId: Value(issueId),
      teamId: Value(teamId),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory IssueTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueTeam(
      issueId: serializer.fromJson<int>(json['issueId']),
      teamId: serializer.fromJson<int>(json['teamId']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'issueId': serializer.toJson<int>(issueId),
      'teamId': serializer.toJson<int>(teamId),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  IssueTeam copyWith({
    int? issueId,
    int? teamId,
    Value<int?> sortOrder = const Value.absent(),
  }) => IssueTeam(
    issueId: issueId ?? this.issueId,
    teamId: teamId ?? this.teamId,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  IssueTeam copyWithCompanion(IssueTeamsCompanion data) {
    return IssueTeam(
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueTeam(')
          ..write('issueId: $issueId, ')
          ..write('teamId: $teamId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(issueId, teamId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueTeam &&
          other.issueId == this.issueId &&
          other.teamId == this.teamId &&
          other.sortOrder == this.sortOrder);
}

class IssueTeamsCompanion extends UpdateCompanion<IssueTeam> {
  final Value<int> issueId;
  final Value<int> teamId;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const IssueTeamsCompanion({
    this.issueId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueTeamsCompanion.insert({
    required int issueId,
    required int teamId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : issueId = Value(issueId),
       teamId = Value(teamId);
  static Insertable<IssueTeam> custom({
    Expression<int>? issueId,
    Expression<int>? teamId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (issueId != null) 'issue_id': issueId,
      if (teamId != null) 'team_id': teamId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueTeamsCompanion copyWith({
    Value<int>? issueId,
    Value<int>? teamId,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return IssueTeamsCompanion(
      issueId: issueId ?? this.issueId,
      teamId: teamId ?? this.teamId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueTeamsCompanion(')
          ..write('issueId: $issueId, ')
          ..write('teamId: $teamId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueUniversesTable extends IssueUniverses
    with TableInfo<$IssueUniversesTable, IssueUniverse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueUniversesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universeIdMeta = const VerificationMeta(
    'universeId',
  );
  @override
  late final GeneratedColumn<int> universeId = GeneratedColumn<int>(
    'universe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [issueId, universeId, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_universes';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueUniverse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('universe_id')) {
      context.handle(
        _universeIdMeta,
        universeId.isAcceptableOrUnknown(data['universe_id']!, _universeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_universeIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {issueId, universeId};
  @override
  IssueUniverse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueUniverse(
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      )!,
      universeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}universe_id'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      ),
    );
  }

  @override
  $IssueUniversesTable createAlias(String alias) {
    return $IssueUniversesTable(attachedDatabase, alias);
  }
}

class IssueUniverse extends DataClass implements Insertable<IssueUniverse> {
  final int issueId;
  final int universeId;
  final int? sortOrder;
  const IssueUniverse({
    required this.issueId,
    required this.universeId,
    this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['issue_id'] = Variable<int>(issueId);
    map['universe_id'] = Variable<int>(universeId);
    if (!nullToAbsent || sortOrder != null) {
      map['sort_order'] = Variable<int>(sortOrder);
    }
    return map;
  }

  IssueUniversesCompanion toCompanion(bool nullToAbsent) {
    return IssueUniversesCompanion(
      issueId: Value(issueId),
      universeId: Value(universeId),
      sortOrder: sortOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(sortOrder),
    );
  }

  factory IssueUniverse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueUniverse(
      issueId: serializer.fromJson<int>(json['issueId']),
      universeId: serializer.fromJson<int>(json['universeId']),
      sortOrder: serializer.fromJson<int?>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'issueId': serializer.toJson<int>(issueId),
      'universeId': serializer.toJson<int>(universeId),
      'sortOrder': serializer.toJson<int?>(sortOrder),
    };
  }

  IssueUniverse copyWith({
    int? issueId,
    int? universeId,
    Value<int?> sortOrder = const Value.absent(),
  }) => IssueUniverse(
    issueId: issueId ?? this.issueId,
    universeId: universeId ?? this.universeId,
    sortOrder: sortOrder.present ? sortOrder.value : this.sortOrder,
  );
  IssueUniverse copyWithCompanion(IssueUniversesCompanion data) {
    return IssueUniverse(
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      universeId: data.universeId.present
          ? data.universeId.value
          : this.universeId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueUniverse(')
          ..write('issueId: $issueId, ')
          ..write('universeId: $universeId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(issueId, universeId, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueUniverse &&
          other.issueId == this.issueId &&
          other.universeId == this.universeId &&
          other.sortOrder == this.sortOrder);
}

class IssueUniversesCompanion extends UpdateCompanion<IssueUniverse> {
  final Value<int> issueId;
  final Value<int> universeId;
  final Value<int?> sortOrder;
  final Value<int> rowid;
  const IssueUniversesCompanion({
    this.issueId = const Value.absent(),
    this.universeId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueUniversesCompanion.insert({
    required int issueId,
    required int universeId,
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : issueId = Value(issueId),
       universeId = Value(universeId);
  static Insertable<IssueUniverse> custom({
    Expression<int>? issueId,
    Expression<int>? universeId,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (issueId != null) 'issue_id': issueId,
      if (universeId != null) 'universe_id': universeId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueUniversesCompanion copyWith({
    Value<int>? issueId,
    Value<int>? universeId,
    Value<int?>? sortOrder,
    Value<int>? rowid,
  }) {
    return IssueUniversesCompanion(
      issueId: issueId ?? this.issueId,
      universeId: universeId ?? this.universeId,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (universeId.present) {
      map['universe_id'] = Variable<int>(universeId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueUniversesCompanion(')
          ..write('issueId: $issueId, ')
          ..write('universeId: $universeId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IssueImprintsTable extends IssueImprints
    with TableInfo<$IssueImprintsTable, IssueImprint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IssueImprintsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _issueIdMeta = const VerificationMeta(
    'issueId',
  );
  @override
  late final GeneratedColumn<int> issueId = GeneratedColumn<int>(
    'issue_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imprintIdMeta = const VerificationMeta(
    'imprintId',
  );
  @override
  late final GeneratedColumn<int> imprintId = GeneratedColumn<int>(
    'imprint_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [issueId, imprintId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'issue_imprints';
  @override
  VerificationContext validateIntegrity(
    Insertable<IssueImprint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('issue_id')) {
      context.handle(
        _issueIdMeta,
        issueId.isAcceptableOrUnknown(data['issue_id']!, _issueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIdMeta);
    }
    if (data.containsKey('imprint_id')) {
      context.handle(
        _imprintIdMeta,
        imprintId.isAcceptableOrUnknown(data['imprint_id']!, _imprintIdMeta),
      );
    } else if (isInserting) {
      context.missing(_imprintIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {issueId, imprintId};
  @override
  IssueImprint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IssueImprint(
      issueId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_id'],
      )!,
      imprintId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imprint_id'],
      )!,
    );
  }

  @override
  $IssueImprintsTable createAlias(String alias) {
    return $IssueImprintsTable(attachedDatabase, alias);
  }
}

class IssueImprint extends DataClass implements Insertable<IssueImprint> {
  final int issueId;
  final int imprintId;
  const IssueImprint({required this.issueId, required this.imprintId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['issue_id'] = Variable<int>(issueId);
    map['imprint_id'] = Variable<int>(imprintId);
    return map;
  }

  IssueImprintsCompanion toCompanion(bool nullToAbsent) {
    return IssueImprintsCompanion(
      issueId: Value(issueId),
      imprintId: Value(imprintId),
    );
  }

  factory IssueImprint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IssueImprint(
      issueId: serializer.fromJson<int>(json['issueId']),
      imprintId: serializer.fromJson<int>(json['imprintId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'issueId': serializer.toJson<int>(issueId),
      'imprintId': serializer.toJson<int>(imprintId),
    };
  }

  IssueImprint copyWith({int? issueId, int? imprintId}) => IssueImprint(
    issueId: issueId ?? this.issueId,
    imprintId: imprintId ?? this.imprintId,
  );
  IssueImprint copyWithCompanion(IssueImprintsCompanion data) {
    return IssueImprint(
      issueId: data.issueId.present ? data.issueId.value : this.issueId,
      imprintId: data.imprintId.present ? data.imprintId.value : this.imprintId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IssueImprint(')
          ..write('issueId: $issueId, ')
          ..write('imprintId: $imprintId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(issueId, imprintId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IssueImprint &&
          other.issueId == this.issueId &&
          other.imprintId == this.imprintId);
}

class IssueImprintsCompanion extends UpdateCompanion<IssueImprint> {
  final Value<int> issueId;
  final Value<int> imprintId;
  final Value<int> rowid;
  const IssueImprintsCompanion({
    this.issueId = const Value.absent(),
    this.imprintId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IssueImprintsCompanion.insert({
    required int issueId,
    required int imprintId,
    this.rowid = const Value.absent(),
  }) : issueId = Value(issueId),
       imprintId = Value(imprintId);
  static Insertable<IssueImprint> custom({
    Expression<int>? issueId,
    Expression<int>? imprintId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (issueId != null) 'issue_id': issueId,
      if (imprintId != null) 'imprint_id': imprintId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IssueImprintsCompanion copyWith({
    Value<int>? issueId,
    Value<int>? imprintId,
    Value<int>? rowid,
  }) {
    return IssueImprintsCompanion(
      issueId: issueId ?? this.issueId,
      imprintId: imprintId ?? this.imprintId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (issueId.present) {
      map['issue_id'] = Variable<int>(issueId.value);
    }
    if (imprintId.present) {
      map['imprint_id'] = Variable<int>(imprintId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IssueImprintsCompanion(')
          ..write('issueId: $issueId, ')
          ..write('imprintId: $imprintId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesArcsTable extends SeriesArcs
    with TableInfo<$SeriesArcsTable, SeriesArc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesArcsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arcIdMeta = const VerificationMeta('arcId');
  @override
  late final GeneratedColumn<int> arcId = GeneratedColumn<int>(
    'arc_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, arcId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_arcs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesArc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('arc_id')) {
      context.handle(
        _arcIdMeta,
        arcId.isAcceptableOrUnknown(data['arc_id']!, _arcIdMeta),
      );
    } else if (isInserting) {
      context.missing(_arcIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, arcId};
  @override
  SeriesArc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesArc(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      arcId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arc_id'],
      )!,
    );
  }

  @override
  $SeriesArcsTable createAlias(String alias) {
    return $SeriesArcsTable(attachedDatabase, alias);
  }
}

class SeriesArc extends DataClass implements Insertable<SeriesArc> {
  final int seriesId;
  final int arcId;
  const SeriesArc({required this.seriesId, required this.arcId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<int>(seriesId);
    map['arc_id'] = Variable<int>(arcId);
    return map;
  }

  SeriesArcsCompanion toCompanion(bool nullToAbsent) {
    return SeriesArcsCompanion(seriesId: Value(seriesId), arcId: Value(arcId));
  }

  factory SeriesArc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesArc(
      seriesId: serializer.fromJson<int>(json['seriesId']),
      arcId: serializer.fromJson<int>(json['arcId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<int>(seriesId),
      'arcId': serializer.toJson<int>(arcId),
    };
  }

  SeriesArc copyWith({int? seriesId, int? arcId}) => SeriesArc(
    seriesId: seriesId ?? this.seriesId,
    arcId: arcId ?? this.arcId,
  );
  SeriesArc copyWithCompanion(SeriesArcsCompanion data) {
    return SeriesArc(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      arcId: data.arcId.present ? data.arcId.value : this.arcId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesArc(')
          ..write('seriesId: $seriesId, ')
          ..write('arcId: $arcId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, arcId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesArc &&
          other.seriesId == this.seriesId &&
          other.arcId == this.arcId);
}

class SeriesArcsCompanion extends UpdateCompanion<SeriesArc> {
  final Value<int> seriesId;
  final Value<int> arcId;
  final Value<int> rowid;
  const SeriesArcsCompanion({
    this.seriesId = const Value.absent(),
    this.arcId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesArcsCompanion.insert({
    required int seriesId,
    required int arcId,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       arcId = Value(arcId);
  static Insertable<SeriesArc> custom({
    Expression<int>? seriesId,
    Expression<int>? arcId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (arcId != null) 'arc_id': arcId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesArcsCompanion copyWith({
    Value<int>? seriesId,
    Value<int>? arcId,
    Value<int>? rowid,
  }) {
    return SeriesArcsCompanion(
      seriesId: seriesId ?? this.seriesId,
      arcId: arcId ?? this.arcId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (arcId.present) {
      map['arc_id'] = Variable<int>(arcId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesArcsCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('arcId: $arcId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesTeamsTable extends SeriesTeams
    with TableInfo<$SeriesTeamsTable, SeriesTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, teamId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, teamId};
  @override
  SeriesTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesTeam(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
    );
  }

  @override
  $SeriesTeamsTable createAlias(String alias) {
    return $SeriesTeamsTable(attachedDatabase, alias);
  }
}

class SeriesTeam extends DataClass implements Insertable<SeriesTeam> {
  final int seriesId;
  final int teamId;
  const SeriesTeam({required this.seriesId, required this.teamId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<int>(seriesId);
    map['team_id'] = Variable<int>(teamId);
    return map;
  }

  SeriesTeamsCompanion toCompanion(bool nullToAbsent) {
    return SeriesTeamsCompanion(
      seriesId: Value(seriesId),
      teamId: Value(teamId),
    );
  }

  factory SeriesTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesTeam(
      seriesId: serializer.fromJson<int>(json['seriesId']),
      teamId: serializer.fromJson<int>(json['teamId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<int>(seriesId),
      'teamId': serializer.toJson<int>(teamId),
    };
  }

  SeriesTeam copyWith({int? seriesId, int? teamId}) => SeriesTeam(
    seriesId: seriesId ?? this.seriesId,
    teamId: teamId ?? this.teamId,
  );
  SeriesTeam copyWithCompanion(SeriesTeamsCompanion data) {
    return SeriesTeam(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTeam(')
          ..write('seriesId: $seriesId, ')
          ..write('teamId: $teamId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, teamId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesTeam &&
          other.seriesId == this.seriesId &&
          other.teamId == this.teamId);
}

class SeriesTeamsCompanion extends UpdateCompanion<SeriesTeam> {
  final Value<int> seriesId;
  final Value<int> teamId;
  final Value<int> rowid;
  const SeriesTeamsCompanion({
    this.seriesId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesTeamsCompanion.insert({
    required int seriesId,
    required int teamId,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       teamId = Value(teamId);
  static Insertable<SeriesTeam> custom({
    Expression<int>? seriesId,
    Expression<int>? teamId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (teamId != null) 'team_id': teamId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesTeamsCompanion copyWith({
    Value<int>? seriesId,
    Value<int>? teamId,
    Value<int>? rowid,
  }) {
    return SeriesTeamsCompanion(
      seriesId: seriesId ?? this.seriesId,
      teamId: teamId ?? this.teamId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesTeamsCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('teamId: $teamId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesUniversesTable extends SeriesUniverses
    with TableInfo<$SeriesUniversesTable, SeriesUniverse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesUniversesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universeIdMeta = const VerificationMeta(
    'universeId',
  );
  @override
  late final GeneratedColumn<int> universeId = GeneratedColumn<int>(
    'universe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, universeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_universes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesUniverse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('universe_id')) {
      context.handle(
        _universeIdMeta,
        universeId.isAcceptableOrUnknown(data['universe_id']!, _universeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_universeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, universeId};
  @override
  SeriesUniverse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesUniverse(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      universeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}universe_id'],
      )!,
    );
  }

  @override
  $SeriesUniversesTable createAlias(String alias) {
    return $SeriesUniversesTable(attachedDatabase, alias);
  }
}

class SeriesUniverse extends DataClass implements Insertable<SeriesUniverse> {
  final int seriesId;
  final int universeId;
  const SeriesUniverse({required this.seriesId, required this.universeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<int>(seriesId);
    map['universe_id'] = Variable<int>(universeId);
    return map;
  }

  SeriesUniversesCompanion toCompanion(bool nullToAbsent) {
    return SeriesUniversesCompanion(
      seriesId: Value(seriesId),
      universeId: Value(universeId),
    );
  }

  factory SeriesUniverse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesUniverse(
      seriesId: serializer.fromJson<int>(json['seriesId']),
      universeId: serializer.fromJson<int>(json['universeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<int>(seriesId),
      'universeId': serializer.toJson<int>(universeId),
    };
  }

  SeriesUniverse copyWith({int? seriesId, int? universeId}) => SeriesUniverse(
    seriesId: seriesId ?? this.seriesId,
    universeId: universeId ?? this.universeId,
  );
  SeriesUniverse copyWithCompanion(SeriesUniversesCompanion data) {
    return SeriesUniverse(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      universeId: data.universeId.present
          ? data.universeId.value
          : this.universeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesUniverse(')
          ..write('seriesId: $seriesId, ')
          ..write('universeId: $universeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, universeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesUniverse &&
          other.seriesId == this.seriesId &&
          other.universeId == this.universeId);
}

class SeriesUniversesCompanion extends UpdateCompanion<SeriesUniverse> {
  final Value<int> seriesId;
  final Value<int> universeId;
  final Value<int> rowid;
  const SeriesUniversesCompanion({
    this.seriesId = const Value.absent(),
    this.universeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesUniversesCompanion.insert({
    required int seriesId,
    required int universeId,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       universeId = Value(universeId);
  static Insertable<SeriesUniverse> custom({
    Expression<int>? seriesId,
    Expression<int>? universeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (universeId != null) 'universe_id': universeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesUniversesCompanion copyWith({
    Value<int>? seriesId,
    Value<int>? universeId,
    Value<int>? rowid,
  }) {
    return SeriesUniversesCompanion(
      seriesId: seriesId ?? this.seriesId,
      universeId: universeId ?? this.universeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (universeId.present) {
      map['universe_id'] = Variable<int>(universeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesUniversesCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('universeId: $universeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssociatedSeriesTable extends AssociatedSeries
    with TableInfo<$AssociatedSeriesTable, AssociatedSery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssociatedSeriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _associatedSeriesIdMeta =
      const VerificationMeta('associatedSeriesId');
  @override
  late final GeneratedColumn<int> associatedSeriesId = GeneratedColumn<int>(
    'associated_series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, associatedSeriesId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'associated_series';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssociatedSery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('associated_series_id')) {
      context.handle(
        _associatedSeriesIdMeta,
        associatedSeriesId.isAcceptableOrUnknown(
          data['associated_series_id']!,
          _associatedSeriesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_associatedSeriesIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, associatedSeriesId};
  @override
  AssociatedSery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssociatedSery(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      associatedSeriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}associated_series_id'],
      )!,
    );
  }

  @override
  $AssociatedSeriesTable createAlias(String alias) {
    return $AssociatedSeriesTable(attachedDatabase, alias);
  }
}

class AssociatedSery extends DataClass implements Insertable<AssociatedSery> {
  final int seriesId;
  final int associatedSeriesId;
  const AssociatedSery({
    required this.seriesId,
    required this.associatedSeriesId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<int>(seriesId);
    map['associated_series_id'] = Variable<int>(associatedSeriesId);
    return map;
  }

  AssociatedSeriesCompanion toCompanion(bool nullToAbsent) {
    return AssociatedSeriesCompanion(
      seriesId: Value(seriesId),
      associatedSeriesId: Value(associatedSeriesId),
    );
  }

  factory AssociatedSery.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssociatedSery(
      seriesId: serializer.fromJson<int>(json['seriesId']),
      associatedSeriesId: serializer.fromJson<int>(json['associatedSeriesId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<int>(seriesId),
      'associatedSeriesId': serializer.toJson<int>(associatedSeriesId),
    };
  }

  AssociatedSery copyWith({int? seriesId, int? associatedSeriesId}) =>
      AssociatedSery(
        seriesId: seriesId ?? this.seriesId,
        associatedSeriesId: associatedSeriesId ?? this.associatedSeriesId,
      );
  AssociatedSery copyWithCompanion(AssociatedSeriesCompanion data) {
    return AssociatedSery(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      associatedSeriesId: data.associatedSeriesId.present
          ? data.associatedSeriesId.value
          : this.associatedSeriesId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedSery(')
          ..write('seriesId: $seriesId, ')
          ..write('associatedSeriesId: $associatedSeriesId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, associatedSeriesId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssociatedSery &&
          other.seriesId == this.seriesId &&
          other.associatedSeriesId == this.associatedSeriesId);
}

class AssociatedSeriesCompanion extends UpdateCompanion<AssociatedSery> {
  final Value<int> seriesId;
  final Value<int> associatedSeriesId;
  final Value<int> rowid;
  const AssociatedSeriesCompanion({
    this.seriesId = const Value.absent(),
    this.associatedSeriesId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssociatedSeriesCompanion.insert({
    required int seriesId,
    required int associatedSeriesId,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       associatedSeriesId = Value(associatedSeriesId);
  static Insertable<AssociatedSery> custom({
    Expression<int>? seriesId,
    Expression<int>? associatedSeriesId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (associatedSeriesId != null)
        'associated_series_id': associatedSeriesId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssociatedSeriesCompanion copyWith({
    Value<int>? seriesId,
    Value<int>? associatedSeriesId,
    Value<int>? rowid,
  }) {
    return AssociatedSeriesCompanion(
      seriesId: seriesId ?? this.seriesId,
      associatedSeriesId: associatedSeriesId ?? this.associatedSeriesId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (associatedSeriesId.present) {
      map['associated_series_id'] = Variable<int>(associatedSeriesId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssociatedSeriesCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('associatedSeriesId: $associatedSeriesId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterCreatorsTable extends CharacterCreators
    with TableInfo<$CharacterCreatorsTable, CharacterCreator> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterCreatorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [characterId, creatorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_creators';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterCreator> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {characterId, creatorId};
  @override
  CharacterCreator map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterCreator(
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      )!,
    );
  }

  @override
  $CharacterCreatorsTable createAlias(String alias) {
    return $CharacterCreatorsTable(attachedDatabase, alias);
  }
}

class CharacterCreator extends DataClass
    implements Insertable<CharacterCreator> {
  final int characterId;
  final int creatorId;
  const CharacterCreator({required this.characterId, required this.creatorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character_id'] = Variable<int>(characterId);
    map['creator_id'] = Variable<int>(creatorId);
    return map;
  }

  CharacterCreatorsCompanion toCompanion(bool nullToAbsent) {
    return CharacterCreatorsCompanion(
      characterId: Value(characterId),
      creatorId: Value(creatorId),
    );
  }

  factory CharacterCreator.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterCreator(
      characterId: serializer.fromJson<int>(json['characterId']),
      creatorId: serializer.fromJson<int>(json['creatorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'characterId': serializer.toJson<int>(characterId),
      'creatorId': serializer.toJson<int>(creatorId),
    };
  }

  CharacterCreator copyWith({int? characterId, int? creatorId}) =>
      CharacterCreator(
        characterId: characterId ?? this.characterId,
        creatorId: creatorId ?? this.creatorId,
      );
  CharacterCreator copyWithCompanion(CharacterCreatorsCompanion data) {
    return CharacterCreator(
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterCreator(')
          ..write('characterId: $characterId, ')
          ..write('creatorId: $creatorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(characterId, creatorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterCreator &&
          other.characterId == this.characterId &&
          other.creatorId == this.creatorId);
}

class CharacterCreatorsCompanion extends UpdateCompanion<CharacterCreator> {
  final Value<int> characterId;
  final Value<int> creatorId;
  final Value<int> rowid;
  const CharacterCreatorsCompanion({
    this.characterId = const Value.absent(),
    this.creatorId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterCreatorsCompanion.insert({
    required int characterId,
    required int creatorId,
    this.rowid = const Value.absent(),
  }) : characterId = Value(characterId),
       creatorId = Value(creatorId);
  static Insertable<CharacterCreator> custom({
    Expression<int>? characterId,
    Expression<int>? creatorId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (characterId != null) 'character_id': characterId,
      if (creatorId != null) 'creator_id': creatorId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterCreatorsCompanion copyWith({
    Value<int>? characterId,
    Value<int>? creatorId,
    Value<int>? rowid,
  }) {
    return CharacterCreatorsCompanion(
      characterId: characterId ?? this.characterId,
      creatorId: creatorId ?? this.creatorId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterCreatorsCompanion(')
          ..write('characterId: $characterId, ')
          ..write('creatorId: $creatorId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterTeamsTable extends CharacterTeams
    with TableInfo<$CharacterTeamsTable, CharacterTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [characterId, teamId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {characterId, teamId};
  @override
  CharacterTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterTeam(
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
    );
  }

  @override
  $CharacterTeamsTable createAlias(String alias) {
    return $CharacterTeamsTable(attachedDatabase, alias);
  }
}

class CharacterTeam extends DataClass implements Insertable<CharacterTeam> {
  final int characterId;
  final int teamId;
  const CharacterTeam({required this.characterId, required this.teamId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character_id'] = Variable<int>(characterId);
    map['team_id'] = Variable<int>(teamId);
    return map;
  }

  CharacterTeamsCompanion toCompanion(bool nullToAbsent) {
    return CharacterTeamsCompanion(
      characterId: Value(characterId),
      teamId: Value(teamId),
    );
  }

  factory CharacterTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterTeam(
      characterId: serializer.fromJson<int>(json['characterId']),
      teamId: serializer.fromJson<int>(json['teamId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'characterId': serializer.toJson<int>(characterId),
      'teamId': serializer.toJson<int>(teamId),
    };
  }

  CharacterTeam copyWith({int? characterId, int? teamId}) => CharacterTeam(
    characterId: characterId ?? this.characterId,
    teamId: teamId ?? this.teamId,
  );
  CharacterTeam copyWithCompanion(CharacterTeamsCompanion data) {
    return CharacterTeam(
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterTeam(')
          ..write('characterId: $characterId, ')
          ..write('teamId: $teamId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(characterId, teamId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterTeam &&
          other.characterId == this.characterId &&
          other.teamId == this.teamId);
}

class CharacterTeamsCompanion extends UpdateCompanion<CharacterTeam> {
  final Value<int> characterId;
  final Value<int> teamId;
  final Value<int> rowid;
  const CharacterTeamsCompanion({
    this.characterId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterTeamsCompanion.insert({
    required int characterId,
    required int teamId,
    this.rowid = const Value.absent(),
  }) : characterId = Value(characterId),
       teamId = Value(teamId);
  static Insertable<CharacterTeam> custom({
    Expression<int>? characterId,
    Expression<int>? teamId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (characterId != null) 'character_id': characterId,
      if (teamId != null) 'team_id': teamId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterTeamsCompanion copyWith({
    Value<int>? characterId,
    Value<int>? teamId,
    Value<int>? rowid,
  }) {
    return CharacterTeamsCompanion(
      characterId: characterId ?? this.characterId,
      teamId: teamId ?? this.teamId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterTeamsCompanion(')
          ..write('characterId: $characterId, ')
          ..write('teamId: $teamId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CharacterUniversesTable extends CharacterUniverses
    with TableInfo<$CharacterUniversesTable, CharacterUniverse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CharacterUniversesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _characterIdMeta = const VerificationMeta(
    'characterId',
  );
  @override
  late final GeneratedColumn<int> characterId = GeneratedColumn<int>(
    'character_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universeIdMeta = const VerificationMeta(
    'universeId',
  );
  @override
  late final GeneratedColumn<int> universeId = GeneratedColumn<int>(
    'universe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [characterId, universeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'character_universes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CharacterUniverse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('character_id')) {
      context.handle(
        _characterIdMeta,
        characterId.isAcceptableOrUnknown(
          data['character_id']!,
          _characterIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('universe_id')) {
      context.handle(
        _universeIdMeta,
        universeId.isAcceptableOrUnknown(data['universe_id']!, _universeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_universeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {characterId, universeId};
  @override
  CharacterUniverse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CharacterUniverse(
      characterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}character_id'],
      )!,
      universeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}universe_id'],
      )!,
    );
  }

  @override
  $CharacterUniversesTable createAlias(String alias) {
    return $CharacterUniversesTable(attachedDatabase, alias);
  }
}

class CharacterUniverse extends DataClass
    implements Insertable<CharacterUniverse> {
  final int characterId;
  final int universeId;
  const CharacterUniverse({
    required this.characterId,
    required this.universeId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['character_id'] = Variable<int>(characterId);
    map['universe_id'] = Variable<int>(universeId);
    return map;
  }

  CharacterUniversesCompanion toCompanion(bool nullToAbsent) {
    return CharacterUniversesCompanion(
      characterId: Value(characterId),
      universeId: Value(universeId),
    );
  }

  factory CharacterUniverse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CharacterUniverse(
      characterId: serializer.fromJson<int>(json['characterId']),
      universeId: serializer.fromJson<int>(json['universeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'characterId': serializer.toJson<int>(characterId),
      'universeId': serializer.toJson<int>(universeId),
    };
  }

  CharacterUniverse copyWith({int? characterId, int? universeId}) =>
      CharacterUniverse(
        characterId: characterId ?? this.characterId,
        universeId: universeId ?? this.universeId,
      );
  CharacterUniverse copyWithCompanion(CharacterUniversesCompanion data) {
    return CharacterUniverse(
      characterId: data.characterId.present
          ? data.characterId.value
          : this.characterId,
      universeId: data.universeId.present
          ? data.universeId.value
          : this.universeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CharacterUniverse(')
          ..write('characterId: $characterId, ')
          ..write('universeId: $universeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(characterId, universeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CharacterUniverse &&
          other.characterId == this.characterId &&
          other.universeId == this.universeId);
}

class CharacterUniversesCompanion extends UpdateCompanion<CharacterUniverse> {
  final Value<int> characterId;
  final Value<int> universeId;
  final Value<int> rowid;
  const CharacterUniversesCompanion({
    this.characterId = const Value.absent(),
    this.universeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CharacterUniversesCompanion.insert({
    required int characterId,
    required int universeId,
    this.rowid = const Value.absent(),
  }) : characterId = Value(characterId),
       universeId = Value(universeId);
  static Insertable<CharacterUniverse> custom({
    Expression<int>? characterId,
    Expression<int>? universeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (characterId != null) 'character_id': characterId,
      if (universeId != null) 'universe_id': universeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CharacterUniversesCompanion copyWith({
    Value<int>? characterId,
    Value<int>? universeId,
    Value<int>? rowid,
  }) {
    return CharacterUniversesCompanion(
      characterId: characterId ?? this.characterId,
      universeId: universeId ?? this.universeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (characterId.present) {
      map['character_id'] = Variable<int>(characterId.value);
    }
    if (universeId.present) {
      map['universe_id'] = Variable<int>(universeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CharacterUniversesCompanion(')
          ..write('characterId: $characterId, ')
          ..write('universeId: $universeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreatorTeamsTable extends CreatorTeams
    with TableInfo<$CreatorTeamsTable, CreatorTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreatorTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _creatorIdMeta = const VerificationMeta(
    'creatorId',
  );
  @override
  late final GeneratedColumn<int> creatorId = GeneratedColumn<int>(
    'creator_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [creatorId, teamId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'creator_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<CreatorTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('creator_id')) {
      context.handle(
        _creatorIdMeta,
        creatorId.isAcceptableOrUnknown(data['creator_id']!, _creatorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_creatorIdMeta);
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {creatorId, teamId};
  @override
  CreatorTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreatorTeam(
      creatorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}creator_id'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
    );
  }

  @override
  $CreatorTeamsTable createAlias(String alias) {
    return $CreatorTeamsTable(attachedDatabase, alias);
  }
}

class CreatorTeam extends DataClass implements Insertable<CreatorTeam> {
  final int creatorId;
  final int teamId;
  const CreatorTeam({required this.creatorId, required this.teamId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['creator_id'] = Variable<int>(creatorId);
    map['team_id'] = Variable<int>(teamId);
    return map;
  }

  CreatorTeamsCompanion toCompanion(bool nullToAbsent) {
    return CreatorTeamsCompanion(
      creatorId: Value(creatorId),
      teamId: Value(teamId),
    );
  }

  factory CreatorTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreatorTeam(
      creatorId: serializer.fromJson<int>(json['creatorId']),
      teamId: serializer.fromJson<int>(json['teamId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'creatorId': serializer.toJson<int>(creatorId),
      'teamId': serializer.toJson<int>(teamId),
    };
  }

  CreatorTeam copyWith({int? creatorId, int? teamId}) => CreatorTeam(
    creatorId: creatorId ?? this.creatorId,
    teamId: teamId ?? this.teamId,
  );
  CreatorTeam copyWithCompanion(CreatorTeamsCompanion data) {
    return CreatorTeam(
      creatorId: data.creatorId.present ? data.creatorId.value : this.creatorId,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreatorTeam(')
          ..write('creatorId: $creatorId, ')
          ..write('teamId: $teamId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(creatorId, teamId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreatorTeam &&
          other.creatorId == this.creatorId &&
          other.teamId == this.teamId);
}

class CreatorTeamsCompanion extends UpdateCompanion<CreatorTeam> {
  final Value<int> creatorId;
  final Value<int> teamId;
  final Value<int> rowid;
  const CreatorTeamsCompanion({
    this.creatorId = const Value.absent(),
    this.teamId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreatorTeamsCompanion.insert({
    required int creatorId,
    required int teamId,
    this.rowid = const Value.absent(),
  }) : creatorId = Value(creatorId),
       teamId = Value(teamId);
  static Insertable<CreatorTeam> custom({
    Expression<int>? creatorId,
    Expression<int>? teamId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (creatorId != null) 'creator_id': creatorId,
      if (teamId != null) 'team_id': teamId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreatorTeamsCompanion copyWith({
    Value<int>? creatorId,
    Value<int>? teamId,
    Value<int>? rowid,
  }) {
    return CreatorTeamsCompanion(
      creatorId: creatorId ?? this.creatorId,
      teamId: teamId ?? this.teamId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (creatorId.present) {
      map['creator_id'] = Variable<int>(creatorId.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreatorTeamsCompanion(')
          ..write('creatorId: $creatorId, ')
          ..write('teamId: $teamId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamUniversesTable extends TeamUniverses
    with TableInfo<$TeamUniversesTable, TeamUniverse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamUniversesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<int> teamId = GeneratedColumn<int>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _universeIdMeta = const VerificationMeta(
    'universeId',
  );
  @override
  late final GeneratedColumn<int> universeId = GeneratedColumn<int>(
    'universe_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [teamId, universeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_universes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamUniverse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('universe_id')) {
      context.handle(
        _universeIdMeta,
        universeId.isAcceptableOrUnknown(data['universe_id']!, _universeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_universeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {teamId, universeId};
  @override
  TeamUniverse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamUniverse(
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}team_id'],
      )!,
      universeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}universe_id'],
      )!,
    );
  }

  @override
  $TeamUniversesTable createAlias(String alias) {
    return $TeamUniversesTable(attachedDatabase, alias);
  }
}

class TeamUniverse extends DataClass implements Insertable<TeamUniverse> {
  final int teamId;
  final int universeId;
  const TeamUniverse({required this.teamId, required this.universeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['team_id'] = Variable<int>(teamId);
    map['universe_id'] = Variable<int>(universeId);
    return map;
  }

  TeamUniversesCompanion toCompanion(bool nullToAbsent) {
    return TeamUniversesCompanion(
      teamId: Value(teamId),
      universeId: Value(universeId),
    );
  }

  factory TeamUniverse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamUniverse(
      teamId: serializer.fromJson<int>(json['teamId']),
      universeId: serializer.fromJson<int>(json['universeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'teamId': serializer.toJson<int>(teamId),
      'universeId': serializer.toJson<int>(universeId),
    };
  }

  TeamUniverse copyWith({int? teamId, int? universeId}) => TeamUniverse(
    teamId: teamId ?? this.teamId,
    universeId: universeId ?? this.universeId,
  );
  TeamUniverse copyWithCompanion(TeamUniversesCompanion data) {
    return TeamUniverse(
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      universeId: data.universeId.present
          ? data.universeId.value
          : this.universeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamUniverse(')
          ..write('teamId: $teamId, ')
          ..write('universeId: $universeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(teamId, universeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamUniverse &&
          other.teamId == this.teamId &&
          other.universeId == this.universeId);
}

class TeamUniversesCompanion extends UpdateCompanion<TeamUniverse> {
  final Value<int> teamId;
  final Value<int> universeId;
  final Value<int> rowid;
  const TeamUniversesCompanion({
    this.teamId = const Value.absent(),
    this.universeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamUniversesCompanion.insert({
    required int teamId,
    required int universeId,
    this.rowid = const Value.absent(),
  }) : teamId = Value(teamId),
       universeId = Value(universeId);
  static Insertable<TeamUniverse> custom({
    Expression<int>? teamId,
    Expression<int>? universeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (teamId != null) 'team_id': teamId,
      if (universeId != null) 'universe_id': universeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamUniversesCompanion copyWith({
    Value<int>? teamId,
    Value<int>? universeId,
    Value<int>? rowid,
  }) {
    return TeamUniversesCompanion(
      teamId: teamId ?? this.teamId,
      universeId: universeId ?? this.universeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (teamId.present) {
      map['team_id'] = Variable<int>(teamId.value);
    }
    if (universeId.present) {
      map['universe_id'] = Variable<int>(universeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamUniversesCompanion(')
          ..write('teamId: $teamId, ')
          ..write('universeId: $universeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetronReadingListItemsTable extends MetronReadingListItems
    with TableInfo<$MetronReadingListItemsTable, MetronReadingListItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetronReadingListItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<int> targetId = GeneratedColumn<int>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issueTypeMeta = const VerificationMeta(
    'issueType',
  );
  @override
  late final GeneratedColumn<String> issueType = GeneratedColumn<String>(
    'issue_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [listId, targetId, order, issueType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'metron_reading_list_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetronReadingListItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    }
    if (data.containsKey('issue_type')) {
      context.handle(
        _issueTypeMeta,
        issueType.isAcceptableOrUnknown(data['issue_type']!, _issueTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, targetId};
  @override
  MetronReadingListItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetronReadingListItem(
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      ),
      issueType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_type'],
      ),
    );
  }

  @override
  $MetronReadingListItemsTable createAlias(String alias) {
    return $MetronReadingListItemsTable(attachedDatabase, alias);
  }
}

class MetronReadingListItem extends DataClass
    implements Insertable<MetronReadingListItem> {
  final int listId;
  final int targetId;
  final int? order;
  final String? issueType;
  const MetronReadingListItem({
    required this.listId,
    required this.targetId,
    this.order,
    this.issueType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<int>(listId);
    map['target_id'] = Variable<int>(targetId);
    if (!nullToAbsent || order != null) {
      map['order'] = Variable<int>(order);
    }
    if (!nullToAbsent || issueType != null) {
      map['issue_type'] = Variable<String>(issueType);
    }
    return map;
  }

  MetronReadingListItemsCompanion toCompanion(bool nullToAbsent) {
    return MetronReadingListItemsCompanion(
      listId: Value(listId),
      targetId: Value(targetId),
      order: order == null && nullToAbsent
          ? const Value.absent()
          : Value(order),
      issueType: issueType == null && nullToAbsent
          ? const Value.absent()
          : Value(issueType),
    );
  }

  factory MetronReadingListItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetronReadingListItem(
      listId: serializer.fromJson<int>(json['listId']),
      targetId: serializer.fromJson<int>(json['targetId']),
      order: serializer.fromJson<int?>(json['order']),
      issueType: serializer.fromJson<String?>(json['issueType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<int>(listId),
      'targetId': serializer.toJson<int>(targetId),
      'order': serializer.toJson<int?>(order),
      'issueType': serializer.toJson<String?>(issueType),
    };
  }

  MetronReadingListItem copyWith({
    int? listId,
    int? targetId,
    Value<int?> order = const Value.absent(),
    Value<String?> issueType = const Value.absent(),
  }) => MetronReadingListItem(
    listId: listId ?? this.listId,
    targetId: targetId ?? this.targetId,
    order: order.present ? order.value : this.order,
    issueType: issueType.present ? issueType.value : this.issueType,
  );
  MetronReadingListItem copyWithCompanion(
    MetronReadingListItemsCompanion data,
  ) {
    return MetronReadingListItem(
      listId: data.listId.present ? data.listId.value : this.listId,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      order: data.order.present ? data.order.value : this.order,
      issueType: data.issueType.present ? data.issueType.value : this.issueType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetronReadingListItem(')
          ..write('listId: $listId, ')
          ..write('targetId: $targetId, ')
          ..write('order: $order, ')
          ..write('issueType: $issueType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(listId, targetId, order, issueType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetronReadingListItem &&
          other.listId == this.listId &&
          other.targetId == this.targetId &&
          other.order == this.order &&
          other.issueType == this.issueType);
}

class MetronReadingListItemsCompanion
    extends UpdateCompanion<MetronReadingListItem> {
  final Value<int> listId;
  final Value<int> targetId;
  final Value<int?> order;
  final Value<String?> issueType;
  final Value<int> rowid;
  const MetronReadingListItemsCompanion({
    this.listId = const Value.absent(),
    this.targetId = const Value.absent(),
    this.order = const Value.absent(),
    this.issueType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetronReadingListItemsCompanion.insert({
    required int listId,
    required int targetId,
    this.order = const Value.absent(),
    this.issueType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : listId = Value(listId),
       targetId = Value(targetId);
  static Insertable<MetronReadingListItem> custom({
    Expression<int>? listId,
    Expression<int>? targetId,
    Expression<int>? order,
    Expression<String>? issueType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (targetId != null) 'target_id': targetId,
      if (order != null) 'order': order,
      if (issueType != null) 'issue_type': issueType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetronReadingListItemsCompanion copyWith({
    Value<int>? listId,
    Value<int>? targetId,
    Value<int?>? order,
    Value<String?>? issueType,
    Value<int>? rowid,
  }) {
    return MetronReadingListItemsCompanion(
      listId: listId ?? this.listId,
      targetId: targetId ?? this.targetId,
      order: order ?? this.order,
      issueType: issueType ?? this.issueType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<int>(targetId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (issueType.present) {
      map['issue_type'] = Variable<String>(issueType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetronReadingListItemsCompanion(')
          ..write('listId: $listId, ')
          ..write('targetId: $targetId, ')
          ..write('order: $order, ')
          ..write('issueType: $issueType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiCacheTable extends ApiCache
    with TableInfo<$ApiCacheTable, ApiCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    cacheKey,
    entityType,
    payload,
    etag,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  ApiCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiCacheData(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $ApiCacheTable createAlias(String alias) {
    return $ApiCacheTable(attachedDatabase, alias);
  }
}

class ApiCacheData extends DataClass implements Insertable<ApiCacheData> {
  final String cacheKey;
  final String entityType;
  final String payload;
  final String? etag;
  final DateTime cachedAt;
  const ApiCacheData({
    required this.cacheKey,
    required this.entityType,
    required this.payload,
    this.etag,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    map['entity_type'] = Variable<String>(entityType);
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  ApiCacheCompanion toCompanion(bool nullToAbsent) {
    return ApiCacheCompanion(
      cacheKey: Value(cacheKey),
      entityType: Value(entityType),
      payload: Value(payload),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      cachedAt: Value(cachedAt),
    );
  }

  factory ApiCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiCacheData(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      entityType: serializer.fromJson<String>(json['entityType']),
      payload: serializer.fromJson<String>(json['payload']),
      etag: serializer.fromJson<String?>(json['etag']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'entityType': serializer.toJson<String>(entityType),
      'payload': serializer.toJson<String>(payload),
      'etag': serializer.toJson<String?>(etag),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  ApiCacheData copyWith({
    String? cacheKey,
    String? entityType,
    String? payload,
    Value<String?> etag = const Value.absent(),
    DateTime? cachedAt,
  }) => ApiCacheData(
    cacheKey: cacheKey ?? this.cacheKey,
    entityType: entityType ?? this.entityType,
    payload: payload ?? this.payload,
    etag: etag.present ? etag.value : this.etag,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  ApiCacheData copyWithCompanion(ApiCacheCompanion data) {
    return ApiCacheData(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      payload: data.payload.present ? data.payload.value : this.payload,
      etag: data.etag.present ? data.etag.value : this.etag,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheData(')
          ..write('cacheKey: $cacheKey, ')
          ..write('entityType: $entityType, ')
          ..write('payload: $payload, ')
          ..write('etag: $etag, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cacheKey, entityType, payload, etag, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiCacheData &&
          other.cacheKey == this.cacheKey &&
          other.entityType == this.entityType &&
          other.payload == this.payload &&
          other.etag == this.etag &&
          other.cachedAt == this.cachedAt);
}

class ApiCacheCompanion extends UpdateCompanion<ApiCacheData> {
  final Value<String> cacheKey;
  final Value<String> entityType;
  final Value<String> payload;
  final Value<String?> etag;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const ApiCacheCompanion({
    this.cacheKey = const Value.absent(),
    this.entityType = const Value.absent(),
    this.payload = const Value.absent(),
    this.etag = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiCacheCompanion.insert({
    required String cacheKey,
    required String entityType,
    required String payload,
    this.etag = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       entityType = Value(entityType),
       payload = Value(payload),
       cachedAt = Value(cachedAt);
  static Insertable<ApiCacheData> custom({
    Expression<String>? cacheKey,
    Expression<String>? entityType,
    Expression<String>? payload,
    Expression<String>? etag,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (entityType != null) 'entity_type': entityType,
      if (payload != null) 'payload': payload,
      if (etag != null) 'etag': etag,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiCacheCompanion copyWith({
    Value<String>? cacheKey,
    Value<String>? entityType,
    Value<String>? payload,
    Value<String?>? etag,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return ApiCacheCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      entityType: entityType ?? this.entityType,
      payload: payload ?? this.payload,
      etag: etag ?? this.etag,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiCacheCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('entityType: $entityType, ')
          ..write('payload: $payload, ')
          ..write('etag: $etag, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageCacheTable extends ImageCache
    with TableInfo<$ImageCacheTable, ImageCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    entityType,
    entityId,
    imageUrl,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ImageCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $ImageCacheTable createAlias(String alias) {
    return $ImageCacheTable(attachedDatabase, alias);
  }
}

class ImageCacheData extends DataClass implements Insertable<ImageCacheData> {
  final String key;
  final String entityType;
  final int entityId;
  final String imageUrl;
  final DateTime cachedAt;
  const ImageCacheData({
    required this.key,
    required this.entityType,
    required this.entityId,
    required this.imageUrl,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<int>(entityId);
    map['image_url'] = Variable<String>(imageUrl);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  ImageCacheCompanion toCompanion(bool nullToAbsent) {
    return ImageCacheCompanion(
      key: Value(key),
      entityType: Value(entityType),
      entityId: Value(entityId),
      imageUrl: Value(imageUrl),
      cachedAt: Value(cachedAt),
    );
  }

  factory ImageCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageCacheData(
      key: serializer.fromJson<String>(json['key']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<int>(json['entityId']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<int>(entityId),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  ImageCacheData copyWith({
    String? key,
    String? entityType,
    int? entityId,
    String? imageUrl,
    DateTime? cachedAt,
  }) => ImageCacheData(
    key: key ?? this.key,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    imageUrl: imageUrl ?? this.imageUrl,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  ImageCacheData copyWithCompanion(ImageCacheCompanion data) {
    return ImageCacheData(
      key: data.key.present ? data.key.value : this.key,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheData(')
          ..write('key: $key, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(key, entityType, entityId, imageUrl, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageCacheData &&
          other.key == this.key &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.imageUrl == this.imageUrl &&
          other.cachedAt == this.cachedAt);
}

class ImageCacheCompanion extends UpdateCompanion<ImageCacheData> {
  final Value<String> key;
  final Value<String> entityType;
  final Value<int> entityId;
  final Value<String> imageUrl;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const ImageCacheCompanion({
    this.key = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageCacheCompanion.insert({
    required String key,
    required String entityType,
    required int entityId,
    required String imageUrl,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       entityType = Value(entityType),
       entityId = Value(entityId),
       imageUrl = Value(imageUrl),
       cachedAt = Value(cachedAt);
  static Insertable<ImageCacheData> custom({
    Expression<String>? key,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? imageUrl,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (imageUrl != null) 'image_url': imageUrl,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? entityType,
    Value<int>? entityId,
    Value<String>? imageUrl,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return ImageCacheCompanion(
      key: key ?? this.key,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      imageUrl: imageUrl ?? this.imageUrl,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheCompanion(')
          ..write('key: $key, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesNameIndexTable extends SeriesNameIndex
    with TableInfo<$SeriesNameIndexTable, SeriesNameIndexData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesNameIndexTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalNameMeta = const VerificationMeta(
    'originalName',
  );
  @override
  late final GeneratedColumn<String> originalName = GeneratedColumn<String>(
    'original_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [normalizedName, originalName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_name_index';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesNameIndexData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('original_name')) {
      context.handle(
        _originalNameMeta,
        originalName.isAcceptableOrUnknown(
          data['original_name']!,
          _originalNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {normalizedName};
  @override
  SeriesNameIndexData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesNameIndexData(
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      originalName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_name'],
      )!,
    );
  }

  @override
  $SeriesNameIndexTable createAlias(String alias) {
    return $SeriesNameIndexTable(attachedDatabase, alias);
  }
}

class SeriesNameIndexData extends DataClass
    implements Insertable<SeriesNameIndexData> {
  final String normalizedName;
  final String originalName;
  const SeriesNameIndexData({
    required this.normalizedName,
    required this.originalName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['normalized_name'] = Variable<String>(normalizedName);
    map['original_name'] = Variable<String>(originalName);
    return map;
  }

  SeriesNameIndexCompanion toCompanion(bool nullToAbsent) {
    return SeriesNameIndexCompanion(
      normalizedName: Value(normalizedName),
      originalName: Value(originalName),
    );
  }

  factory SeriesNameIndexData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesNameIndexData(
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      originalName: serializer.fromJson<String>(json['originalName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'normalizedName': serializer.toJson<String>(normalizedName),
      'originalName': serializer.toJson<String>(originalName),
    };
  }

  SeriesNameIndexData copyWith({
    String? normalizedName,
    String? originalName,
  }) => SeriesNameIndexData(
    normalizedName: normalizedName ?? this.normalizedName,
    originalName: originalName ?? this.originalName,
  );
  SeriesNameIndexData copyWithCompanion(SeriesNameIndexCompanion data) {
    return SeriesNameIndexData(
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      originalName: data.originalName.present
          ? data.originalName.value
          : this.originalName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesNameIndexData(')
          ..write('normalizedName: $normalizedName, ')
          ..write('originalName: $originalName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(normalizedName, originalName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesNameIndexData &&
          other.normalizedName == this.normalizedName &&
          other.originalName == this.originalName);
}

class SeriesNameIndexCompanion extends UpdateCompanion<SeriesNameIndexData> {
  final Value<String> normalizedName;
  final Value<String> originalName;
  final Value<int> rowid;
  const SeriesNameIndexCompanion({
    this.normalizedName = const Value.absent(),
    this.originalName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesNameIndexCompanion.insert({
    required String normalizedName,
    required String originalName,
    this.rowid = const Value.absent(),
  }) : normalizedName = Value(normalizedName),
       originalName = Value(originalName);
  static Insertable<SeriesNameIndexData> custom({
    Expression<String>? normalizedName,
    Expression<String>? originalName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (originalName != null) 'original_name': originalName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesNameIndexCompanion copyWith({
    Value<String>? normalizedName,
    Value<String>? originalName,
    Value<int>? rowid,
  }) {
    return SeriesNameIndexCompanion(
      normalizedName: normalizedName ?? this.normalizedName,
      originalName: originalName ?? this.originalName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (originalName.present) {
      map['original_name'] = Variable<String>(originalName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesNameIndexCompanion(')
          ..write('normalizedName: $normalizedName, ')
          ..write('originalName: $originalName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String key;
  final String value;
  const SyncMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetaData copyWith({String? key, String? value}) =>
      SyncMetaData(key: key ?? this.key, value: value ?? this.value);
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LibraryItemsTable libraryItems = $LibraryItemsTable(this);
  late final $LibraryReadLogsTable libraryReadLogs = $LibraryReadLogsTable(
    this,
  );
  late final $PullListEntriesTable pullListEntries = $PullListEntriesTable(
    this,
  );
  late final $SeriesSubscriptionsTable seriesSubscriptions =
      $SeriesSubscriptionsTable(this);
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $ReadingListsTable readingLists = $ReadingListsTable(this);
  late final $ReadingListItemsTable readingListItems = $ReadingListItemsTable(
    this,
  );
  late final $FavoriteSeriesTable favoriteSeries = $FavoriteSeriesTable(this);
  late final $FavoriteIssuesTable favoriteIssues = $FavoriteIssuesTable(this);
  late final $FavoriteCharactersTable favoriteCharacters =
      $FavoriteCharactersTable(this);
  late final $FavoriteCreatorsTable favoriteCreators = $FavoriteCreatorsTable(
    this,
  );
  late final $FavoriteReadingListsTable favoriteReadingLists =
      $FavoriteReadingListsTable(this);
  late final $MetronIssuesTable metronIssues = $MetronIssuesTable(this);
  late final $MetronSeriesTable metronSeries = $MetronSeriesTable(this);
  late final $MetronCreatorsTable metronCreators = $MetronCreatorsTable(this);
  late final $MetronCharactersTable metronCharacters = $MetronCharactersTable(
    this,
  );
  late final $MetronArcsTable metronArcs = $MetronArcsTable(this);
  late final $MetronTeamsTable metronTeams = $MetronTeamsTable(this);
  late final $MetronUniversesTable metronUniverses = $MetronUniversesTable(
    this,
  );
  late final $MetronPublishersTable metronPublishers = $MetronPublishersTable(
    this,
  );
  late final $MetronImprintsTable metronImprints = $MetronImprintsTable(this);
  late final $MetronReadingListsTable metronReadingLists =
      $MetronReadingListsTable(this);
  late final $IssueCreatorsTable issueCreators = $IssueCreatorsTable(this);
  late final $IssueCharactersTable issueCharacters = $IssueCharactersTable(
    this,
  );
  late final $IssueArcsTable issueArcs = $IssueArcsTable(this);
  late final $IssueTeamsTable issueTeams = $IssueTeamsTable(this);
  late final $IssueUniversesTable issueUniverses = $IssueUniversesTable(this);
  late final $IssueImprintsTable issueImprints = $IssueImprintsTable(this);
  late final $SeriesArcsTable seriesArcs = $SeriesArcsTable(this);
  late final $SeriesTeamsTable seriesTeams = $SeriesTeamsTable(this);
  late final $SeriesUniversesTable seriesUniverses = $SeriesUniversesTable(
    this,
  );
  late final $AssociatedSeriesTable associatedSeries = $AssociatedSeriesTable(
    this,
  );
  late final $CharacterCreatorsTable characterCreators =
      $CharacterCreatorsTable(this);
  late final $CharacterTeamsTable characterTeams = $CharacterTeamsTable(this);
  late final $CharacterUniversesTable characterUniverses =
      $CharacterUniversesTable(this);
  late final $CreatorTeamsTable creatorTeams = $CreatorTeamsTable(this);
  late final $TeamUniversesTable teamUniverses = $TeamUniversesTable(this);
  late final $MetronReadingListItemsTable metronReadingListItems =
      $MetronReadingListItemsTable(this);
  late final $ApiCacheTable apiCache = $ApiCacheTable(this);
  late final $ImageCacheTable imageCache = $ImageCacheTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $SeriesNameIndexTable seriesNameIndex = $SeriesNameIndexTable(
    this,
  );
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final Index idxLibIssue = Index(
    'idx_lib_issue',
    'CREATE INDEX idx_lib_issue ON library_items (metron_issue_id)',
  );
  late final Index idxLibSeries = Index(
    'idx_lib_series',
    'CREATE INDEX idx_lib_series ON library_items (metron_series_id)',
  );
  late final Index idxReadlogItem = Index(
    'idx_readlog_item',
    'CREATE INDEX idx_readlog_item ON library_read_logs (collection_item_id)',
  );
  late final Index idxPullIssue = Index(
    'idx_pull_issue',
    'CREATE INDEX idx_pull_issue ON pull_list_entries (metron_issue_id)',
  );
  late final Index idxPullSeries = Index(
    'idx_pull_series',
    'CREATE INDEX idx_pull_series ON pull_list_entries (metron_series_id)',
  );
  late final Index idxPullRelease = Index(
    'idx_pull_release',
    'CREATE INDEX idx_pull_release ON pull_list_entries (release_date)',
  );
  late final Index idxSubSeries = Index(
    'idx_sub_series',
    'CREATE INDEX idx_sub_series ON series_subscriptions (metron_series_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    libraryItems,
    libraryReadLogs,
    pullListEntries,
    seriesSubscriptions,
    activityEvents,
    readingLists,
    readingListItems,
    favoriteSeries,
    favoriteIssues,
    favoriteCharacters,
    favoriteCreators,
    favoriteReadingLists,
    metronIssues,
    metronSeries,
    metronCreators,
    metronCharacters,
    metronArcs,
    metronTeams,
    metronUniverses,
    metronPublishers,
    metronImprints,
    metronReadingLists,
    issueCreators,
    issueCharacters,
    issueArcs,
    issueTeams,
    issueUniverses,
    issueImprints,
    seriesArcs,
    seriesTeams,
    seriesUniverses,
    associatedSeries,
    characterCreators,
    characterTeams,
    characterUniverses,
    creatorTeams,
    teamUniverses,
    metronReadingListItems,
    apiCache,
    imageCache,
    appSettings,
    seriesNameIndex,
    syncMeta,
    idxLibIssue,
    idxLibSeries,
    idxReadlogItem,
    idxPullIssue,
    idxPullSeries,
    idxPullRelease,
    idxSubSeries,
  ];
}

typedef $$LibraryItemsTableCreateCompanionBuilder =
    LibraryItemsCompanion Function({
      required String id,
      required String userId,
      required int metronIssueId,
      required int metronSeriesId,
      required String ownershipStatus,
      required bool isRead,
      Value<int?> rating,
      Value<String?> purchaseDate,
      Value<double?> pricePaid,
      Value<int> quantityOwned,
      required String format,
      Value<String?> firstReadAt,
      Value<String?> conditionGrade,
      Value<String?> acquiredOn,
      Value<String?> notes,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$LibraryItemsTableUpdateCompanionBuilder =
    LibraryItemsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> metronIssueId,
      Value<int> metronSeriesId,
      Value<String> ownershipStatus,
      Value<bool> isRead,
      Value<int?> rating,
      Value<String?> purchaseDate,
      Value<double?> pricePaid,
      Value<int> quantityOwned,
      Value<String> format,
      Value<String?> firstReadAt,
      Value<String?> conditionGrade,
      Value<String?> acquiredOn,
      Value<String?> notes,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$LibraryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownershipStatus => $composableBuilder(
    column: $table.ownershipStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityOwned => $composableBuilder(
    column: $table.quantityOwned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstReadAt => $composableBuilder(
    column: $table.firstReadAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionGrade => $composableBuilder(
    column: $table.conditionGrade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acquiredOn => $composableBuilder(
    column: $table.acquiredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownershipStatus => $composableBuilder(
    column: $table.ownershipStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityOwned => $composableBuilder(
    column: $table.quantityOwned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstReadAt => $composableBuilder(
    column: $table.firstReadAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionGrade => $composableBuilder(
    column: $table.conditionGrade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acquiredOn => $composableBuilder(
    column: $table.acquiredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryItemsTable> {
  $$LibraryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownershipStatus => $composableBuilder(
    column: $table.ownershipStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePaid =>
      $composableBuilder(column: $table.pricePaid, builder: (column) => column);

  GeneratedColumn<int> get quantityOwned => $composableBuilder(
    column: $table.quantityOwned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get firstReadAt => $composableBuilder(
    column: $table.firstReadAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionGrade => $composableBuilder(
    column: $table.conditionGrade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get acquiredOn => $composableBuilder(
    column: $table.acquiredOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryItemsTable,
          LibraryItem,
          $$LibraryItemsTableFilterComposer,
          $$LibraryItemsTableOrderingComposer,
          $$LibraryItemsTableAnnotationComposer,
          $$LibraryItemsTableCreateCompanionBuilder,
          $$LibraryItemsTableUpdateCompanionBuilder,
          (
            LibraryItem,
            BaseReferences<_$AppDatabase, $LibraryItemsTable, LibraryItem>,
          ),
          LibraryItem,
          PrefetchHooks Function()
        > {
  $$LibraryItemsTableTableManager(_$AppDatabase db, $LibraryItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> metronIssueId = const Value.absent(),
                Value<int> metronSeriesId = const Value.absent(),
                Value<String> ownershipStatus = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> purchaseDate = const Value.absent(),
                Value<double?> pricePaid = const Value.absent(),
                Value<int> quantityOwned = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String?> firstReadAt = const Value.absent(),
                Value<String?> conditionGrade = const Value.absent(),
                Value<String?> acquiredOn = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemsCompanion(
                id: id,
                userId: userId,
                metronIssueId: metronIssueId,
                metronSeriesId: metronSeriesId,
                ownershipStatus: ownershipStatus,
                isRead: isRead,
                rating: rating,
                purchaseDate: purchaseDate,
                pricePaid: pricePaid,
                quantityOwned: quantityOwned,
                format: format,
                firstReadAt: firstReadAt,
                conditionGrade: conditionGrade,
                acquiredOn: acquiredOn,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required int metronIssueId,
                required int metronSeriesId,
                required String ownershipStatus,
                required bool isRead,
                Value<int?> rating = const Value.absent(),
                Value<String?> purchaseDate = const Value.absent(),
                Value<double?> pricePaid = const Value.absent(),
                Value<int> quantityOwned = const Value.absent(),
                required String format,
                Value<String?> firstReadAt = const Value.absent(),
                Value<String?> conditionGrade = const Value.absent(),
                Value<String?> acquiredOn = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LibraryItemsCompanion.insert(
                id: id,
                userId: userId,
                metronIssueId: metronIssueId,
                metronSeriesId: metronSeriesId,
                ownershipStatus: ownershipStatus,
                isRead: isRead,
                rating: rating,
                purchaseDate: purchaseDate,
                pricePaid: pricePaid,
                quantityOwned: quantityOwned,
                format: format,
                firstReadAt: firstReadAt,
                conditionGrade: conditionGrade,
                acquiredOn: acquiredOn,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryItemsTable,
      LibraryItem,
      $$LibraryItemsTableFilterComposer,
      $$LibraryItemsTableOrderingComposer,
      $$LibraryItemsTableAnnotationComposer,
      $$LibraryItemsTableCreateCompanionBuilder,
      $$LibraryItemsTableUpdateCompanionBuilder,
      (
        LibraryItem,
        BaseReferences<_$AppDatabase, $LibraryItemsTable, LibraryItem>,
      ),
      LibraryItem,
      PrefetchHooks Function()
    >;
typedef $$LibraryReadLogsTableCreateCompanionBuilder =
    LibraryReadLogsCompanion Function({
      required String id,
      required String userId,
      required String collectionItemId,
      required String readAt,
      Value<String?> notes,
      required String createdAt,
      Value<int> rowid,
    });
typedef $$LibraryReadLogsTableUpdateCompanionBuilder =
    LibraryReadLogsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> collectionItemId,
      Value<String> readAt,
      Value<String?> notes,
      Value<String> createdAt,
      Value<int> rowid,
    });

class $$LibraryReadLogsTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryReadLogsTable> {
  $$LibraryReadLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionItemId => $composableBuilder(
    column: $table.collectionItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LibraryReadLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryReadLogsTable> {
  $$LibraryReadLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionItemId => $composableBuilder(
    column: $table.collectionItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LibraryReadLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryReadLogsTable> {
  $$LibraryReadLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get collectionItemId => $composableBuilder(
    column: $table.collectionItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LibraryReadLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryReadLogsTable,
          LibraryReadLog,
          $$LibraryReadLogsTableFilterComposer,
          $$LibraryReadLogsTableOrderingComposer,
          $$LibraryReadLogsTableAnnotationComposer,
          $$LibraryReadLogsTableCreateCompanionBuilder,
          $$LibraryReadLogsTableUpdateCompanionBuilder,
          (
            LibraryReadLog,
            BaseReferences<
              _$AppDatabase,
              $LibraryReadLogsTable,
              LibraryReadLog
            >,
          ),
          LibraryReadLog,
          PrefetchHooks Function()
        > {
  $$LibraryReadLogsTableTableManager(
    _$AppDatabase db,
    $LibraryReadLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryReadLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryReadLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryReadLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> collectionItemId = const Value.absent(),
                Value<String> readAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryReadLogsCompanion(
                id: id,
                userId: userId,
                collectionItemId: collectionItemId,
                readAt: readAt,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String collectionItemId,
                required String readAt,
                Value<String?> notes = const Value.absent(),
                required String createdAt,
                Value<int> rowid = const Value.absent(),
              }) => LibraryReadLogsCompanion.insert(
                id: id,
                userId: userId,
                collectionItemId: collectionItemId,
                readAt: readAt,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LibraryReadLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryReadLogsTable,
      LibraryReadLog,
      $$LibraryReadLogsTableFilterComposer,
      $$LibraryReadLogsTableOrderingComposer,
      $$LibraryReadLogsTableAnnotationComposer,
      $$LibraryReadLogsTableCreateCompanionBuilder,
      $$LibraryReadLogsTableUpdateCompanionBuilder,
      (
        LibraryReadLog,
        BaseReferences<_$AppDatabase, $LibraryReadLogsTable, LibraryReadLog>,
      ),
      LibraryReadLog,
      PrefetchHooks Function()
    >;
typedef $$PullListEntriesTableCreateCompanionBuilder =
    PullListEntriesCompanion Function({
      required String id,
      required String userId,
      required int metronIssueId,
      required int metronSeriesId,
      required String entryStatus,
      Value<DateTime?> releaseDate,
      required String source,
      required String generatedAt,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$PullListEntriesTableUpdateCompanionBuilder =
    PullListEntriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> metronIssueId,
      Value<int> metronSeriesId,
      Value<String> entryStatus,
      Value<DateTime?> releaseDate,
      Value<String> source,
      Value<String> generatedAt,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$PullListEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PullListEntriesTable> {
  $$PullListEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryStatus => $composableBuilder(
    column: $table.entryStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PullListEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PullListEntriesTable> {
  $$PullListEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryStatus => $composableBuilder(
    column: $table.entryStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PullListEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PullListEntriesTable> {
  $$PullListEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryStatus => $composableBuilder(
    column: $table.entryStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PullListEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PullListEntriesTable,
          PullListEntry,
          $$PullListEntriesTableFilterComposer,
          $$PullListEntriesTableOrderingComposer,
          $$PullListEntriesTableAnnotationComposer,
          $$PullListEntriesTableCreateCompanionBuilder,
          $$PullListEntriesTableUpdateCompanionBuilder,
          (
            PullListEntry,
            BaseReferences<_$AppDatabase, $PullListEntriesTable, PullListEntry>,
          ),
          PullListEntry,
          PrefetchHooks Function()
        > {
  $$PullListEntriesTableTableManager(
    _$AppDatabase db,
    $PullListEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PullListEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PullListEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PullListEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> metronIssueId = const Value.absent(),
                Value<int> metronSeriesId = const Value.absent(),
                Value<String> entryStatus = const Value.absent(),
                Value<DateTime?> releaseDate = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> generatedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PullListEntriesCompanion(
                id: id,
                userId: userId,
                metronIssueId: metronIssueId,
                metronSeriesId: metronSeriesId,
                entryStatus: entryStatus,
                releaseDate: releaseDate,
                source: source,
                generatedAt: generatedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required int metronIssueId,
                required int metronSeriesId,
                required String entryStatus,
                Value<DateTime?> releaseDate = const Value.absent(),
                required String source,
                required String generatedAt,
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PullListEntriesCompanion.insert(
                id: id,
                userId: userId,
                metronIssueId: metronIssueId,
                metronSeriesId: metronSeriesId,
                entryStatus: entryStatus,
                releaseDate: releaseDate,
                source: source,
                generatedAt: generatedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PullListEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PullListEntriesTable,
      PullListEntry,
      $$PullListEntriesTableFilterComposer,
      $$PullListEntriesTableOrderingComposer,
      $$PullListEntriesTableAnnotationComposer,
      $$PullListEntriesTableCreateCompanionBuilder,
      $$PullListEntriesTableUpdateCompanionBuilder,
      (
        PullListEntry,
        BaseReferences<_$AppDatabase, $PullListEntriesTable, PullListEntry>,
      ),
      PullListEntry,
      PrefetchHooks Function()
    >;
typedef $$SeriesSubscriptionsTableCreateCompanionBuilder =
    SeriesSubscriptionsCompanion Function({
      required String id,
      required String userId,
      required int metronSeriesId,
      required bool isActive,
      Value<bool> autoAddPull,
      required String subscribedAt,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$SeriesSubscriptionsTableUpdateCompanionBuilder =
    SeriesSubscriptionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int> metronSeriesId,
      Value<bool> isActive,
      Value<bool> autoAddPull,
      Value<String> subscribedAt,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$SeriesSubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesSubscriptionsTable> {
  $$SeriesSubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoAddPull => $composableBuilder(
    column: $table.autoAddPull,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesSubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesSubscriptionsTable> {
  $$SeriesSubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoAddPull => $composableBuilder(
    column: $table.autoAddPull,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesSubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesSubscriptionsTable> {
  $$SeriesSubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get autoAddPull => $composableBuilder(
    column: $table.autoAddPull,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subscribedAt => $composableBuilder(
    column: $table.subscribedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SeriesSubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesSubscriptionsTable,
          SeriesSubscription,
          $$SeriesSubscriptionsTableFilterComposer,
          $$SeriesSubscriptionsTableOrderingComposer,
          $$SeriesSubscriptionsTableAnnotationComposer,
          $$SeriesSubscriptionsTableCreateCompanionBuilder,
          $$SeriesSubscriptionsTableUpdateCompanionBuilder,
          (
            SeriesSubscription,
            BaseReferences<
              _$AppDatabase,
              $SeriesSubscriptionsTable,
              SeriesSubscription
            >,
          ),
          SeriesSubscription,
          PrefetchHooks Function()
        > {
  $$SeriesSubscriptionsTableTableManager(
    _$AppDatabase db,
    $SeriesSubscriptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesSubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesSubscriptionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SeriesSubscriptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> metronSeriesId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> autoAddPull = const Value.absent(),
                Value<String> subscribedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesSubscriptionsCompanion(
                id: id,
                userId: userId,
                metronSeriesId: metronSeriesId,
                isActive: isActive,
                autoAddPull: autoAddPull,
                subscribedAt: subscribedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required int metronSeriesId,
                required bool isActive,
                Value<bool> autoAddPull = const Value.absent(),
                required String subscribedAt,
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SeriesSubscriptionsCompanion.insert(
                id: id,
                userId: userId,
                metronSeriesId: metronSeriesId,
                isActive: isActive,
                autoAddPull: autoAddPull,
                subscribedAt: subscribedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesSubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesSubscriptionsTable,
      SeriesSubscription,
      $$SeriesSubscriptionsTableFilterComposer,
      $$SeriesSubscriptionsTableOrderingComposer,
      $$SeriesSubscriptionsTableAnnotationComposer,
      $$SeriesSubscriptionsTableCreateCompanionBuilder,
      $$SeriesSubscriptionsTableUpdateCompanionBuilder,
      (
        SeriesSubscription,
        BaseReferences<
          _$AppDatabase,
          $SeriesSubscriptionsTable,
          SeriesSubscription
        >,
      ),
      SeriesSubscription,
      PrefetchHooks Function()
    >;
typedef $$ActivityEventsTableCreateCompanionBuilder =
    ActivityEventsCompanion Function({
      required String id,
      required String userId,
      Value<int?> seriesId,
      Value<int?> issueId,
      required String eventType,
      Value<String?> seriesName,
      Value<String?> issueNumber,
      Value<String?> imageUrl,
      Value<String?> metadata,
      required String timestamp,
      Value<int> rowid,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<int?> seriesId,
      Value<int?> issueId,
      Value<String> eventType,
      Value<String?> seriesName,
      Value<String?> issueNumber,
      Value<String?> imageUrl,
      Value<String?> metadata,
      Value<String> timestamp,
      Value<int> rowid,
    });

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueNumber => $composableBuilder(
    column: $table.issueNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueNumber => $composableBuilder(
    column: $table.issueNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get seriesName => $composableBuilder(
    column: $table.seriesName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issueNumber => $composableBuilder(
    column: $table.issueNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  GeneratedColumn<String> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$ActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTable,
          ActivityEvent,
          $$ActivityEventsTableFilterComposer,
          $$ActivityEventsTableOrderingComposer,
          $$ActivityEventsTableAnnotationComposer,
          $$ActivityEventsTableCreateCompanionBuilder,
          $$ActivityEventsTableUpdateCompanionBuilder,
          (
            ActivityEvent,
            BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
          ),
          ActivityEvent,
          PrefetchHooks Function()
        > {
  $$ActivityEventsTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                Value<int?> issueId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> seriesName = const Value.absent(),
                Value<String?> issueNumber = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                Value<String> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                userId: userId,
                seriesId: seriesId,
                issueId: issueId,
                eventType: eventType,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                metadata: metadata,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<int?> seriesId = const Value.absent(),
                Value<int?> issueId = const Value.absent(),
                required String eventType,
                Value<String?> seriesName = const Value.absent(),
                Value<String?> issueNumber = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
                required String timestamp,
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion.insert(
                id: id,
                userId: userId,
                seriesId: seriesId,
                issueId: issueId,
                eventType: eventType,
                seriesName: seriesName,
                issueNumber: issueNumber,
                imageUrl: imageUrl,
                metadata: metadata,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTable,
      ActivityEvent,
      $$ActivityEventsTableFilterComposer,
      $$ActivityEventsTableOrderingComposer,
      $$ActivityEventsTableAnnotationComposer,
      $$ActivityEventsTableCreateCompanionBuilder,
      $$ActivityEventsTableUpdateCompanionBuilder,
      (
        ActivityEvent,
        BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
      ),
      ActivityEvent,
      PrefetchHooks Function()
    >;
typedef $$ReadingListsTableCreateCompanionBuilder =
    ReadingListsCompanion Function({
      required String id,
      required String title,
      required String description,
      required bool isOrdered,
      required String contentType,
      required String itemsJson,
      Value<int?> metronSourceId,
      Value<String?> metronAttributionSource,
      Value<String?> metronAttributionUrl,
      Value<String?> metronImageUrl,
      Value<String?> metronListType,
      Value<String?> lastSyncedAt,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$ReadingListsTableUpdateCompanionBuilder =
    ReadingListsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<bool> isOrdered,
      Value<String> contentType,
      Value<String> itemsJson,
      Value<int?> metronSourceId,
      Value<String?> metronAttributionSource,
      Value<String?> metronAttributionUrl,
      Value<String?> metronImageUrl,
      Value<String?> metronListType,
      Value<String?> lastSyncedAt,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$ReadingListsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingListsTable> {
  $$ReadingListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOrdered => $composableBuilder(
    column: $table.isOrdered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get metronSourceId => $composableBuilder(
    column: $table.metronSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metronAttributionSource => $composableBuilder(
    column: $table.metronAttributionSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metronAttributionUrl => $composableBuilder(
    column: $table.metronAttributionUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metronImageUrl => $composableBuilder(
    column: $table.metronImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metronListType => $composableBuilder(
    column: $table.metronListType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingListsTable> {
  $$ReadingListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOrdered => $composableBuilder(
    column: $table.isOrdered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get metronSourceId => $composableBuilder(
    column: $table.metronSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metronAttributionSource => $composableBuilder(
    column: $table.metronAttributionSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metronAttributionUrl => $composableBuilder(
    column: $table.metronAttributionUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metronImageUrl => $composableBuilder(
    column: $table.metronImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metronListType => $composableBuilder(
    column: $table.metronListType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingListsTable> {
  $$ReadingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isOrdered =>
      $composableBuilder(column: $table.isOrdered, builder: (column) => column);

  GeneratedColumn<String> get contentType => $composableBuilder(
    column: $table.contentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<int> get metronSourceId => $composableBuilder(
    column: $table.metronSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metronAttributionSource => $composableBuilder(
    column: $table.metronAttributionSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metronAttributionUrl => $composableBuilder(
    column: $table.metronAttributionUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metronImageUrl => $composableBuilder(
    column: $table.metronImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metronListType => $composableBuilder(
    column: $table.metronListType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingListsTable,
          ReadingList,
          $$ReadingListsTableFilterComposer,
          $$ReadingListsTableOrderingComposer,
          $$ReadingListsTableAnnotationComposer,
          $$ReadingListsTableCreateCompanionBuilder,
          $$ReadingListsTableUpdateCompanionBuilder,
          (
            ReadingList,
            BaseReferences<_$AppDatabase, $ReadingListsTable, ReadingList>,
          ),
          ReadingList,
          PrefetchHooks Function()
        > {
  $$ReadingListsTableTableManager(_$AppDatabase db, $ReadingListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<bool> isOrdered = const Value.absent(),
                Value<String> contentType = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<int?> metronSourceId = const Value.absent(),
                Value<String?> metronAttributionSource = const Value.absent(),
                Value<String?> metronAttributionUrl = const Value.absent(),
                Value<String?> metronImageUrl = const Value.absent(),
                Value<String?> metronListType = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingListsCompanion(
                id: id,
                title: title,
                description: description,
                isOrdered: isOrdered,
                contentType: contentType,
                itemsJson: itemsJson,
                metronSourceId: metronSourceId,
                metronAttributionSource: metronAttributionSource,
                metronAttributionUrl: metronAttributionUrl,
                metronImageUrl: metronImageUrl,
                metronListType: metronListType,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required bool isOrdered,
                required String contentType,
                required String itemsJson,
                Value<int?> metronSourceId = const Value.absent(),
                Value<String?> metronAttributionSource = const Value.absent(),
                Value<String?> metronAttributionUrl = const Value.absent(),
                Value<String?> metronImageUrl = const Value.absent(),
                Value<String?> metronListType = const Value.absent(),
                Value<String?> lastSyncedAt = const Value.absent(),
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReadingListsCompanion.insert(
                id: id,
                title: title,
                description: description,
                isOrdered: isOrdered,
                contentType: contentType,
                itemsJson: itemsJson,
                metronSourceId: metronSourceId,
                metronAttributionSource: metronAttributionSource,
                metronAttributionUrl: metronAttributionUrl,
                metronImageUrl: metronImageUrl,
                metronListType: metronListType,
                lastSyncedAt: lastSyncedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingListsTable,
      ReadingList,
      $$ReadingListsTableFilterComposer,
      $$ReadingListsTableOrderingComposer,
      $$ReadingListsTableAnnotationComposer,
      $$ReadingListsTableCreateCompanionBuilder,
      $$ReadingListsTableUpdateCompanionBuilder,
      (
        ReadingList,
        BaseReferences<_$AppDatabase, $ReadingListsTable, ReadingList>,
      ),
      ReadingList,
      PrefetchHooks Function()
    >;
typedef $$ReadingListItemsTableCreateCompanionBuilder =
    ReadingListItemsCompanion Function({
      required String id,
      required String listId,
      required String targetId,
      required bool isSeries,
      required String role,
      required bool isRead,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$ReadingListItemsTableUpdateCompanionBuilder =
    ReadingListItemsCompanion Function({
      Value<String> id,
      Value<String> listId,
      Value<String> targetId,
      Value<bool> isSeries,
      Value<String> role,
      Value<bool> isRead,
      Value<int> sortOrder,
      Value<int> rowid,
    });

class $$ReadingListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingListItemsTable> {
  $$ReadingListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSeries => $composableBuilder(
    column: $table.isSeries,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingListItemsTable> {
  $$ReadingListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSeries => $composableBuilder(
    column: $table.isSeries,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingListItemsTable> {
  $$ReadingListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<bool> get isSeries =>
      $composableBuilder(column: $table.isSeries, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$ReadingListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingListItemsTable,
          ReadingListItem,
          $$ReadingListItemsTableFilterComposer,
          $$ReadingListItemsTableOrderingComposer,
          $$ReadingListItemsTableAnnotationComposer,
          $$ReadingListItemsTableCreateCompanionBuilder,
          $$ReadingListItemsTableUpdateCompanionBuilder,
          (
            ReadingListItem,
            BaseReferences<
              _$AppDatabase,
              $ReadingListItemsTable,
              ReadingListItem
            >,
          ),
          ReadingListItem,
          PrefetchHooks Function()
        > {
  $$ReadingListItemsTableTableManager(
    _$AppDatabase db,
    $ReadingListItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingListItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingListItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingListItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<bool> isSeries = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingListItemsCompanion(
                id: id,
                listId: listId,
                targetId: targetId,
                isSeries: isSeries,
                role: role,
                isRead: isRead,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String listId,
                required String targetId,
                required bool isSeries,
                required String role,
                required bool isRead,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => ReadingListItemsCompanion.insert(
                id: id,
                listId: listId,
                targetId: targetId,
                isSeries: isSeries,
                role: role,
                isRead: isRead,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingListItemsTable,
      ReadingListItem,
      $$ReadingListItemsTableFilterComposer,
      $$ReadingListItemsTableOrderingComposer,
      $$ReadingListItemsTableAnnotationComposer,
      $$ReadingListItemsTableCreateCompanionBuilder,
      $$ReadingListItemsTableUpdateCompanionBuilder,
      (
        ReadingListItem,
        BaseReferences<_$AppDatabase, $ReadingListItemsTable, ReadingListItem>,
      ),
      ReadingListItem,
      PrefetchHooks Function()
    >;
typedef $$FavoriteSeriesTableCreateCompanionBuilder =
    FavoriteSeriesCompanion Function({
      Value<int> metronSeriesId,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FavoriteSeriesTableUpdateCompanionBuilder =
    FavoriteSeriesCompanion Function({
      Value<int> metronSeriesId,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FavoriteSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteSeriesTable> {
  $$FavoriteSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteSeriesTable> {
  $$FavoriteSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteSeriesTable> {
  $$FavoriteSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get metronSeriesId => $composableBuilder(
    column: $table.metronSeriesId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteSeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteSeriesTable,
          FavoriteSery,
          $$FavoriteSeriesTableFilterComposer,
          $$FavoriteSeriesTableOrderingComposer,
          $$FavoriteSeriesTableAnnotationComposer,
          $$FavoriteSeriesTableCreateCompanionBuilder,
          $$FavoriteSeriesTableUpdateCompanionBuilder,
          (
            FavoriteSery,
            BaseReferences<_$AppDatabase, $FavoriteSeriesTable, FavoriteSery>,
          ),
          FavoriteSery,
          PrefetchHooks Function()
        > {
  $$FavoriteSeriesTableTableManager(
    _$AppDatabase db,
    $FavoriteSeriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> metronSeriesId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FavoriteSeriesCompanion(
                metronSeriesId: metronSeriesId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> metronSeriesId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FavoriteSeriesCompanion.insert(
                metronSeriesId: metronSeriesId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteSeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteSeriesTable,
      FavoriteSery,
      $$FavoriteSeriesTableFilterComposer,
      $$FavoriteSeriesTableOrderingComposer,
      $$FavoriteSeriesTableAnnotationComposer,
      $$FavoriteSeriesTableCreateCompanionBuilder,
      $$FavoriteSeriesTableUpdateCompanionBuilder,
      (
        FavoriteSery,
        BaseReferences<_$AppDatabase, $FavoriteSeriesTable, FavoriteSery>,
      ),
      FavoriteSery,
      PrefetchHooks Function()
    >;
typedef $$FavoriteIssuesTableCreateCompanionBuilder =
    FavoriteIssuesCompanion Function({
      Value<int> metronIssueId,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FavoriteIssuesTableUpdateCompanionBuilder =
    FavoriteIssuesCompanion Function({
      Value<int> metronIssueId,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FavoriteIssuesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteIssuesTable> {
  $$FavoriteIssuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteIssuesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteIssuesTable> {
  $$FavoriteIssuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteIssuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteIssuesTable> {
  $$FavoriteIssuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get metronIssueId => $composableBuilder(
    column: $table.metronIssueId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteIssuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteIssuesTable,
          FavoriteIssue,
          $$FavoriteIssuesTableFilterComposer,
          $$FavoriteIssuesTableOrderingComposer,
          $$FavoriteIssuesTableAnnotationComposer,
          $$FavoriteIssuesTableCreateCompanionBuilder,
          $$FavoriteIssuesTableUpdateCompanionBuilder,
          (
            FavoriteIssue,
            BaseReferences<_$AppDatabase, $FavoriteIssuesTable, FavoriteIssue>,
          ),
          FavoriteIssue,
          PrefetchHooks Function()
        > {
  $$FavoriteIssuesTableTableManager(
    _$AppDatabase db,
    $FavoriteIssuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteIssuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteIssuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteIssuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> metronIssueId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FavoriteIssuesCompanion(
                metronIssueId: metronIssueId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> metronIssueId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FavoriteIssuesCompanion.insert(
                metronIssueId: metronIssueId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteIssuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteIssuesTable,
      FavoriteIssue,
      $$FavoriteIssuesTableFilterComposer,
      $$FavoriteIssuesTableOrderingComposer,
      $$FavoriteIssuesTableAnnotationComposer,
      $$FavoriteIssuesTableCreateCompanionBuilder,
      $$FavoriteIssuesTableUpdateCompanionBuilder,
      (
        FavoriteIssue,
        BaseReferences<_$AppDatabase, $FavoriteIssuesTable, FavoriteIssue>,
      ),
      FavoriteIssue,
      PrefetchHooks Function()
    >;
typedef $$FavoriteCharactersTableCreateCompanionBuilder =
    FavoriteCharactersCompanion Function({
      Value<int> metronCharacterId,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FavoriteCharactersTableUpdateCompanionBuilder =
    FavoriteCharactersCompanion Function({
      Value<int> metronCharacterId,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FavoriteCharactersTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteCharactersTable> {
  $$FavoriteCharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get metronCharacterId => $composableBuilder(
    column: $table.metronCharacterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteCharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteCharactersTable> {
  $$FavoriteCharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get metronCharacterId => $composableBuilder(
    column: $table.metronCharacterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteCharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteCharactersTable> {
  $$FavoriteCharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get metronCharacterId => $composableBuilder(
    column: $table.metronCharacterId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteCharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteCharactersTable,
          FavoriteCharacter,
          $$FavoriteCharactersTableFilterComposer,
          $$FavoriteCharactersTableOrderingComposer,
          $$FavoriteCharactersTableAnnotationComposer,
          $$FavoriteCharactersTableCreateCompanionBuilder,
          $$FavoriteCharactersTableUpdateCompanionBuilder,
          (
            FavoriteCharacter,
            BaseReferences<
              _$AppDatabase,
              $FavoriteCharactersTable,
              FavoriteCharacter
            >,
          ),
          FavoriteCharacter,
          PrefetchHooks Function()
        > {
  $$FavoriteCharactersTableTableManager(
    _$AppDatabase db,
    $FavoriteCharactersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteCharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteCharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteCharactersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> metronCharacterId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FavoriteCharactersCompanion(
                metronCharacterId: metronCharacterId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> metronCharacterId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FavoriteCharactersCompanion.insert(
                metronCharacterId: metronCharacterId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteCharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteCharactersTable,
      FavoriteCharacter,
      $$FavoriteCharactersTableFilterComposer,
      $$FavoriteCharactersTableOrderingComposer,
      $$FavoriteCharactersTableAnnotationComposer,
      $$FavoriteCharactersTableCreateCompanionBuilder,
      $$FavoriteCharactersTableUpdateCompanionBuilder,
      (
        FavoriteCharacter,
        BaseReferences<
          _$AppDatabase,
          $FavoriteCharactersTable,
          FavoriteCharacter
        >,
      ),
      FavoriteCharacter,
      PrefetchHooks Function()
    >;
typedef $$FavoriteCreatorsTableCreateCompanionBuilder =
    FavoriteCreatorsCompanion Function({
      Value<int> metronCreatorId,
      required String createdAt,
      required String updatedAt,
    });
typedef $$FavoriteCreatorsTableUpdateCompanionBuilder =
    FavoriteCreatorsCompanion Function({
      Value<int> metronCreatorId,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

class $$FavoriteCreatorsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteCreatorsTable> {
  $$FavoriteCreatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get metronCreatorId => $composableBuilder(
    column: $table.metronCreatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteCreatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteCreatorsTable> {
  $$FavoriteCreatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get metronCreatorId => $composableBuilder(
    column: $table.metronCreatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteCreatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteCreatorsTable> {
  $$FavoriteCreatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get metronCreatorId => $composableBuilder(
    column: $table.metronCreatorId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteCreatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteCreatorsTable,
          FavoriteCreator,
          $$FavoriteCreatorsTableFilterComposer,
          $$FavoriteCreatorsTableOrderingComposer,
          $$FavoriteCreatorsTableAnnotationComposer,
          $$FavoriteCreatorsTableCreateCompanionBuilder,
          $$FavoriteCreatorsTableUpdateCompanionBuilder,
          (
            FavoriteCreator,
            BaseReferences<
              _$AppDatabase,
              $FavoriteCreatorsTable,
              FavoriteCreator
            >,
          ),
          FavoriteCreator,
          PrefetchHooks Function()
        > {
  $$FavoriteCreatorsTableTableManager(
    _$AppDatabase db,
    $FavoriteCreatorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteCreatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteCreatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteCreatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> metronCreatorId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => FavoriteCreatorsCompanion(
                metronCreatorId: metronCreatorId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> metronCreatorId = const Value.absent(),
                required String createdAt,
                required String updatedAt,
              }) => FavoriteCreatorsCompanion.insert(
                metronCreatorId: metronCreatorId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteCreatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteCreatorsTable,
      FavoriteCreator,
      $$FavoriteCreatorsTableFilterComposer,
      $$FavoriteCreatorsTableOrderingComposer,
      $$FavoriteCreatorsTableAnnotationComposer,
      $$FavoriteCreatorsTableCreateCompanionBuilder,
      $$FavoriteCreatorsTableUpdateCompanionBuilder,
      (
        FavoriteCreator,
        BaseReferences<_$AppDatabase, $FavoriteCreatorsTable, FavoriteCreator>,
      ),
      FavoriteCreator,
      PrefetchHooks Function()
    >;
typedef $$FavoriteReadingListsTableCreateCompanionBuilder =
    FavoriteReadingListsCompanion Function({
      required String readingListId,
      required String createdAt,
      required String updatedAt,
      Value<int> rowid,
    });
typedef $$FavoriteReadingListsTableUpdateCompanionBuilder =
    FavoriteReadingListsCompanion Function({
      Value<String> readingListId,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<int> rowid,
    });

class $$FavoriteReadingListsTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteReadingListsTable> {
  $$FavoriteReadingListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get readingListId => $composableBuilder(
    column: $table.readingListId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteReadingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteReadingListsTable> {
  $$FavoriteReadingListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get readingListId => $composableBuilder(
    column: $table.readingListId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteReadingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteReadingListsTable> {
  $$FavoriteReadingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get readingListId => $composableBuilder(
    column: $table.readingListId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FavoriteReadingListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteReadingListsTable,
          FavoriteReadingList,
          $$FavoriteReadingListsTableFilterComposer,
          $$FavoriteReadingListsTableOrderingComposer,
          $$FavoriteReadingListsTableAnnotationComposer,
          $$FavoriteReadingListsTableCreateCompanionBuilder,
          $$FavoriteReadingListsTableUpdateCompanionBuilder,
          (
            FavoriteReadingList,
            BaseReferences<
              _$AppDatabase,
              $FavoriteReadingListsTable,
              FavoriteReadingList
            >,
          ),
          FavoriteReadingList,
          PrefetchHooks Function()
        > {
  $$FavoriteReadingListsTableTableManager(
    _$AppDatabase db,
    $FavoriteReadingListsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteReadingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteReadingListsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FavoriteReadingListsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> readingListId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteReadingListsCompanion(
                readingListId: readingListId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String readingListId,
                required String createdAt,
                required String updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteReadingListsCompanion.insert(
                readingListId: readingListId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteReadingListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteReadingListsTable,
      FavoriteReadingList,
      $$FavoriteReadingListsTableFilterComposer,
      $$FavoriteReadingListsTableOrderingComposer,
      $$FavoriteReadingListsTableAnnotationComposer,
      $$FavoriteReadingListsTableCreateCompanionBuilder,
      $$FavoriteReadingListsTableUpdateCompanionBuilder,
      (
        FavoriteReadingList,
        BaseReferences<
          _$AppDatabase,
          $FavoriteReadingListsTable,
          FavoriteReadingList
        >,
      ),
      FavoriteReadingList,
      PrefetchHooks Function()
    >;
typedef $$MetronIssuesTableCreateCompanionBuilder =
    MetronIssuesCompanion Function({
      Value<int> id,
      required String number,
      Value<int?> seriesId,
      Value<String?> coverDate,
      Value<String?> storeDate,
      Value<String?> focDate,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> pageCount,
      Value<String?> price,
      Value<String?> sku,
      Value<String?> upc,
      Value<String?> isbn,
      Value<String?> coverHash,
      Value<int?> publisherId,
      Value<int?> imprintId,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronIssuesTableUpdateCompanionBuilder =
    MetronIssuesCompanion Function({
      Value<int> id,
      Value<String> number,
      Value<int?> seriesId,
      Value<String?> coverDate,
      Value<String?> storeDate,
      Value<String?> focDate,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> pageCount,
      Value<String?> price,
      Value<String?> sku,
      Value<String?> upc,
      Value<String?> isbn,
      Value<String?> coverHash,
      Value<int?> publisherId,
      Value<int?> imprintId,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronIssuesTableFilterComposer
    extends Composer<_$AppDatabase, $MetronIssuesTable> {
  $$MetronIssuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverDate => $composableBuilder(
    column: $table.coverDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storeDate => $composableBuilder(
    column: $table.storeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focDate => $composableBuilder(
    column: $table.focDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upc => $composableBuilder(
    column: $table.upc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverHash => $composableBuilder(
    column: $table.coverHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imprintId => $composableBuilder(
    column: $table.imprintId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronIssuesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronIssuesTable> {
  $$MetronIssuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverDate => $composableBuilder(
    column: $table.coverDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storeDate => $composableBuilder(
    column: $table.storeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focDate => $composableBuilder(
    column: $table.focDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upc => $composableBuilder(
    column: $table.upc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverHash => $composableBuilder(
    column: $table.coverHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imprintId => $composableBuilder(
    column: $table.imprintId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronIssuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronIssuesTable> {
  $$MetronIssuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<String> get coverDate =>
      $composableBuilder(column: $table.coverDate, builder: (column) => column);

  GeneratedColumn<String> get storeDate =>
      $composableBuilder(column: $table.storeDate, builder: (column) => column);

  GeneratedColumn<String> get focDate =>
      $composableBuilder(column: $table.focDate, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get upc =>
      $composableBuilder(column: $table.upc, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get coverHash =>
      $composableBuilder(column: $table.coverHash, builder: (column) => column);

  GeneratedColumn<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imprintId =>
      $composableBuilder(column: $table.imprintId, builder: (column) => column);

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronIssuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronIssuesTable,
          MetronIssue,
          $$MetronIssuesTableFilterComposer,
          $$MetronIssuesTableOrderingComposer,
          $$MetronIssuesTableAnnotationComposer,
          $$MetronIssuesTableCreateCompanionBuilder,
          $$MetronIssuesTableUpdateCompanionBuilder,
          (
            MetronIssue,
            BaseReferences<_$AppDatabase, $MetronIssuesTable, MetronIssue>,
          ),
          MetronIssue,
          PrefetchHooks Function()
        > {
  $$MetronIssuesTableTableManager(_$AppDatabase db, $MetronIssuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronIssuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronIssuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronIssuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> number = const Value.absent(),
                Value<int?> seriesId = const Value.absent(),
                Value<String?> coverDate = const Value.absent(),
                Value<String?> storeDate = const Value.absent(),
                Value<String?> focDate = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> price = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> upc = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> coverHash = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<int?> imprintId = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronIssuesCompanion(
                id: id,
                number: number,
                seriesId: seriesId,
                coverDate: coverDate,
                storeDate: storeDate,
                focDate: focDate,
                imageUrl: imageUrl,
                description: description,
                pageCount: pageCount,
                price: price,
                sku: sku,
                upc: upc,
                isbn: isbn,
                coverHash: coverHash,
                publisherId: publisherId,
                imprintId: imprintId,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String number,
                Value<int?> seriesId = const Value.absent(),
                Value<String?> coverDate = const Value.absent(),
                Value<String?> storeDate = const Value.absent(),
                Value<String?> focDate = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> price = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> upc = const Value.absent(),
                Value<String?> isbn = const Value.absent(),
                Value<String?> coverHash = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<int?> imprintId = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronIssuesCompanion.insert(
                id: id,
                number: number,
                seriesId: seriesId,
                coverDate: coverDate,
                storeDate: storeDate,
                focDate: focDate,
                imageUrl: imageUrl,
                description: description,
                pageCount: pageCount,
                price: price,
                sku: sku,
                upc: upc,
                isbn: isbn,
                coverHash: coverHash,
                publisherId: publisherId,
                imprintId: imprintId,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronIssuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronIssuesTable,
      MetronIssue,
      $$MetronIssuesTableFilterComposer,
      $$MetronIssuesTableOrderingComposer,
      $$MetronIssuesTableAnnotationComposer,
      $$MetronIssuesTableCreateCompanionBuilder,
      $$MetronIssuesTableUpdateCompanionBuilder,
      (
        MetronIssue,
        BaseReferences<_$AppDatabase, $MetronIssuesTable, MetronIssue>,
      ),
      MetronIssue,
      PrefetchHooks Function()
    >;
typedef $$MetronSeriesTableCreateCompanionBuilder =
    MetronSeriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> sortName,
      Value<int?> volume,
      Value<int?> seriesTypeId,
      Value<String?> status,
      Value<int?> publisherId,
      Value<int?> imprintId,
      Value<int?> yearBegan,
      Value<int?> yearEnd,
      Value<String?> description,
      Value<int?> issueCount,
      Value<String?> computedCoverUrl,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronSeriesTableUpdateCompanionBuilder =
    MetronSeriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> sortName,
      Value<int?> volume,
      Value<int?> seriesTypeId,
      Value<String?> status,
      Value<int?> publisherId,
      Value<int?> imprintId,
      Value<int?> yearBegan,
      Value<int?> yearEnd,
      Value<String?> description,
      Value<int?> issueCount,
      Value<String?> computedCoverUrl,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $MetronSeriesTable> {
  $$MetronSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesTypeId => $composableBuilder(
    column: $table.seriesTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imprintId => $composableBuilder(
    column: $table.imprintId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearBegan => $composableBuilder(
    column: $table.yearBegan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearEnd => $composableBuilder(
    column: $table.yearEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issueCount => $composableBuilder(
    column: $table.issueCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get computedCoverUrl => $composableBuilder(
    column: $table.computedCoverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronSeriesTable> {
  $$MetronSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sortName => $composableBuilder(
    column: $table.sortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesTypeId => $composableBuilder(
    column: $table.seriesTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imprintId => $composableBuilder(
    column: $table.imprintId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearBegan => $composableBuilder(
    column: $table.yearBegan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearEnd => $composableBuilder(
    column: $table.yearEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issueCount => $composableBuilder(
    column: $table.issueCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get computedCoverUrl => $composableBuilder(
    column: $table.computedCoverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronSeriesTable> {
  $$MetronSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sortName =>
      $composableBuilder(column: $table.sortName, builder: (column) => column);

  GeneratedColumn<int> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<int> get seriesTypeId => $composableBuilder(
    column: $table.seriesTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get imprintId =>
      $composableBuilder(column: $table.imprintId, builder: (column) => column);

  GeneratedColumn<int> get yearBegan =>
      $composableBuilder(column: $table.yearBegan, builder: (column) => column);

  GeneratedColumn<int> get yearEnd =>
      $composableBuilder(column: $table.yearEnd, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get issueCount => $composableBuilder(
    column: $table.issueCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get computedCoverUrl => $composableBuilder(
    column: $table.computedCoverUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronSeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronSeriesTable,
          MetronSery,
          $$MetronSeriesTableFilterComposer,
          $$MetronSeriesTableOrderingComposer,
          $$MetronSeriesTableAnnotationComposer,
          $$MetronSeriesTableCreateCompanionBuilder,
          $$MetronSeriesTableUpdateCompanionBuilder,
          (
            MetronSery,
            BaseReferences<_$AppDatabase, $MetronSeriesTable, MetronSery>,
          ),
          MetronSery,
          PrefetchHooks Function()
        > {
  $$MetronSeriesTableTableManager(_$AppDatabase db, $MetronSeriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sortName = const Value.absent(),
                Value<int?> volume = const Value.absent(),
                Value<int?> seriesTypeId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<int?> imprintId = const Value.absent(),
                Value<int?> yearBegan = const Value.absent(),
                Value<int?> yearEnd = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> issueCount = const Value.absent(),
                Value<String?> computedCoverUrl = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronSeriesCompanion(
                id: id,
                name: name,
                sortName: sortName,
                volume: volume,
                seriesTypeId: seriesTypeId,
                status: status,
                publisherId: publisherId,
                imprintId: imprintId,
                yearBegan: yearBegan,
                yearEnd: yearEnd,
                description: description,
                issueCount: issueCount,
                computedCoverUrl: computedCoverUrl,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> sortName = const Value.absent(),
                Value<int?> volume = const Value.absent(),
                Value<int?> seriesTypeId = const Value.absent(),
                Value<String?> status = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<int?> imprintId = const Value.absent(),
                Value<int?> yearBegan = const Value.absent(),
                Value<int?> yearEnd = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> issueCount = const Value.absent(),
                Value<String?> computedCoverUrl = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronSeriesCompanion.insert(
                id: id,
                name: name,
                sortName: sortName,
                volume: volume,
                seriesTypeId: seriesTypeId,
                status: status,
                publisherId: publisherId,
                imprintId: imprintId,
                yearBegan: yearBegan,
                yearEnd: yearEnd,
                description: description,
                issueCount: issueCount,
                computedCoverUrl: computedCoverUrl,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronSeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronSeriesTable,
      MetronSery,
      $$MetronSeriesTableFilterComposer,
      $$MetronSeriesTableOrderingComposer,
      $$MetronSeriesTableAnnotationComposer,
      $$MetronSeriesTableCreateCompanionBuilder,
      $$MetronSeriesTableUpdateCompanionBuilder,
      (
        MetronSery,
        BaseReferences<_$AppDatabase, $MetronSeriesTable, MetronSery>,
      ),
      MetronSery,
      PrefetchHooks Function()
    >;
typedef $$MetronCreatorsTableCreateCompanionBuilder =
    MetronCreatorsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String?> birth,
      Value<String?> death,
      Value<String?> aliasJson,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronCreatorsTableUpdateCompanionBuilder =
    MetronCreatorsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String?> birth,
      Value<String?> death,
      Value<String?> aliasJson,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronCreatorsTableFilterComposer
    extends Composer<_$AppDatabase, $MetronCreatorsTable> {
  $$MetronCreatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birth => $composableBuilder(
    column: $table.birth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get death => $composableBuilder(
    column: $table.death,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasJson => $composableBuilder(
    column: $table.aliasJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronCreatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronCreatorsTable> {
  $$MetronCreatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birth => $composableBuilder(
    column: $table.birth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get death => $composableBuilder(
    column: $table.death,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasJson => $composableBuilder(
    column: $table.aliasJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronCreatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronCreatorsTable> {
  $$MetronCreatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get birth =>
      $composableBuilder(column: $table.birth, builder: (column) => column);

  GeneratedColumn<String> get death =>
      $composableBuilder(column: $table.death, builder: (column) => column);

  GeneratedColumn<String> get aliasJson =>
      $composableBuilder(column: $table.aliasJson, builder: (column) => column);

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronCreatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronCreatorsTable,
          MetronCreator,
          $$MetronCreatorsTableFilterComposer,
          $$MetronCreatorsTableOrderingComposer,
          $$MetronCreatorsTableAnnotationComposer,
          $$MetronCreatorsTableCreateCompanionBuilder,
          $$MetronCreatorsTableUpdateCompanionBuilder,
          (
            MetronCreator,
            BaseReferences<_$AppDatabase, $MetronCreatorsTable, MetronCreator>,
          ),
          MetronCreator,
          PrefetchHooks Function()
        > {
  $$MetronCreatorsTableTableManager(
    _$AppDatabase db,
    $MetronCreatorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronCreatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronCreatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronCreatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> birth = const Value.absent(),
                Value<String?> death = const Value.absent(),
                Value<String?> aliasJson = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronCreatorsCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                birth: birth,
                death: death,
                aliasJson: aliasJson,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> birth = const Value.absent(),
                Value<String?> death = const Value.absent(),
                Value<String?> aliasJson = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronCreatorsCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                birth: birth,
                death: death,
                aliasJson: aliasJson,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronCreatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronCreatorsTable,
      MetronCreator,
      $$MetronCreatorsTableFilterComposer,
      $$MetronCreatorsTableOrderingComposer,
      $$MetronCreatorsTableAnnotationComposer,
      $$MetronCreatorsTableCreateCompanionBuilder,
      $$MetronCreatorsTableUpdateCompanionBuilder,
      (
        MetronCreator,
        BaseReferences<_$AppDatabase, $MetronCreatorsTable, MetronCreator>,
      ),
      MetronCreator,
      PrefetchHooks Function()
    >;
typedef $$MetronCharactersTableCreateCompanionBuilder =
    MetronCharactersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String?> aliasJson,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronCharactersTableUpdateCompanionBuilder =
    MetronCharactersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String?> aliasJson,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronCharactersTableFilterComposer
    extends Composer<_$AppDatabase, $MetronCharactersTable> {
  $$MetronCharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasJson => $composableBuilder(
    column: $table.aliasJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronCharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronCharactersTable> {
  $$MetronCharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasJson => $composableBuilder(
    column: $table.aliasJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronCharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronCharactersTable> {
  $$MetronCharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aliasJson =>
      $composableBuilder(column: $table.aliasJson, builder: (column) => column);

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronCharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronCharactersTable,
          MetronCharacter,
          $$MetronCharactersTableFilterComposer,
          $$MetronCharactersTableOrderingComposer,
          $$MetronCharactersTableAnnotationComposer,
          $$MetronCharactersTableCreateCompanionBuilder,
          $$MetronCharactersTableUpdateCompanionBuilder,
          (
            MetronCharacter,
            BaseReferences<
              _$AppDatabase,
              $MetronCharactersTable,
              MetronCharacter
            >,
          ),
          MetronCharacter,
          PrefetchHooks Function()
        > {
  $$MetronCharactersTableTableManager(
    _$AppDatabase db,
    $MetronCharactersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronCharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronCharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronCharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> aliasJson = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronCharactersCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                aliasJson: aliasJson,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> aliasJson = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronCharactersCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                aliasJson: aliasJson,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronCharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronCharactersTable,
      MetronCharacter,
      $$MetronCharactersTableFilterComposer,
      $$MetronCharactersTableOrderingComposer,
      $$MetronCharactersTableAnnotationComposer,
      $$MetronCharactersTableCreateCompanionBuilder,
      $$MetronCharactersTableUpdateCompanionBuilder,
      (
        MetronCharacter,
        BaseReferences<_$AppDatabase, $MetronCharactersTable, MetronCharacter>,
      ),
      MetronCharacter,
      PrefetchHooks Function()
    >;
typedef $$MetronArcsTableCreateCompanionBuilder =
    MetronArcsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronArcsTableUpdateCompanionBuilder =
    MetronArcsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronArcsTableFilterComposer
    extends Composer<_$AppDatabase, $MetronArcsTable> {
  $$MetronArcsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronArcsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronArcsTable> {
  $$MetronArcsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronArcsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronArcsTable> {
  $$MetronArcsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronArcsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronArcsTable,
          MetronArc,
          $$MetronArcsTableFilterComposer,
          $$MetronArcsTableOrderingComposer,
          $$MetronArcsTableAnnotationComposer,
          $$MetronArcsTableCreateCompanionBuilder,
          $$MetronArcsTableUpdateCompanionBuilder,
          (
            MetronArc,
            BaseReferences<_$AppDatabase, $MetronArcsTable, MetronArc>,
          ),
          MetronArc,
          PrefetchHooks Function()
        > {
  $$MetronArcsTableTableManager(_$AppDatabase db, $MetronArcsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronArcsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronArcsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronArcsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronArcsCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronArcsCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronArcsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronArcsTable,
      MetronArc,
      $$MetronArcsTableFilterComposer,
      $$MetronArcsTableOrderingComposer,
      $$MetronArcsTableAnnotationComposer,
      $$MetronArcsTableCreateCompanionBuilder,
      $$MetronArcsTableUpdateCompanionBuilder,
      (MetronArc, BaseReferences<_$AppDatabase, $MetronArcsTable, MetronArc>),
      MetronArc,
      PrefetchHooks Function()
    >;
typedef $$MetronTeamsTableCreateCompanionBuilder =
    MetronTeamsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronTeamsTableUpdateCompanionBuilder =
    MetronTeamsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $MetronTeamsTable> {
  $$MetronTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronTeamsTable> {
  $$MetronTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronTeamsTable> {
  $$MetronTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronTeamsTable,
          MetronTeam,
          $$MetronTeamsTableFilterComposer,
          $$MetronTeamsTableOrderingComposer,
          $$MetronTeamsTableAnnotationComposer,
          $$MetronTeamsTableCreateCompanionBuilder,
          $$MetronTeamsTableUpdateCompanionBuilder,
          (
            MetronTeam,
            BaseReferences<_$AppDatabase, $MetronTeamsTable, MetronTeam>,
          ),
          MetronTeam,
          PrefetchHooks Function()
        > {
  $$MetronTeamsTableTableManager(_$AppDatabase db, $MetronTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronTeamsCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronTeamsCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronTeamsTable,
      MetronTeam,
      $$MetronTeamsTableFilterComposer,
      $$MetronTeamsTableOrderingComposer,
      $$MetronTeamsTableAnnotationComposer,
      $$MetronTeamsTableCreateCompanionBuilder,
      $$MetronTeamsTableUpdateCompanionBuilder,
      (
        MetronTeam,
        BaseReferences<_$AppDatabase, $MetronTeamsTable, MetronTeam>,
      ),
      MetronTeam,
      PrefetchHooks Function()
    >;
typedef $$MetronUniversesTableCreateCompanionBuilder =
    MetronUniversesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> designation,
      Value<int?> publisherId,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronUniversesTableUpdateCompanionBuilder =
    MetronUniversesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> designation,
      Value<int?> publisherId,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronUniversesTableFilterComposer
    extends Composer<_$AppDatabase, $MetronUniversesTable> {
  $$MetronUniversesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronUniversesTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronUniversesTable> {
  $$MetronUniversesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronUniversesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronUniversesTable> {
  $$MetronUniversesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronUniversesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronUniversesTable,
          MetronUniverse,
          $$MetronUniversesTableFilterComposer,
          $$MetronUniversesTableOrderingComposer,
          $$MetronUniversesTableAnnotationComposer,
          $$MetronUniversesTableCreateCompanionBuilder,
          $$MetronUniversesTableUpdateCompanionBuilder,
          (
            MetronUniverse,
            BaseReferences<
              _$AppDatabase,
              $MetronUniversesTable,
              MetronUniverse
            >,
          ),
          MetronUniverse,
          PrefetchHooks Function()
        > {
  $$MetronUniversesTableTableManager(
    _$AppDatabase db,
    $MetronUniversesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronUniversesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronUniversesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronUniversesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> designation = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronUniversesCompanion(
                id: id,
                name: name,
                designation: designation,
                publisherId: publisherId,
                imageUrl: imageUrl,
                description: description,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> designation = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronUniversesCompanion.insert(
                id: id,
                name: name,
                designation: designation,
                publisherId: publisherId,
                imageUrl: imageUrl,
                description: description,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronUniversesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronUniversesTable,
      MetronUniverse,
      $$MetronUniversesTableFilterComposer,
      $$MetronUniversesTableOrderingComposer,
      $$MetronUniversesTableAnnotationComposer,
      $$MetronUniversesTableCreateCompanionBuilder,
      $$MetronUniversesTableUpdateCompanionBuilder,
      (
        MetronUniverse,
        BaseReferences<_$AppDatabase, $MetronUniversesTable, MetronUniverse>,
      ),
      MetronUniverse,
      PrefetchHooks Function()
    >;
typedef $$MetronPublishersTableCreateCompanionBuilder =
    MetronPublishersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String?> country,
      Value<int?> founded,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronPublishersTableUpdateCompanionBuilder =
    MetronPublishersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<String?> country,
      Value<int?> founded,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronPublishersTableFilterComposer
    extends Composer<_$AppDatabase, $MetronPublishersTable> {
  $$MetronPublishersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get founded => $composableBuilder(
    column: $table.founded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronPublishersTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronPublishersTable> {
  $$MetronPublishersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get founded => $composableBuilder(
    column: $table.founded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronPublishersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronPublishersTable> {
  $$MetronPublishersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<int> get founded =>
      $composableBuilder(column: $table.founded, builder: (column) => column);

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronPublishersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronPublishersTable,
          MetronPublisher,
          $$MetronPublishersTableFilterComposer,
          $$MetronPublishersTableOrderingComposer,
          $$MetronPublishersTableAnnotationComposer,
          $$MetronPublishersTableCreateCompanionBuilder,
          $$MetronPublishersTableUpdateCompanionBuilder,
          (
            MetronPublisher,
            BaseReferences<
              _$AppDatabase,
              $MetronPublishersTable,
              MetronPublisher
            >,
          ),
          MetronPublisher,
          PrefetchHooks Function()
        > {
  $$MetronPublishersTableTableManager(
    _$AppDatabase db,
    $MetronPublishersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronPublishersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronPublishersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronPublishersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<int?> founded = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronPublishersCompanion(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                country: country,
                founded: founded,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<int?> founded = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronPublishersCompanion.insert(
                id: id,
                name: name,
                imageUrl: imageUrl,
                description: description,
                country: country,
                founded: founded,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronPublishersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronPublishersTable,
      MetronPublisher,
      $$MetronPublishersTableFilterComposer,
      $$MetronPublishersTableOrderingComposer,
      $$MetronPublishersTableAnnotationComposer,
      $$MetronPublishersTableCreateCompanionBuilder,
      $$MetronPublishersTableUpdateCompanionBuilder,
      (
        MetronPublisher,
        BaseReferences<_$AppDatabase, $MetronPublishersTable, MetronPublisher>,
      ),
      MetronPublisher,
      PrefetchHooks Function()
    >;
typedef $$MetronImprintsTableCreateCompanionBuilder =
    MetronImprintsCompanion Function({
      Value<int> id,
      required String name,
      Value<int?> publisherId,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> founded,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronImprintsTableUpdateCompanionBuilder =
    MetronImprintsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int?> publisherId,
      Value<String?> imageUrl,
      Value<String?> description,
      Value<int?> founded,
      Value<int?> cvId,
      Value<int?> gcdId,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronImprintsTableFilterComposer
    extends Composer<_$AppDatabase, $MetronImprintsTable> {
  $$MetronImprintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get founded => $composableBuilder(
    column: $table.founded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronImprintsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronImprintsTable> {
  $$MetronImprintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get founded => $composableBuilder(
    column: $table.founded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cvId => $composableBuilder(
    column: $table.cvId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gcdId => $composableBuilder(
    column: $table.gcdId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronImprintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronImprintsTable> {
  $$MetronImprintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get publisherId => $composableBuilder(
    column: $table.publisherId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get founded =>
      $composableBuilder(column: $table.founded, builder: (column) => column);

  GeneratedColumn<int> get cvId =>
      $composableBuilder(column: $table.cvId, builder: (column) => column);

  GeneratedColumn<int> get gcdId =>
      $composableBuilder(column: $table.gcdId, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronImprintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronImprintsTable,
          MetronImprint,
          $$MetronImprintsTableFilterComposer,
          $$MetronImprintsTableOrderingComposer,
          $$MetronImprintsTableAnnotationComposer,
          $$MetronImprintsTableCreateCompanionBuilder,
          $$MetronImprintsTableUpdateCompanionBuilder,
          (
            MetronImprint,
            BaseReferences<_$AppDatabase, $MetronImprintsTable, MetronImprint>,
          ),
          MetronImprint,
          PrefetchHooks Function()
        > {
  $$MetronImprintsTableTableManager(
    _$AppDatabase db,
    $MetronImprintsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronImprintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronImprintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronImprintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> publisherId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> founded = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronImprintsCompanion(
                id: id,
                name: name,
                publisherId: publisherId,
                imageUrl: imageUrl,
                description: description,
                founded: founded,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> publisherId = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> founded = const Value.absent(),
                Value<int?> cvId = const Value.absent(),
                Value<int?> gcdId = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronImprintsCompanion.insert(
                id: id,
                name: name,
                publisherId: publisherId,
                imageUrl: imageUrl,
                description: description,
                founded: founded,
                cvId: cvId,
                gcdId: gcdId,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronImprintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronImprintsTable,
      MetronImprint,
      $$MetronImprintsTableFilterComposer,
      $$MetronImprintsTableOrderingComposer,
      $$MetronImprintsTableAnnotationComposer,
      $$MetronImprintsTableCreateCompanionBuilder,
      $$MetronImprintsTableUpdateCompanionBuilder,
      (
        MetronImprint,
        BaseReferences<_$AppDatabase, $MetronImprintsTable, MetronImprint>,
      ),
      MetronImprint,
      PrefetchHooks Function()
    >;
typedef $$MetronReadingListsTableCreateCompanionBuilder =
    MetronReadingListsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> slug,
      Value<int?> userId,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String?> listType,
      Value<bool?> isPrivate,
      Value<String?> attributionSource,
      Value<String?> attributionUrl,
      Value<double?> averageRating,
      Value<int?> ratingCount,
      Value<String?> itemsUrl,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });
typedef $$MetronReadingListsTableUpdateCompanionBuilder =
    MetronReadingListsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> slug,
      Value<int?> userId,
      Value<String?> description,
      Value<String?> imageUrl,
      Value<String?> listType,
      Value<bool?> isPrivate,
      Value<String?> attributionSource,
      Value<String?> attributionUrl,
      Value<double?> averageRating,
      Value<int?> ratingCount,
      Value<String?> itemsUrl,
      Value<String?> resourceUrl,
      Value<String?> modified,
      Value<bool> isFullyHydrated,
    });

class $$MetronReadingListsTableFilterComposer
    extends Composer<_$AppDatabase, $MetronReadingListsTable> {
  $$MetronReadingListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listType => $composableBuilder(
    column: $table.listType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributionSource => $composableBuilder(
    column: $table.attributionSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attributionUrl => $composableBuilder(
    column: $table.attributionUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ratingCount => $composableBuilder(
    column: $table.ratingCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsUrl => $composableBuilder(
    column: $table.itemsUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronReadingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronReadingListsTable> {
  $$MetronReadingListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listType => $composableBuilder(
    column: $table.listType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributionSource => $composableBuilder(
    column: $table.attributionSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attributionUrl => $composableBuilder(
    column: $table.attributionUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ratingCount => $composableBuilder(
    column: $table.ratingCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsUrl => $composableBuilder(
    column: $table.itemsUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modified => $composableBuilder(
    column: $table.modified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronReadingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronReadingListsTable> {
  $$MetronReadingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get listType =>
      $composableBuilder(column: $table.listType, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  GeneratedColumn<String> get attributionSource => $composableBuilder(
    column: $table.attributionSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attributionUrl => $composableBuilder(
    column: $table.attributionUrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageRating => $composableBuilder(
    column: $table.averageRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ratingCount => $composableBuilder(
    column: $table.ratingCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemsUrl =>
      $composableBuilder(column: $table.itemsUrl, builder: (column) => column);

  GeneratedColumn<String> get resourceUrl => $composableBuilder(
    column: $table.resourceUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modified =>
      $composableBuilder(column: $table.modified, builder: (column) => column);

  GeneratedColumn<bool> get isFullyHydrated => $composableBuilder(
    column: $table.isFullyHydrated,
    builder: (column) => column,
  );
}

class $$MetronReadingListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronReadingListsTable,
          MetronReadingList,
          $$MetronReadingListsTableFilterComposer,
          $$MetronReadingListsTableOrderingComposer,
          $$MetronReadingListsTableAnnotationComposer,
          $$MetronReadingListsTableCreateCompanionBuilder,
          $$MetronReadingListsTableUpdateCompanionBuilder,
          (
            MetronReadingList,
            BaseReferences<
              _$AppDatabase,
              $MetronReadingListsTable,
              MetronReadingList
            >,
          ),
          MetronReadingList,
          PrefetchHooks Function()
        > {
  $$MetronReadingListsTableTableManager(
    _$AppDatabase db,
    $MetronReadingListsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronReadingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetronReadingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetronReadingListsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> listType = const Value.absent(),
                Value<bool?> isPrivate = const Value.absent(),
                Value<String?> attributionSource = const Value.absent(),
                Value<String?> attributionUrl = const Value.absent(),
                Value<double?> averageRating = const Value.absent(),
                Value<int?> ratingCount = const Value.absent(),
                Value<String?> itemsUrl = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronReadingListsCompanion(
                id: id,
                name: name,
                slug: slug,
                userId: userId,
                description: description,
                imageUrl: imageUrl,
                listType: listType,
                isPrivate: isPrivate,
                attributionSource: attributionSource,
                attributionUrl: attributionUrl,
                averageRating: averageRating,
                ratingCount: ratingCount,
                itemsUrl: itemsUrl,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> slug = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> listType = const Value.absent(),
                Value<bool?> isPrivate = const Value.absent(),
                Value<String?> attributionSource = const Value.absent(),
                Value<String?> attributionUrl = const Value.absent(),
                Value<double?> averageRating = const Value.absent(),
                Value<int?> ratingCount = const Value.absent(),
                Value<String?> itemsUrl = const Value.absent(),
                Value<String?> resourceUrl = const Value.absent(),
                Value<String?> modified = const Value.absent(),
                Value<bool> isFullyHydrated = const Value.absent(),
              }) => MetronReadingListsCompanion.insert(
                id: id,
                name: name,
                slug: slug,
                userId: userId,
                description: description,
                imageUrl: imageUrl,
                listType: listType,
                isPrivate: isPrivate,
                attributionSource: attributionSource,
                attributionUrl: attributionUrl,
                averageRating: averageRating,
                ratingCount: ratingCount,
                itemsUrl: itemsUrl,
                resourceUrl: resourceUrl,
                modified: modified,
                isFullyHydrated: isFullyHydrated,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronReadingListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronReadingListsTable,
      MetronReadingList,
      $$MetronReadingListsTableFilterComposer,
      $$MetronReadingListsTableOrderingComposer,
      $$MetronReadingListsTableAnnotationComposer,
      $$MetronReadingListsTableCreateCompanionBuilder,
      $$MetronReadingListsTableUpdateCompanionBuilder,
      (
        MetronReadingList,
        BaseReferences<
          _$AppDatabase,
          $MetronReadingListsTable,
          MetronReadingList
        >,
      ),
      MetronReadingList,
      PrefetchHooks Function()
    >;
typedef $$IssueCreatorsTableCreateCompanionBuilder =
    IssueCreatorsCompanion Function({
      required int issueId,
      required int creatorId,
      Value<String?> role,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $$IssueCreatorsTableUpdateCompanionBuilder =
    IssueCreatorsCompanion Function({
      Value<int> issueId,
      Value<int> creatorId,
      Value<String?> role,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $$IssueCreatorsTableFilterComposer
    extends Composer<_$AppDatabase, $IssueCreatorsTable> {
  $$IssueCreatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueCreatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueCreatorsTable> {
  $$IssueCreatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueCreatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueCreatorsTable> {
  $$IssueCreatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$IssueCreatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueCreatorsTable,
          IssueCreator,
          $$IssueCreatorsTableFilterComposer,
          $$IssueCreatorsTableOrderingComposer,
          $$IssueCreatorsTableAnnotationComposer,
          $$IssueCreatorsTableCreateCompanionBuilder,
          $$IssueCreatorsTableUpdateCompanionBuilder,
          (
            IssueCreator,
            BaseReferences<_$AppDatabase, $IssueCreatorsTable, IssueCreator>,
          ),
          IssueCreator,
          PrefetchHooks Function()
        > {
  $$IssueCreatorsTableTableManager(_$AppDatabase db, $IssueCreatorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueCreatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueCreatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueCreatorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> issueId = const Value.absent(),
                Value<int> creatorId = const Value.absent(),
                Value<String?> role = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueCreatorsCompanion(
                issueId: issueId,
                creatorId: creatorId,
                role: role,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int issueId,
                required int creatorId,
                Value<String?> role = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueCreatorsCompanion.insert(
                issueId: issueId,
                creatorId: creatorId,
                role: role,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueCreatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueCreatorsTable,
      IssueCreator,
      $$IssueCreatorsTableFilterComposer,
      $$IssueCreatorsTableOrderingComposer,
      $$IssueCreatorsTableAnnotationComposer,
      $$IssueCreatorsTableCreateCompanionBuilder,
      $$IssueCreatorsTableUpdateCompanionBuilder,
      (
        IssueCreator,
        BaseReferences<_$AppDatabase, $IssueCreatorsTable, IssueCreator>,
      ),
      IssueCreator,
      PrefetchHooks Function()
    >;
typedef $$IssueCharactersTableCreateCompanionBuilder =
    IssueCharactersCompanion Function({
      required int issueId,
      required int characterId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $$IssueCharactersTableUpdateCompanionBuilder =
    IssueCharactersCompanion Function({
      Value<int> issueId,
      Value<int> characterId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $$IssueCharactersTableFilterComposer
    extends Composer<_$AppDatabase, $IssueCharactersTable> {
  $$IssueCharactersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueCharactersTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueCharactersTable> {
  $$IssueCharactersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueCharactersTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueCharactersTable> {
  $$IssueCharactersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$IssueCharactersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueCharactersTable,
          IssueCharacter,
          $$IssueCharactersTableFilterComposer,
          $$IssueCharactersTableOrderingComposer,
          $$IssueCharactersTableAnnotationComposer,
          $$IssueCharactersTableCreateCompanionBuilder,
          $$IssueCharactersTableUpdateCompanionBuilder,
          (
            IssueCharacter,
            BaseReferences<
              _$AppDatabase,
              $IssueCharactersTable,
              IssueCharacter
            >,
          ),
          IssueCharacter,
          PrefetchHooks Function()
        > {
  $$IssueCharactersTableTableManager(
    _$AppDatabase db,
    $IssueCharactersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueCharactersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueCharactersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueCharactersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> issueId = const Value.absent(),
                Value<int> characterId = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueCharactersCompanion(
                issueId: issueId,
                characterId: characterId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int issueId,
                required int characterId,
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueCharactersCompanion.insert(
                issueId: issueId,
                characterId: characterId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueCharactersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueCharactersTable,
      IssueCharacter,
      $$IssueCharactersTableFilterComposer,
      $$IssueCharactersTableOrderingComposer,
      $$IssueCharactersTableAnnotationComposer,
      $$IssueCharactersTableCreateCompanionBuilder,
      $$IssueCharactersTableUpdateCompanionBuilder,
      (
        IssueCharacter,
        BaseReferences<_$AppDatabase, $IssueCharactersTable, IssueCharacter>,
      ),
      IssueCharacter,
      PrefetchHooks Function()
    >;
typedef $$IssueArcsTableCreateCompanionBuilder =
    IssueArcsCompanion Function({
      required int issueId,
      required int arcId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $$IssueArcsTableUpdateCompanionBuilder =
    IssueArcsCompanion Function({
      Value<int> issueId,
      Value<int> arcId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $$IssueArcsTableFilterComposer
    extends Composer<_$AppDatabase, $IssueArcsTable> {
  $$IssueArcsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arcId => $composableBuilder(
    column: $table.arcId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueArcsTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueArcsTable> {
  $$IssueArcsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arcId => $composableBuilder(
    column: $table.arcId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueArcsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueArcsTable> {
  $$IssueArcsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<int> get arcId =>
      $composableBuilder(column: $table.arcId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$IssueArcsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueArcsTable,
          IssueArc,
          $$IssueArcsTableFilterComposer,
          $$IssueArcsTableOrderingComposer,
          $$IssueArcsTableAnnotationComposer,
          $$IssueArcsTableCreateCompanionBuilder,
          $$IssueArcsTableUpdateCompanionBuilder,
          (IssueArc, BaseReferences<_$AppDatabase, $IssueArcsTable, IssueArc>),
          IssueArc,
          PrefetchHooks Function()
        > {
  $$IssueArcsTableTableManager(_$AppDatabase db, $IssueArcsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueArcsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueArcsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueArcsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> issueId = const Value.absent(),
                Value<int> arcId = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueArcsCompanion(
                issueId: issueId,
                arcId: arcId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int issueId,
                required int arcId,
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueArcsCompanion.insert(
                issueId: issueId,
                arcId: arcId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueArcsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueArcsTable,
      IssueArc,
      $$IssueArcsTableFilterComposer,
      $$IssueArcsTableOrderingComposer,
      $$IssueArcsTableAnnotationComposer,
      $$IssueArcsTableCreateCompanionBuilder,
      $$IssueArcsTableUpdateCompanionBuilder,
      (IssueArc, BaseReferences<_$AppDatabase, $IssueArcsTable, IssueArc>),
      IssueArc,
      PrefetchHooks Function()
    >;
typedef $$IssueTeamsTableCreateCompanionBuilder =
    IssueTeamsCompanion Function({
      required int issueId,
      required int teamId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $$IssueTeamsTableUpdateCompanionBuilder =
    IssueTeamsCompanion Function({
      Value<int> issueId,
      Value<int> teamId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $$IssueTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $IssueTeamsTable> {
  $$IssueTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueTeamsTable> {
  $$IssueTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueTeamsTable> {
  $$IssueTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<int> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$IssueTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueTeamsTable,
          IssueTeam,
          $$IssueTeamsTableFilterComposer,
          $$IssueTeamsTableOrderingComposer,
          $$IssueTeamsTableAnnotationComposer,
          $$IssueTeamsTableCreateCompanionBuilder,
          $$IssueTeamsTableUpdateCompanionBuilder,
          (
            IssueTeam,
            BaseReferences<_$AppDatabase, $IssueTeamsTable, IssueTeam>,
          ),
          IssueTeam,
          PrefetchHooks Function()
        > {
  $$IssueTeamsTableTableManager(_$AppDatabase db, $IssueTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> issueId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueTeamsCompanion(
                issueId: issueId,
                teamId: teamId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int issueId,
                required int teamId,
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueTeamsCompanion.insert(
                issueId: issueId,
                teamId: teamId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueTeamsTable,
      IssueTeam,
      $$IssueTeamsTableFilterComposer,
      $$IssueTeamsTableOrderingComposer,
      $$IssueTeamsTableAnnotationComposer,
      $$IssueTeamsTableCreateCompanionBuilder,
      $$IssueTeamsTableUpdateCompanionBuilder,
      (IssueTeam, BaseReferences<_$AppDatabase, $IssueTeamsTable, IssueTeam>),
      IssueTeam,
      PrefetchHooks Function()
    >;
typedef $$IssueUniversesTableCreateCompanionBuilder =
    IssueUniversesCompanion Function({
      required int issueId,
      required int universeId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });
typedef $$IssueUniversesTableUpdateCompanionBuilder =
    IssueUniversesCompanion Function({
      Value<int> issueId,
      Value<int> universeId,
      Value<int?> sortOrder,
      Value<int> rowid,
    });

class $$IssueUniversesTableFilterComposer
    extends Composer<_$AppDatabase, $IssueUniversesTable> {
  $$IssueUniversesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueUniversesTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueUniversesTable> {
  $$IssueUniversesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueUniversesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueUniversesTable> {
  $$IssueUniversesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$IssueUniversesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueUniversesTable,
          IssueUniverse,
          $$IssueUniversesTableFilterComposer,
          $$IssueUniversesTableOrderingComposer,
          $$IssueUniversesTableAnnotationComposer,
          $$IssueUniversesTableCreateCompanionBuilder,
          $$IssueUniversesTableUpdateCompanionBuilder,
          (
            IssueUniverse,
            BaseReferences<_$AppDatabase, $IssueUniversesTable, IssueUniverse>,
          ),
          IssueUniverse,
          PrefetchHooks Function()
        > {
  $$IssueUniversesTableTableManager(
    _$AppDatabase db,
    $IssueUniversesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueUniversesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueUniversesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueUniversesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> issueId = const Value.absent(),
                Value<int> universeId = const Value.absent(),
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueUniversesCompanion(
                issueId: issueId,
                universeId: universeId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int issueId,
                required int universeId,
                Value<int?> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueUniversesCompanion.insert(
                issueId: issueId,
                universeId: universeId,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueUniversesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueUniversesTable,
      IssueUniverse,
      $$IssueUniversesTableFilterComposer,
      $$IssueUniversesTableOrderingComposer,
      $$IssueUniversesTableAnnotationComposer,
      $$IssueUniversesTableCreateCompanionBuilder,
      $$IssueUniversesTableUpdateCompanionBuilder,
      (
        IssueUniverse,
        BaseReferences<_$AppDatabase, $IssueUniversesTable, IssueUniverse>,
      ),
      IssueUniverse,
      PrefetchHooks Function()
    >;
typedef $$IssueImprintsTableCreateCompanionBuilder =
    IssueImprintsCompanion Function({
      required int issueId,
      required int imprintId,
      Value<int> rowid,
    });
typedef $$IssueImprintsTableUpdateCompanionBuilder =
    IssueImprintsCompanion Function({
      Value<int> issueId,
      Value<int> imprintId,
      Value<int> rowid,
    });

class $$IssueImprintsTableFilterComposer
    extends Composer<_$AppDatabase, $IssueImprintsTable> {
  $$IssueImprintsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get imprintId => $composableBuilder(
    column: $table.imprintId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IssueImprintsTableOrderingComposer
    extends Composer<_$AppDatabase, $IssueImprintsTable> {
  $$IssueImprintsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get issueId => $composableBuilder(
    column: $table.issueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get imprintId => $composableBuilder(
    column: $table.imprintId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IssueImprintsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IssueImprintsTable> {
  $$IssueImprintsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get issueId =>
      $composableBuilder(column: $table.issueId, builder: (column) => column);

  GeneratedColumn<int> get imprintId =>
      $composableBuilder(column: $table.imprintId, builder: (column) => column);
}

class $$IssueImprintsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IssueImprintsTable,
          IssueImprint,
          $$IssueImprintsTableFilterComposer,
          $$IssueImprintsTableOrderingComposer,
          $$IssueImprintsTableAnnotationComposer,
          $$IssueImprintsTableCreateCompanionBuilder,
          $$IssueImprintsTableUpdateCompanionBuilder,
          (
            IssueImprint,
            BaseReferences<_$AppDatabase, $IssueImprintsTable, IssueImprint>,
          ),
          IssueImprint,
          PrefetchHooks Function()
        > {
  $$IssueImprintsTableTableManager(_$AppDatabase db, $IssueImprintsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IssueImprintsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IssueImprintsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IssueImprintsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> issueId = const Value.absent(),
                Value<int> imprintId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IssueImprintsCompanion(
                issueId: issueId,
                imprintId: imprintId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int issueId,
                required int imprintId,
                Value<int> rowid = const Value.absent(),
              }) => IssueImprintsCompanion.insert(
                issueId: issueId,
                imprintId: imprintId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IssueImprintsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IssueImprintsTable,
      IssueImprint,
      $$IssueImprintsTableFilterComposer,
      $$IssueImprintsTableOrderingComposer,
      $$IssueImprintsTableAnnotationComposer,
      $$IssueImprintsTableCreateCompanionBuilder,
      $$IssueImprintsTableUpdateCompanionBuilder,
      (
        IssueImprint,
        BaseReferences<_$AppDatabase, $IssueImprintsTable, IssueImprint>,
      ),
      IssueImprint,
      PrefetchHooks Function()
    >;
typedef $$SeriesArcsTableCreateCompanionBuilder =
    SeriesArcsCompanion Function({
      required int seriesId,
      required int arcId,
      Value<int> rowid,
    });
typedef $$SeriesArcsTableUpdateCompanionBuilder =
    SeriesArcsCompanion Function({
      Value<int> seriesId,
      Value<int> arcId,
      Value<int> rowid,
    });

class $$SeriesArcsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesArcsTable> {
  $$SeriesArcsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arcId => $composableBuilder(
    column: $table.arcId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesArcsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesArcsTable> {
  $$SeriesArcsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arcId => $composableBuilder(
    column: $table.arcId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesArcsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesArcsTable> {
  $$SeriesArcsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get arcId =>
      $composableBuilder(column: $table.arcId, builder: (column) => column);
}

class $$SeriesArcsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesArcsTable,
          SeriesArc,
          $$SeriesArcsTableFilterComposer,
          $$SeriesArcsTableOrderingComposer,
          $$SeriesArcsTableAnnotationComposer,
          $$SeriesArcsTableCreateCompanionBuilder,
          $$SeriesArcsTableUpdateCompanionBuilder,
          (
            SeriesArc,
            BaseReferences<_$AppDatabase, $SeriesArcsTable, SeriesArc>,
          ),
          SeriesArc,
          PrefetchHooks Function()
        > {
  $$SeriesArcsTableTableManager(_$AppDatabase db, $SeriesArcsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesArcsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesArcsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesArcsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seriesId = const Value.absent(),
                Value<int> arcId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesArcsCompanion(
                seriesId: seriesId,
                arcId: arcId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seriesId,
                required int arcId,
                Value<int> rowid = const Value.absent(),
              }) => SeriesArcsCompanion.insert(
                seriesId: seriesId,
                arcId: arcId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesArcsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesArcsTable,
      SeriesArc,
      $$SeriesArcsTableFilterComposer,
      $$SeriesArcsTableOrderingComposer,
      $$SeriesArcsTableAnnotationComposer,
      $$SeriesArcsTableCreateCompanionBuilder,
      $$SeriesArcsTableUpdateCompanionBuilder,
      (SeriesArc, BaseReferences<_$AppDatabase, $SeriesArcsTable, SeriesArc>),
      SeriesArc,
      PrefetchHooks Function()
    >;
typedef $$SeriesTeamsTableCreateCompanionBuilder =
    SeriesTeamsCompanion Function({
      required int seriesId,
      required int teamId,
      Value<int> rowid,
    });
typedef $$SeriesTeamsTableUpdateCompanionBuilder =
    SeriesTeamsCompanion Function({
      Value<int> seriesId,
      Value<int> teamId,
      Value<int> rowid,
    });

class $$SeriesTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesTeamsTable> {
  $$SeriesTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesTeamsTable> {
  $$SeriesTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesTeamsTable> {
  $$SeriesTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);
}

class $$SeriesTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesTeamsTable,
          SeriesTeam,
          $$SeriesTeamsTableFilterComposer,
          $$SeriesTeamsTableOrderingComposer,
          $$SeriesTeamsTableAnnotationComposer,
          $$SeriesTeamsTableCreateCompanionBuilder,
          $$SeriesTeamsTableUpdateCompanionBuilder,
          (
            SeriesTeam,
            BaseReferences<_$AppDatabase, $SeriesTeamsTable, SeriesTeam>,
          ),
          SeriesTeam,
          PrefetchHooks Function()
        > {
  $$SeriesTeamsTableTableManager(_$AppDatabase db, $SeriesTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seriesId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesTeamsCompanion(
                seriesId: seriesId,
                teamId: teamId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seriesId,
                required int teamId,
                Value<int> rowid = const Value.absent(),
              }) => SeriesTeamsCompanion.insert(
                seriesId: seriesId,
                teamId: teamId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesTeamsTable,
      SeriesTeam,
      $$SeriesTeamsTableFilterComposer,
      $$SeriesTeamsTableOrderingComposer,
      $$SeriesTeamsTableAnnotationComposer,
      $$SeriesTeamsTableCreateCompanionBuilder,
      $$SeriesTeamsTableUpdateCompanionBuilder,
      (
        SeriesTeam,
        BaseReferences<_$AppDatabase, $SeriesTeamsTable, SeriesTeam>,
      ),
      SeriesTeam,
      PrefetchHooks Function()
    >;
typedef $$SeriesUniversesTableCreateCompanionBuilder =
    SeriesUniversesCompanion Function({
      required int seriesId,
      required int universeId,
      Value<int> rowid,
    });
typedef $$SeriesUniversesTableUpdateCompanionBuilder =
    SeriesUniversesCompanion Function({
      Value<int> seriesId,
      Value<int> universeId,
      Value<int> rowid,
    });

class $$SeriesUniversesTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesUniversesTable> {
  $$SeriesUniversesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesUniversesTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesUniversesTable> {
  $$SeriesUniversesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesUniversesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesUniversesTable> {
  $$SeriesUniversesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => column,
  );
}

class $$SeriesUniversesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesUniversesTable,
          SeriesUniverse,
          $$SeriesUniversesTableFilterComposer,
          $$SeriesUniversesTableOrderingComposer,
          $$SeriesUniversesTableAnnotationComposer,
          $$SeriesUniversesTableCreateCompanionBuilder,
          $$SeriesUniversesTableUpdateCompanionBuilder,
          (
            SeriesUniverse,
            BaseReferences<
              _$AppDatabase,
              $SeriesUniversesTable,
              SeriesUniverse
            >,
          ),
          SeriesUniverse,
          PrefetchHooks Function()
        > {
  $$SeriesUniversesTableTableManager(
    _$AppDatabase db,
    $SeriesUniversesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesUniversesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesUniversesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesUniversesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seriesId = const Value.absent(),
                Value<int> universeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesUniversesCompanion(
                seriesId: seriesId,
                universeId: universeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seriesId,
                required int universeId,
                Value<int> rowid = const Value.absent(),
              }) => SeriesUniversesCompanion.insert(
                seriesId: seriesId,
                universeId: universeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesUniversesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesUniversesTable,
      SeriesUniverse,
      $$SeriesUniversesTableFilterComposer,
      $$SeriesUniversesTableOrderingComposer,
      $$SeriesUniversesTableAnnotationComposer,
      $$SeriesUniversesTableCreateCompanionBuilder,
      $$SeriesUniversesTableUpdateCompanionBuilder,
      (
        SeriesUniverse,
        BaseReferences<_$AppDatabase, $SeriesUniversesTable, SeriesUniverse>,
      ),
      SeriesUniverse,
      PrefetchHooks Function()
    >;
typedef $$AssociatedSeriesTableCreateCompanionBuilder =
    AssociatedSeriesCompanion Function({
      required int seriesId,
      required int associatedSeriesId,
      Value<int> rowid,
    });
typedef $$AssociatedSeriesTableUpdateCompanionBuilder =
    AssociatedSeriesCompanion Function({
      Value<int> seriesId,
      Value<int> associatedSeriesId,
      Value<int> rowid,
    });

class $$AssociatedSeriesTableFilterComposer
    extends Composer<_$AppDatabase, $AssociatedSeriesTable> {
  $$AssociatedSeriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get associatedSeriesId => $composableBuilder(
    column: $table.associatedSeriesId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssociatedSeriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssociatedSeriesTable> {
  $$AssociatedSeriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seriesId => $composableBuilder(
    column: $table.seriesId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get associatedSeriesId => $composableBuilder(
    column: $table.associatedSeriesId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssociatedSeriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssociatedSeriesTable> {
  $$AssociatedSeriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seriesId =>
      $composableBuilder(column: $table.seriesId, builder: (column) => column);

  GeneratedColumn<int> get associatedSeriesId => $composableBuilder(
    column: $table.associatedSeriesId,
    builder: (column) => column,
  );
}

class $$AssociatedSeriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssociatedSeriesTable,
          AssociatedSery,
          $$AssociatedSeriesTableFilterComposer,
          $$AssociatedSeriesTableOrderingComposer,
          $$AssociatedSeriesTableAnnotationComposer,
          $$AssociatedSeriesTableCreateCompanionBuilder,
          $$AssociatedSeriesTableUpdateCompanionBuilder,
          (
            AssociatedSery,
            BaseReferences<
              _$AppDatabase,
              $AssociatedSeriesTable,
              AssociatedSery
            >,
          ),
          AssociatedSery,
          PrefetchHooks Function()
        > {
  $$AssociatedSeriesTableTableManager(
    _$AppDatabase db,
    $AssociatedSeriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssociatedSeriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssociatedSeriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssociatedSeriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seriesId = const Value.absent(),
                Value<int> associatedSeriesId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssociatedSeriesCompanion(
                seriesId: seriesId,
                associatedSeriesId: associatedSeriesId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int seriesId,
                required int associatedSeriesId,
                Value<int> rowid = const Value.absent(),
              }) => AssociatedSeriesCompanion.insert(
                seriesId: seriesId,
                associatedSeriesId: associatedSeriesId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssociatedSeriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssociatedSeriesTable,
      AssociatedSery,
      $$AssociatedSeriesTableFilterComposer,
      $$AssociatedSeriesTableOrderingComposer,
      $$AssociatedSeriesTableAnnotationComposer,
      $$AssociatedSeriesTableCreateCompanionBuilder,
      $$AssociatedSeriesTableUpdateCompanionBuilder,
      (
        AssociatedSery,
        BaseReferences<_$AppDatabase, $AssociatedSeriesTable, AssociatedSery>,
      ),
      AssociatedSery,
      PrefetchHooks Function()
    >;
typedef $$CharacterCreatorsTableCreateCompanionBuilder =
    CharacterCreatorsCompanion Function({
      required int characterId,
      required int creatorId,
      Value<int> rowid,
    });
typedef $$CharacterCreatorsTableUpdateCompanionBuilder =
    CharacterCreatorsCompanion Function({
      Value<int> characterId,
      Value<int> creatorId,
      Value<int> rowid,
    });

class $$CharacterCreatorsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterCreatorsTable> {
  $$CharacterCreatorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterCreatorsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterCreatorsTable> {
  $$CharacterCreatorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterCreatorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterCreatorsTable> {
  $$CharacterCreatorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);
}

class $$CharacterCreatorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterCreatorsTable,
          CharacterCreator,
          $$CharacterCreatorsTableFilterComposer,
          $$CharacterCreatorsTableOrderingComposer,
          $$CharacterCreatorsTableAnnotationComposer,
          $$CharacterCreatorsTableCreateCompanionBuilder,
          $$CharacterCreatorsTableUpdateCompanionBuilder,
          (
            CharacterCreator,
            BaseReferences<
              _$AppDatabase,
              $CharacterCreatorsTable,
              CharacterCreator
            >,
          ),
          CharacterCreator,
          PrefetchHooks Function()
        > {
  $$CharacterCreatorsTableTableManager(
    _$AppDatabase db,
    $CharacterCreatorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterCreatorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterCreatorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterCreatorsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> characterId = const Value.absent(),
                Value<int> creatorId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterCreatorsCompanion(
                characterId: characterId,
                creatorId: creatorId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int characterId,
                required int creatorId,
                Value<int> rowid = const Value.absent(),
              }) => CharacterCreatorsCompanion.insert(
                characterId: characterId,
                creatorId: creatorId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterCreatorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterCreatorsTable,
      CharacterCreator,
      $$CharacterCreatorsTableFilterComposer,
      $$CharacterCreatorsTableOrderingComposer,
      $$CharacterCreatorsTableAnnotationComposer,
      $$CharacterCreatorsTableCreateCompanionBuilder,
      $$CharacterCreatorsTableUpdateCompanionBuilder,
      (
        CharacterCreator,
        BaseReferences<
          _$AppDatabase,
          $CharacterCreatorsTable,
          CharacterCreator
        >,
      ),
      CharacterCreator,
      PrefetchHooks Function()
    >;
typedef $$CharacterTeamsTableCreateCompanionBuilder =
    CharacterTeamsCompanion Function({
      required int characterId,
      required int teamId,
      Value<int> rowid,
    });
typedef $$CharacterTeamsTableUpdateCompanionBuilder =
    CharacterTeamsCompanion Function({
      Value<int> characterId,
      Value<int> teamId,
      Value<int> rowid,
    });

class $$CharacterTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterTeamsTable> {
  $$CharacterTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterTeamsTable> {
  $$CharacterTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterTeamsTable> {
  $$CharacterTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);
}

class $$CharacterTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterTeamsTable,
          CharacterTeam,
          $$CharacterTeamsTableFilterComposer,
          $$CharacterTeamsTableOrderingComposer,
          $$CharacterTeamsTableAnnotationComposer,
          $$CharacterTeamsTableCreateCompanionBuilder,
          $$CharacterTeamsTableUpdateCompanionBuilder,
          (
            CharacterTeam,
            BaseReferences<_$AppDatabase, $CharacterTeamsTable, CharacterTeam>,
          ),
          CharacterTeam,
          PrefetchHooks Function()
        > {
  $$CharacterTeamsTableTableManager(
    _$AppDatabase db,
    $CharacterTeamsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> characterId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterTeamsCompanion(
                characterId: characterId,
                teamId: teamId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int characterId,
                required int teamId,
                Value<int> rowid = const Value.absent(),
              }) => CharacterTeamsCompanion.insert(
                characterId: characterId,
                teamId: teamId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterTeamsTable,
      CharacterTeam,
      $$CharacterTeamsTableFilterComposer,
      $$CharacterTeamsTableOrderingComposer,
      $$CharacterTeamsTableAnnotationComposer,
      $$CharacterTeamsTableCreateCompanionBuilder,
      $$CharacterTeamsTableUpdateCompanionBuilder,
      (
        CharacterTeam,
        BaseReferences<_$AppDatabase, $CharacterTeamsTable, CharacterTeam>,
      ),
      CharacterTeam,
      PrefetchHooks Function()
    >;
typedef $$CharacterUniversesTableCreateCompanionBuilder =
    CharacterUniversesCompanion Function({
      required int characterId,
      required int universeId,
      Value<int> rowid,
    });
typedef $$CharacterUniversesTableUpdateCompanionBuilder =
    CharacterUniversesCompanion Function({
      Value<int> characterId,
      Value<int> universeId,
      Value<int> rowid,
    });

class $$CharacterUniversesTableFilterComposer
    extends Composer<_$AppDatabase, $CharacterUniversesTable> {
  $$CharacterUniversesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CharacterUniversesTableOrderingComposer
    extends Composer<_$AppDatabase, $CharacterUniversesTable> {
  $$CharacterUniversesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CharacterUniversesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CharacterUniversesTable> {
  $$CharacterUniversesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get characterId => $composableBuilder(
    column: $table.characterId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => column,
  );
}

class $$CharacterUniversesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CharacterUniversesTable,
          CharacterUniverse,
          $$CharacterUniversesTableFilterComposer,
          $$CharacterUniversesTableOrderingComposer,
          $$CharacterUniversesTableAnnotationComposer,
          $$CharacterUniversesTableCreateCompanionBuilder,
          $$CharacterUniversesTableUpdateCompanionBuilder,
          (
            CharacterUniverse,
            BaseReferences<
              _$AppDatabase,
              $CharacterUniversesTable,
              CharacterUniverse
            >,
          ),
          CharacterUniverse,
          PrefetchHooks Function()
        > {
  $$CharacterUniversesTableTableManager(
    _$AppDatabase db,
    $CharacterUniversesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CharacterUniversesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CharacterUniversesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CharacterUniversesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> characterId = const Value.absent(),
                Value<int> universeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CharacterUniversesCompanion(
                characterId: characterId,
                universeId: universeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int characterId,
                required int universeId,
                Value<int> rowid = const Value.absent(),
              }) => CharacterUniversesCompanion.insert(
                characterId: characterId,
                universeId: universeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CharacterUniversesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CharacterUniversesTable,
      CharacterUniverse,
      $$CharacterUniversesTableFilterComposer,
      $$CharacterUniversesTableOrderingComposer,
      $$CharacterUniversesTableAnnotationComposer,
      $$CharacterUniversesTableCreateCompanionBuilder,
      $$CharacterUniversesTableUpdateCompanionBuilder,
      (
        CharacterUniverse,
        BaseReferences<
          _$AppDatabase,
          $CharacterUniversesTable,
          CharacterUniverse
        >,
      ),
      CharacterUniverse,
      PrefetchHooks Function()
    >;
typedef $$CreatorTeamsTableCreateCompanionBuilder =
    CreatorTeamsCompanion Function({
      required int creatorId,
      required int teamId,
      Value<int> rowid,
    });
typedef $$CreatorTeamsTableUpdateCompanionBuilder =
    CreatorTeamsCompanion Function({
      Value<int> creatorId,
      Value<int> teamId,
      Value<int> rowid,
    });

class $$CreatorTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $CreatorTeamsTable> {
  $$CreatorTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CreatorTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreatorTeamsTable> {
  $$CreatorTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get creatorId => $composableBuilder(
    column: $table.creatorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CreatorTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreatorTeamsTable> {
  $$CreatorTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get creatorId =>
      $composableBuilder(column: $table.creatorId, builder: (column) => column);

  GeneratedColumn<int> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);
}

class $$CreatorTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CreatorTeamsTable,
          CreatorTeam,
          $$CreatorTeamsTableFilterComposer,
          $$CreatorTeamsTableOrderingComposer,
          $$CreatorTeamsTableAnnotationComposer,
          $$CreatorTeamsTableCreateCompanionBuilder,
          $$CreatorTeamsTableUpdateCompanionBuilder,
          (
            CreatorTeam,
            BaseReferences<_$AppDatabase, $CreatorTeamsTable, CreatorTeam>,
          ),
          CreatorTeam,
          PrefetchHooks Function()
        > {
  $$CreatorTeamsTableTableManager(_$AppDatabase db, $CreatorTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreatorTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreatorTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreatorTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> creatorId = const Value.absent(),
                Value<int> teamId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CreatorTeamsCompanion(
                creatorId: creatorId,
                teamId: teamId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int creatorId,
                required int teamId,
                Value<int> rowid = const Value.absent(),
              }) => CreatorTeamsCompanion.insert(
                creatorId: creatorId,
                teamId: teamId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CreatorTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CreatorTeamsTable,
      CreatorTeam,
      $$CreatorTeamsTableFilterComposer,
      $$CreatorTeamsTableOrderingComposer,
      $$CreatorTeamsTableAnnotationComposer,
      $$CreatorTeamsTableCreateCompanionBuilder,
      $$CreatorTeamsTableUpdateCompanionBuilder,
      (
        CreatorTeam,
        BaseReferences<_$AppDatabase, $CreatorTeamsTable, CreatorTeam>,
      ),
      CreatorTeam,
      PrefetchHooks Function()
    >;
typedef $$TeamUniversesTableCreateCompanionBuilder =
    TeamUniversesCompanion Function({
      required int teamId,
      required int universeId,
      Value<int> rowid,
    });
typedef $$TeamUniversesTableUpdateCompanionBuilder =
    TeamUniversesCompanion Function({
      Value<int> teamId,
      Value<int> universeId,
      Value<int> rowid,
    });

class $$TeamUniversesTableFilterComposer
    extends Composer<_$AppDatabase, $TeamUniversesTable> {
  $$TeamUniversesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamUniversesTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamUniversesTable> {
  $$TeamUniversesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamUniversesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamUniversesTable> {
  $$TeamUniversesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<int> get universeId => $composableBuilder(
    column: $table.universeId,
    builder: (column) => column,
  );
}

class $$TeamUniversesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamUniversesTable,
          TeamUniverse,
          $$TeamUniversesTableFilterComposer,
          $$TeamUniversesTableOrderingComposer,
          $$TeamUniversesTableAnnotationComposer,
          $$TeamUniversesTableCreateCompanionBuilder,
          $$TeamUniversesTableUpdateCompanionBuilder,
          (
            TeamUniverse,
            BaseReferences<_$AppDatabase, $TeamUniversesTable, TeamUniverse>,
          ),
          TeamUniverse,
          PrefetchHooks Function()
        > {
  $$TeamUniversesTableTableManager(_$AppDatabase db, $TeamUniversesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamUniversesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamUniversesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamUniversesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> teamId = const Value.absent(),
                Value<int> universeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamUniversesCompanion(
                teamId: teamId,
                universeId: universeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int teamId,
                required int universeId,
                Value<int> rowid = const Value.absent(),
              }) => TeamUniversesCompanion.insert(
                teamId: teamId,
                universeId: universeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamUniversesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamUniversesTable,
      TeamUniverse,
      $$TeamUniversesTableFilterComposer,
      $$TeamUniversesTableOrderingComposer,
      $$TeamUniversesTableAnnotationComposer,
      $$TeamUniversesTableCreateCompanionBuilder,
      $$TeamUniversesTableUpdateCompanionBuilder,
      (
        TeamUniverse,
        BaseReferences<_$AppDatabase, $TeamUniversesTable, TeamUniverse>,
      ),
      TeamUniverse,
      PrefetchHooks Function()
    >;
typedef $$MetronReadingListItemsTableCreateCompanionBuilder =
    MetronReadingListItemsCompanion Function({
      required int listId,
      required int targetId,
      Value<int?> order,
      Value<String?> issueType,
      Value<int> rowid,
    });
typedef $$MetronReadingListItemsTableUpdateCompanionBuilder =
    MetronReadingListItemsCompanion Function({
      Value<int> listId,
      Value<int> targetId,
      Value<int?> order,
      Value<String?> issueType,
      Value<int> rowid,
    });

class $$MetronReadingListItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MetronReadingListItemsTable> {
  $$MetronReadingListItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueType => $composableBuilder(
    column: $table.issueType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetronReadingListItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MetronReadingListItemsTable> {
  $$MetronReadingListItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueType => $composableBuilder(
    column: $table.issueType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetronReadingListItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetronReadingListItemsTable> {
  $$MetronReadingListItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<int> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get issueType =>
      $composableBuilder(column: $table.issueType, builder: (column) => column);
}

class $$MetronReadingListItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetronReadingListItemsTable,
          MetronReadingListItem,
          $$MetronReadingListItemsTableFilterComposer,
          $$MetronReadingListItemsTableOrderingComposer,
          $$MetronReadingListItemsTableAnnotationComposer,
          $$MetronReadingListItemsTableCreateCompanionBuilder,
          $$MetronReadingListItemsTableUpdateCompanionBuilder,
          (
            MetronReadingListItem,
            BaseReferences<
              _$AppDatabase,
              $MetronReadingListItemsTable,
              MetronReadingListItem
            >,
          ),
          MetronReadingListItem,
          PrefetchHooks Function()
        > {
  $$MetronReadingListItemsTableTableManager(
    _$AppDatabase db,
    $MetronReadingListItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetronReadingListItemsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MetronReadingListItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MetronReadingListItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> listId = const Value.absent(),
                Value<int> targetId = const Value.absent(),
                Value<int?> order = const Value.absent(),
                Value<String?> issueType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetronReadingListItemsCompanion(
                listId: listId,
                targetId: targetId,
                order: order,
                issueType: issueType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int listId,
                required int targetId,
                Value<int?> order = const Value.absent(),
                Value<String?> issueType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetronReadingListItemsCompanion.insert(
                listId: listId,
                targetId: targetId,
                order: order,
                issueType: issueType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetronReadingListItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetronReadingListItemsTable,
      MetronReadingListItem,
      $$MetronReadingListItemsTableFilterComposer,
      $$MetronReadingListItemsTableOrderingComposer,
      $$MetronReadingListItemsTableAnnotationComposer,
      $$MetronReadingListItemsTableCreateCompanionBuilder,
      $$MetronReadingListItemsTableUpdateCompanionBuilder,
      (
        MetronReadingListItem,
        BaseReferences<
          _$AppDatabase,
          $MetronReadingListItemsTable,
          MetronReadingListItem
        >,
      ),
      MetronReadingListItem,
      PrefetchHooks Function()
    >;
typedef $$ApiCacheTableCreateCompanionBuilder =
    ApiCacheCompanion Function({
      required String cacheKey,
      required String entityType,
      required String payload,
      Value<String?> etag,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$ApiCacheTableUpdateCompanionBuilder =
    ApiCacheCompanion Function({
      Value<String> cacheKey,
      Value<String> entityType,
      Value<String> payload,
      Value<String?> etag,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$ApiCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiCacheTable> {
  $$ApiCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$ApiCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiCacheTable,
          ApiCacheData,
          $$ApiCacheTableFilterComposer,
          $$ApiCacheTableOrderingComposer,
          $$ApiCacheTableAnnotationComposer,
          $$ApiCacheTableCreateCompanionBuilder,
          $$ApiCacheTableUpdateCompanionBuilder,
          (
            ApiCacheData,
            BaseReferences<_$AppDatabase, $ApiCacheTable, ApiCacheData>,
          ),
          ApiCacheData,
          PrefetchHooks Function()
        > {
  $$ApiCacheTableTableManager(_$AppDatabase db, $ApiCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheCompanion(
                cacheKey: cacheKey,
                entityType: entityType,
                payload: payload,
                etag: etag,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                required String entityType,
                required String payload,
                Value<String?> etag = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => ApiCacheCompanion.insert(
                cacheKey: cacheKey,
                entityType: entityType,
                payload: payload,
                etag: etag,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiCacheTable,
      ApiCacheData,
      $$ApiCacheTableFilterComposer,
      $$ApiCacheTableOrderingComposer,
      $$ApiCacheTableAnnotationComposer,
      $$ApiCacheTableCreateCompanionBuilder,
      $$ApiCacheTableUpdateCompanionBuilder,
      (
        ApiCacheData,
        BaseReferences<_$AppDatabase, $ApiCacheTable, ApiCacheData>,
      ),
      ApiCacheData,
      PrefetchHooks Function()
    >;
typedef $$ImageCacheTableCreateCompanionBuilder =
    ImageCacheCompanion Function({
      required String key,
      required String entityType,
      required int entityId,
      required String imageUrl,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$ImageCacheTableUpdateCompanionBuilder =
    ImageCacheCompanion Function({
      Value<String> key,
      Value<String> entityType,
      Value<int> entityId,
      Value<String> imageUrl,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$ImageCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ImageCacheTable> {
  $$ImageCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImageCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageCacheTable> {
  $$ImageCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImageCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageCacheTable> {
  $$ImageCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$ImageCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageCacheTable,
          ImageCacheData,
          $$ImageCacheTableFilterComposer,
          $$ImageCacheTableOrderingComposer,
          $$ImageCacheTableAnnotationComposer,
          $$ImageCacheTableCreateCompanionBuilder,
          $$ImageCacheTableUpdateCompanionBuilder,
          (
            ImageCacheData,
            BaseReferences<_$AppDatabase, $ImageCacheTable, ImageCacheData>,
          ),
          ImageCacheData,
          PrefetchHooks Function()
        > {
  $$ImageCacheTableTableManager(_$AppDatabase db, $ImageCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<int> entityId = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImageCacheCompanion(
                key: key,
                entityType: entityType,
                entityId: entityId,
                imageUrl: imageUrl,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String entityType,
                required int entityId,
                required String imageUrl,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => ImageCacheCompanion.insert(
                key: key,
                entityType: entityType,
                entityId: entityId,
                imageUrl: imageUrl,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImageCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageCacheTable,
      ImageCacheData,
      $$ImageCacheTableFilterComposer,
      $$ImageCacheTableOrderingComposer,
      $$ImageCacheTableAnnotationComposer,
      $$ImageCacheTableCreateCompanionBuilder,
      $$ImageCacheTableUpdateCompanionBuilder,
      (
        ImageCacheData,
        BaseReferences<_$AppDatabase, $ImageCacheTable, ImageCacheData>,
      ),
      ImageCacheData,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$SeriesNameIndexTableCreateCompanionBuilder =
    SeriesNameIndexCompanion Function({
      required String normalizedName,
      required String originalName,
      Value<int> rowid,
    });
typedef $$SeriesNameIndexTableUpdateCompanionBuilder =
    SeriesNameIndexCompanion Function({
      Value<String> normalizedName,
      Value<String> originalName,
      Value<int> rowid,
    });

class $$SeriesNameIndexTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesNameIndexTable> {
  $$SeriesNameIndexTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesNameIndexTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesNameIndexTable> {
  $$SeriesNameIndexTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesNameIndexTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesNameIndexTable> {
  $$SeriesNameIndexTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalName => $composableBuilder(
    column: $table.originalName,
    builder: (column) => column,
  );
}

class $$SeriesNameIndexTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesNameIndexTable,
          SeriesNameIndexData,
          $$SeriesNameIndexTableFilterComposer,
          $$SeriesNameIndexTableOrderingComposer,
          $$SeriesNameIndexTableAnnotationComposer,
          $$SeriesNameIndexTableCreateCompanionBuilder,
          $$SeriesNameIndexTableUpdateCompanionBuilder,
          (
            SeriesNameIndexData,
            BaseReferences<
              _$AppDatabase,
              $SeriesNameIndexTable,
              SeriesNameIndexData
            >,
          ),
          SeriesNameIndexData,
          PrefetchHooks Function()
        > {
  $$SeriesNameIndexTableTableManager(
    _$AppDatabase db,
    $SeriesNameIndexTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesNameIndexTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesNameIndexTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesNameIndexTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> normalizedName = const Value.absent(),
                Value<String> originalName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesNameIndexCompanion(
                normalizedName: normalizedName,
                originalName: originalName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String normalizedName,
                required String originalName,
                Value<int> rowid = const Value.absent(),
              }) => SeriesNameIndexCompanion.insert(
                normalizedName: normalizedName,
                originalName: originalName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesNameIndexTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesNameIndexTable,
      SeriesNameIndexData,
      $$SeriesNameIndexTableFilterComposer,
      $$SeriesNameIndexTableOrderingComposer,
      $$SeriesNameIndexTableAnnotationComposer,
      $$SeriesNameIndexTableCreateCompanionBuilder,
      $$SeriesNameIndexTableUpdateCompanionBuilder,
      (
        SeriesNameIndexData,
        BaseReferences<
          _$AppDatabase,
          $SeriesNameIndexTable,
          SeriesNameIndexData
        >,
      ),
      SeriesNameIndexData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LibraryItemsTableTableManager get libraryItems =>
      $$LibraryItemsTableTableManager(_db, _db.libraryItems);
  $$LibraryReadLogsTableTableManager get libraryReadLogs =>
      $$LibraryReadLogsTableTableManager(_db, _db.libraryReadLogs);
  $$PullListEntriesTableTableManager get pullListEntries =>
      $$PullListEntriesTableTableManager(_db, _db.pullListEntries);
  $$SeriesSubscriptionsTableTableManager get seriesSubscriptions =>
      $$SeriesSubscriptionsTableTableManager(_db, _db.seriesSubscriptions);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$ReadingListsTableTableManager get readingLists =>
      $$ReadingListsTableTableManager(_db, _db.readingLists);
  $$ReadingListItemsTableTableManager get readingListItems =>
      $$ReadingListItemsTableTableManager(_db, _db.readingListItems);
  $$FavoriteSeriesTableTableManager get favoriteSeries =>
      $$FavoriteSeriesTableTableManager(_db, _db.favoriteSeries);
  $$FavoriteIssuesTableTableManager get favoriteIssues =>
      $$FavoriteIssuesTableTableManager(_db, _db.favoriteIssues);
  $$FavoriteCharactersTableTableManager get favoriteCharacters =>
      $$FavoriteCharactersTableTableManager(_db, _db.favoriteCharacters);
  $$FavoriteCreatorsTableTableManager get favoriteCreators =>
      $$FavoriteCreatorsTableTableManager(_db, _db.favoriteCreators);
  $$FavoriteReadingListsTableTableManager get favoriteReadingLists =>
      $$FavoriteReadingListsTableTableManager(_db, _db.favoriteReadingLists);
  $$MetronIssuesTableTableManager get metronIssues =>
      $$MetronIssuesTableTableManager(_db, _db.metronIssues);
  $$MetronSeriesTableTableManager get metronSeries =>
      $$MetronSeriesTableTableManager(_db, _db.metronSeries);
  $$MetronCreatorsTableTableManager get metronCreators =>
      $$MetronCreatorsTableTableManager(_db, _db.metronCreators);
  $$MetronCharactersTableTableManager get metronCharacters =>
      $$MetronCharactersTableTableManager(_db, _db.metronCharacters);
  $$MetronArcsTableTableManager get metronArcs =>
      $$MetronArcsTableTableManager(_db, _db.metronArcs);
  $$MetronTeamsTableTableManager get metronTeams =>
      $$MetronTeamsTableTableManager(_db, _db.metronTeams);
  $$MetronUniversesTableTableManager get metronUniverses =>
      $$MetronUniversesTableTableManager(_db, _db.metronUniverses);
  $$MetronPublishersTableTableManager get metronPublishers =>
      $$MetronPublishersTableTableManager(_db, _db.metronPublishers);
  $$MetronImprintsTableTableManager get metronImprints =>
      $$MetronImprintsTableTableManager(_db, _db.metronImprints);
  $$MetronReadingListsTableTableManager get metronReadingLists =>
      $$MetronReadingListsTableTableManager(_db, _db.metronReadingLists);
  $$IssueCreatorsTableTableManager get issueCreators =>
      $$IssueCreatorsTableTableManager(_db, _db.issueCreators);
  $$IssueCharactersTableTableManager get issueCharacters =>
      $$IssueCharactersTableTableManager(_db, _db.issueCharacters);
  $$IssueArcsTableTableManager get issueArcs =>
      $$IssueArcsTableTableManager(_db, _db.issueArcs);
  $$IssueTeamsTableTableManager get issueTeams =>
      $$IssueTeamsTableTableManager(_db, _db.issueTeams);
  $$IssueUniversesTableTableManager get issueUniverses =>
      $$IssueUniversesTableTableManager(_db, _db.issueUniverses);
  $$IssueImprintsTableTableManager get issueImprints =>
      $$IssueImprintsTableTableManager(_db, _db.issueImprints);
  $$SeriesArcsTableTableManager get seriesArcs =>
      $$SeriesArcsTableTableManager(_db, _db.seriesArcs);
  $$SeriesTeamsTableTableManager get seriesTeams =>
      $$SeriesTeamsTableTableManager(_db, _db.seriesTeams);
  $$SeriesUniversesTableTableManager get seriesUniverses =>
      $$SeriesUniversesTableTableManager(_db, _db.seriesUniverses);
  $$AssociatedSeriesTableTableManager get associatedSeries =>
      $$AssociatedSeriesTableTableManager(_db, _db.associatedSeries);
  $$CharacterCreatorsTableTableManager get characterCreators =>
      $$CharacterCreatorsTableTableManager(_db, _db.characterCreators);
  $$CharacterTeamsTableTableManager get characterTeams =>
      $$CharacterTeamsTableTableManager(_db, _db.characterTeams);
  $$CharacterUniversesTableTableManager get characterUniverses =>
      $$CharacterUniversesTableTableManager(_db, _db.characterUniverses);
  $$CreatorTeamsTableTableManager get creatorTeams =>
      $$CreatorTeamsTableTableManager(_db, _db.creatorTeams);
  $$TeamUniversesTableTableManager get teamUniverses =>
      $$TeamUniversesTableTableManager(_db, _db.teamUniverses);
  $$MetronReadingListItemsTableTableManager get metronReadingListItems =>
      $$MetronReadingListItemsTableTableManager(
        _db,
        _db.metronReadingListItems,
      );
  $$ApiCacheTableTableManager get apiCache =>
      $$ApiCacheTableTableManager(_db, _db.apiCache);
  $$ImageCacheTableTableManager get imageCache =>
      $$ImageCacheTableTableManager(_db, _db.imageCache);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$SeriesNameIndexTableTableManager get seriesNameIndex =>
      $$SeriesNameIndexTableTableManager(_db, _db.seriesNameIndex);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
