/// Represents a user in the WishKit system.
class WishKitUser {
  /// Unique identifier for the user.
  final String uuid;

  const WishKitUser({
    required this.uuid,
  });

  factory WishKitUser.fromJson(Map<String, dynamic> json) {
    return WishKitUser(
      uuid: json['uuid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishKitUser && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}

/// User information that can be updated.
class UserInfo {
  /// Custom identifier for the user.
  String? customId;

  /// User's email address.
  String? email;

  /// User's display name.
  String? name;

  /// User's payment amount per month (in cents).
  int? paymentPerMonth;

  UserInfo({
    this.customId,
    this.email,
    this.name,
    this.paymentPerMonth,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (customId != null) map['customID'] = customId;
    if (email != null) map['email'] = email;
    if (name != null) map['name'] = name;
    if (paymentPerMonth != null) map['payment'] = paymentPerMonth;
    return map;
  }
}
