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

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
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
