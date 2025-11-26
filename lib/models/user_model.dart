import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String email;
  final String profilePicture;
  final String bannerPicture;
  final String uid;
  final bool isAuthenticated;
  final int karma;
  final List<String> awards;
  UserModel({
    required this.name,
    required this.email,
    required this.profilePicture,
    required this.bannerPicture,
    required this.uid,
    required this.isAuthenticated,
    required this.karma,
    required this.awards,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? profilePicture,
    String? bannerPicture,
    String? uid,
    bool? isAuthenticated,
    int? karma,
    List<String>? awards,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      bannerPicture: bannerPicture ?? this.bannerPicture,
      uid: uid ?? this.uid,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'bannerPicture': bannerPicture,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      email: map['email'] as String,
      profilePicture: map['profilePicture'] as String,
      bannerPicture: map['bannerPicture'] as String,
      uid: map['\$id'] as String,
      isAuthenticated: map['isAuthenticated'] as bool,
      karma: map['karma'] as int,
      awards: List<String>.from((map['awards'] ?? []).map((x) => x as String)),
    );
  }

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, profilePicture: $profilePicture, bannerPicture: $bannerPicture, uid: $uid, isAuthenticated: $isAuthenticated, karma: $karma, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.email == email &&
        other.profilePicture == profilePicture &&
        other.bannerPicture == bannerPicture &&
        other.uid == uid &&
        other.isAuthenticated == isAuthenticated &&
        other.karma == karma &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        profilePicture.hashCode ^
        bannerPicture.hashCode ^
        uid.hashCode ^
        isAuthenticated.hashCode ^
        karma.hashCode ^
        awards.hashCode;
  }
}
