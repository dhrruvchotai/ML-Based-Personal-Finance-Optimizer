import 'dart:convert';

class UserModel {
  String? username;
  String? email;
  String? phoneNumber;
  String? profileImagePath;

  UserModel({
    this.username,
    this.email,
    this.phoneNumber,
    this.profileImagePath,
  });

  // Convert user model to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImagePath,
    };
  }

  // Create user model from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImagePath: json['profileImagePath'],
    );
  }

  // Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Create from JSON string
  factory UserModel.fromJsonString(String jsonString) {
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  // Copy with method to create a copy of the model with some fields updated
  UserModel copyWith({
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
  }) {
    return UserModel(
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
} 