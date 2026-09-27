/// Represents a comment on a wish.
class Comment {
  /// Unique identifier for the comment.
  final String id;

  /// The comment text.
  final String description;

  /// When the comment was created.
  final DateTime createdAt;

  /// Whether this comment was made by an admin.
  final bool isAdmin;

  const Comment({
    required this.id,
    required this.description,
    required this.createdAt,
    required this.isAdmin,
  });

  /// Builds a comment, tolerating a missing or unparseable `createdAt`.
  ///
  /// The old `DateTime.parse(createdAtRaw.toString())` threw on `null` and on any
  /// format the API had not promised, and it threw from inside
  /// `Wish.fromJson` — so one malformed timestamp anywhere in the list took the
  /// entire board down with a red screen. A comment with an unknown date is
  /// still a comment; the timestamp is simply omitted, which
  /// `CommentListRow` handles by hiding it.
  factory Comment.fromJson(Map<String, dynamic> json) {
    // Support both camelCase and snake_case keys from the server.
    final createdAtRaw = json['createdAt'] ?? json['created_at'];
    final isAdminRaw = json['isAdmin'] ?? json['is_admin'];

    return Comment(
      id: json['id']?.toString() ?? '',
      description: (json['description'] ?? '').toString(),
      createdAt: _parseDate(createdAtRaw) ?? DateTime.fromMillisecondsSinceEpoch(0),
      isAdmin: isAdminRaw == true,
    );
  }

  /// Whether [createdAt] is a real timestamp rather than the epoch placeholder.
  ///
  /// A placeholder from a missing field reads as 1 January 1970, which is
  /// noise; callers use this to decide whether to render a date at all.
  bool get hasKnownDate => createdAt.millisecondsSinceEpoch != 0;

  /// Parses the API's timestamp format, or the ISO-8601 fallback.
  ///
  /// The API sends `yyyy-MM-dd HH:mm:ss` (no zone designator) for some
  /// endpoints and full ISO-8601 for others; both are accepted, and anything
  /// else yields `null`.
  static DateTime? _parseDate(Object? raw) {
    if (raw is DateTime) return raw;
    if (raw is! String || raw.isEmpty) return null;

    final iso = DateTime.tryParse(raw);
    if (iso != null) return iso;

    // `DateTime.parse` needs the `T`; the API sends a space.
    return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'isAdmin': isAdmin,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Comment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Request to create a new comment.
class CreateCommentRequest {
  /// The ID of the wish to comment on.
  final String wishId;

  /// The comment text.
  final String description;

  const CreateCommentRequest({
    required this.wishId,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'wishId': wishId,
      'description': description,
    };
  }
}
