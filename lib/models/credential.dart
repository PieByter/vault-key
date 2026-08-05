/// Core credential model — represents a single saved password/item.
///
/// This is the encrypted entity stored locally and synced to Firestore.
/// Timestamps use [DateTime] in-memory and ISO-8601 strings on the wire.
class Credential {
  final String id;
  final String userId; // Firebase Auth UID
  final CredentialType type;
  final String name;
  final String? url;
  final String username;
  final String password; // encrypted
  final String? totpSecret; // encrypted TOTP seed
  final String? notes; // encrypted
  final String? categoryId;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted; // soft-delete for sync

  const Credential({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.url,
    required this.username,
    required this.password,
    this.totpSecret,
    this.notes,
    this.categoryId,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Credential copyWith({
    String? id,
    String? userId,
    CredentialType? type,
    String? name,
    String? url,
    String? username,
    String? password,
    String? totpSecret,
    String? notes,
    String? categoryId,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Credential(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      name: name ?? this.name,
      url: url ?? this.url,
      username: username ?? this.username,
      password: password ?? this.password,
      totpSecret: totpSecret ?? this.totpSecret,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Factory from Firestore JSON (decrypted fields already applied).
  factory Credential.fromJson(Map<String, dynamic> json) {
    return Credential(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: CredentialType.fromValue(json['type'] as String),
      name: json['name'] as String,
      url: json['url'] as String?,
      username: json['username'] as String,
      password: json['password'] as String,
      totpSecret: json['totpSecret'] as String?,
      notes: json['notes'] as String?,
      categoryId: json['categoryId'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// Serialize to Firestore JSON (fields assumed already encrypted).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.value,
      'name': name,
      'url': url,
      'username': username,
      'password': password,
      'totpSecret': totpSecret,
      'notes': notes,
      'categoryId': categoryId,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }
}

/// Types of credentials the vault supports.
enum CredentialType {
  login('login'),
  card('card'),
  note('note'),
  identity('identity');

  final String value;
  const CredentialType(this.value);

  static CredentialType fromValue(String v) =>
      CredentialType.values.firstWhere((e) => e.value == v);
}
