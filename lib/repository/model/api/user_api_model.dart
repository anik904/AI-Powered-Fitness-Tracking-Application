class UserRegisterRequest {
  final String firebaseUid;
  final String email;
  final String? displayName;

  UserRegisterRequest({
    required this.firebaseUid,
    required this.email,
    this.displayName,
  });

  Map<String, dynamic> toJson() => {
    'firebase_uid': firebaseUid,
    'email': email,
    'display_name': displayName,
  };
}

class UserResponseModel {
  final int id;
  final String firebaseUid;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserResponseModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      id: json['id'] as int,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firebase_uid': firebaseUid,
    'email': email,
    'display_name': displayName,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
