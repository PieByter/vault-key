/// User-defined or system category for grouping credentials.
class CredentialCategory {
  final String id;
  final String userId;
  final String name;
  final String? icon; // icon codepoint name, e.g. "shield"
  final int sortOrder;
  final bool isSystem; // built-in categories
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const CredentialCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.icon,
    this.sortOrder = 0,
    this.isSystem = false,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  CredentialCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    int? sortOrder,
    bool? isSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return CredentialCategory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  factory CredentialCategory.fromJson(Map<String, dynamic> json) {
    return CredentialCategory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isSystem: json['isSystem'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'isSystem': isSystem,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Built-in default categories for new users.
  static List<CredentialCategory> defaults(String userId) {
    final now = DateTime.now();
    return [
      CredentialCategory(
        id: 'sys_logins',
        userId: userId,
        name: 'Logins',
        icon: 'key',
        sortOrder: 0,
        isSystem: true,
        createdAt: now,
        updatedAt: now,
      ),
      CredentialCategory(
        id: 'sys_cards',
        userId: userId,
        name: 'Cards',
        icon: 'credit_card',
        sortOrder: 1,
        isSystem: true,
        createdAt: now,
        updatedAt: now,
      ),
      CredentialCategory(
        id: 'sys_notes',
        userId: userId,
        name: 'Secure Notes',
        icon: 'note',
        sortOrder: 2,
        isSystem: true,
        createdAt: now,
        updatedAt: now,
      ),
      CredentialCategory(
        id: 'sys_identity',
        userId: userId,
        name: 'Identity',
        icon: 'person',
        sortOrder: 3,
        isSystem: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
