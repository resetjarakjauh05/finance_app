/// Tipe pergerakan uang
enum MovementType {
  masuk,
  keluar,
}

extension MovementTypeExtension on MovementType {
  String get displayName {
    switch (this) {
      case MovementType.masuk:  return 'Masuk';
      case MovementType.keluar: return 'Keluar';
    }
  }

  String get name {
    switch (this) {
      case MovementType.masuk:  return 'MASUK';
      case MovementType.keluar: return 'KELUAR';
    }
  }

  static MovementType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'KELUAR': return MovementType.keluar;
      default:       return MovementType.masuk;
    }
  }
}

/// Model pergerakan titipan
class CustodyMovementModel {
  final int id;
  final String? firebaseDocId;
  final int custodyId;
  final String? custodyFirebaseDocId;
  final MovementType movementType;
  final int nominal;
  final int transferFee;
  final DateTime date;
  final String? description;
  final bool isSynced;
  final DateTime? syncedAt;
  final DateTime localCreatedAt;

  const CustodyMovementModel({
    required this.id,
    this.firebaseDocId,
    required this.custodyId,
    this.custodyFirebaseDocId,
    required this.movementType,
    required this.nominal,
    this.transferFee = 0,
    required this.date,
    this.description,
    this.isSynced = false,
    this.syncedAt,
    required this.localCreatedAt,
  });

  CustodyMovementModel copyWith({
    int? id,
    String? firebaseDocId,
    int? custodyId,
    String? custodyFirebaseDocId,
    MovementType? movementType,
    int? nominal,
    int? transferFee,
    DateTime? date,
    String? description,
    bool? isSynced,
    DateTime? syncedAt,
    DateTime? localCreatedAt,
  }) {
    return CustodyMovementModel(
      id: id ?? this.id,
      firebaseDocId: firebaseDocId ?? this.firebaseDocId,
      custodyId: custodyId ?? this.custodyId,
      custodyFirebaseDocId: custodyFirebaseDocId ?? this.custodyFirebaseDocId,
      movementType: movementType ?? this.movementType,
      nominal: nominal ?? this.nominal,
      transferFee: transferFee ?? this.transferFee,
      date: date ?? this.date,
      description: description ?? this.description,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      if (id > 0) 'id': id,
      'firebaseDocId': firebaseDocId,
      'custodyId': custodyId,
      'custodyFirebaseDocId': custodyFirebaseDocId,
      'movementType': movementType.name,
      'nominal': nominal,
      'transferFee': transferFee,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
    };
  }

  static CustodyMovementModel fromSqlite(Map<String, dynamic> map) {
    return CustodyMovementModel(
      id: map['id'] as int,
      firebaseDocId: map['firebaseDocId'] as String?,
      custodyId: map['custodyId'] as int,
      custodyFirebaseDocId: map['custodyFirebaseDocId'] as String?,
      movementType: MovementTypeExtension.fromString(map['movementType'] as String? ?? 'MASUK'),
      nominal: map['nominal'] as int,
      transferFee: (map['transferFee'] as int?) ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      description: map['description'] as String?,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
      localCreatedAt: DateTime.fromMillisecondsSinceEpoch(map['localCreatedAt'] as int),
    );
  }
}
