/// Tipe custody
enum CustodyType {
  diterima, // Uang dititipkan ke kita
  diberikan, // Kita titip ke orang lain
}

extension CustodyTypeExtension on CustodyType {
  String get displayName {
    switch (this) {
      case CustodyType.diterima: return 'Uang Diterima';
      case CustodyType.diberikan: return 'Uang Diberikan';
    }
  }

  String get name {
    switch (this) {
      case CustodyType.diterima: return 'DITERIMA';
      case CustodyType.diberikan: return 'DIBERIKAN';
    }
  }

  static CustodyType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DIBERIKAN': return CustodyType.diberikan;
      default: return CustodyType.diterima;
    }
  }
}

/// Model titipan uang
class CustodyModel {
  final int id;
  final String? firebaseDocId;
  final String userId;
  final String depositorName;
  final String? description;
  final int totalNominal;
  final CustodyType type;
  final int currentBalance;
  final bool isSynced;
  final DateTime? syncedAt;
  final DateTime localCreatedAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  const CustodyModel({
    required this.id,
    this.firebaseDocId,
    required this.userId,
    required this.depositorName,
    this.description,
    required this.totalNominal,
    required this.type,
    this.currentBalance = 0,
    this.isSynced = false,
    this.syncedAt,
    required this.localCreatedAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  CustodyModel copyWith({
    int? id,
    String? firebaseDocId,
    String? userId,
    String? depositorName,
    String? description,
    int? totalNominal,
    CustodyType? type,
    int? currentBalance,
    bool? isSynced,
    DateTime? syncedAt,
    DateTime? localCreatedAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return CustodyModel(
      id: id ?? this.id,
      firebaseDocId: firebaseDocId ?? this.firebaseDocId,
      userId: userId ?? this.userId,
      depositorName: depositorName ?? this.depositorName,
      description: description ?? this.description,
      totalNominal: totalNominal ?? this.totalNominal,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      isSynced: isSynced ?? this.isSynced,
      syncedAt: syncedAt ?? this.syncedAt,
      localCreatedAt: localCreatedAt ?? this.localCreatedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toSqlite() {
    return {
      if (id > 0) 'id': id,
      'firebaseDocId': firebaseDocId,
      'userId': userId,
      'depositorName': depositorName,
      'description': description,
      'totalNominal': totalNominal,
      'type': type.name,
      'currentBalance': currentBalance,
      'isSynced': isSynced ? 1 : 0,
      'syncedAt': syncedAt?.millisecondsSinceEpoch,
      'localCreatedAt': localCreatedAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  static CustodyModel fromSqlite(Map<String, dynamic> map) {
    return CustodyModel(
      id: map['id'] as int,
      firebaseDocId: map['firebaseDocId'] as String?,
      userId: map['userId'] as String,
      depositorName: map['depositorName'] as String,
      description: map['description'] as String?,
      totalNominal: map['totalNominal'] as int,
      type: CustodyTypeExtension.fromString(map['type'] as String? ?? 'DITERIMA'),
      currentBalance: (map['currentBalance'] as int?) ?? 0,
      isSynced: (map['isSynced'] as int) == 1,
      syncedAt: map['syncedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['syncedAt'] as int)
          : null,
      localCreatedAt: DateTime.fromMillisecondsSinceEpoch(map['localCreatedAt'] as int),
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isDeleted: (map['isDeleted'] as int? ?? 0) == 1,
    );
  }
}
