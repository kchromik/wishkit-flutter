import 'comment.dart';
import 'user.dart';
import 'wish_state.dart';

/// Represents a wish/feature request.
class Wish {
  /// Unique identifier for the wish.
  final String id;

  /// UUID of the user who created this wish.
  final String userUUID;

  /// Title of the wish.
  final String title;

  /// Detailed description of the wish.
  final String description;

  /// Current state of the wish.
  final WishState state;

  /// List of users who voted for this wish.
  final List<WishKitUser> votingUsers;

  /// List of comments on this wish.
  final List<Comment> comments;

  const Wish({
    required this.id,
    required this.userUUID,
    required this.title,
    required this.description,
    required this.state,
    required this.votingUsers,
    required this.comments,
  });

  /// Number of votes this wish has received.
  int get voteCount => votingUsers.length;

  /// Check if a user has voted for this wish.
  bool hasUserVoted(String userUUID) {
    return votingUsers.any((user) => user.uuid == userUUID);
  }

  factory Wish.fromJson(Map<String, dynamic> json) {
    return Wish(
      id: json['id'] as String,
      userUUID: json['userUUID'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      state: WishState.fromString(json['state'] as String? ?? 'pending'),
      votingUsers: (json['votingUsers'] as List<dynamic>?)
              ?.map((e) => WishKitUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      comments: (json['commentList'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userUUID': userUUID,
      'title': title,
      'description': description,
      'state': state.toApiString(),
      'votingUsers': votingUsers.map((e) => e.toJson()).toList(),
      'commentList': comments.map((e) => e.toJson()).toList(),
    };
  }

  Wish copyWith({
    String? id,
    String? userUUID,
    String? title,
    String? description,
    WishState? state,
    List<WishKitUser>? votingUsers,
    List<Comment>? comments,
  }) {
    return Wish(
      id: id ?? this.id,
      userUUID: userUUID ?? this.userUUID,
      title: title ?? this.title,
      description: description ?? this.description,
      state: state ?? this.state,
      votingUsers: votingUsers ?? this.votingUsers,
      comments: comments ?? this.comments,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Wish && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Request to create a new wish.
class CreateWishRequest {
  /// Title of the wish (max 50 characters).
  final String title;

  /// Description of the wish (max 500 characters).
  final String description;

  /// Optional email of the submitter.
  final String? email;

  const CreateWishRequest({
    required this.title,
    required this.description,
    this.email,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
    };
    if (email != null && email!.isNotEmpty) {
      map['email'] = email;
    }
    return map;
  }
}

/// Request to vote on a wish.
class VoteWishRequest {
  /// The ID of the wish to vote on.
  final String wishId;

  const VoteWishRequest({
    required this.wishId,
  });

  Map<String, dynamic> toJson() {
    return {
      'wishId': wishId,
    };
  }
}
