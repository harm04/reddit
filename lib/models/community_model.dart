import 'package:flutter/foundation.dart';

class CommunityModel {
  final String name;
  final String description;
  final String avatar;
  final String banner;
  final String id;
  final List<String> members;
  final List<String> mods;
  CommunityModel({
    required this.name,
    required this.description,
    required this.avatar,
    required this.banner,
    required this.id,
    required this.members,
    required this.mods,
  });

  CommunityModel copyWith({
    String? name,
    String? description,
    String? avatar,
    String? banner,
    String? id,
    List<String>? members,
    List<String>? mods,
  }) {
    return CommunityModel(
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      banner: banner ?? this.banner,
      id: id ?? this.id,
      members: members ?? this.members,
      mods: mods ?? this.mods,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'avatar': avatar,
      'banner': banner,

      'members': members,
      'mods': mods,
    };
  }

  factory CommunityModel.fromMap(Map<String, dynamic> map) {
    return CommunityModel(
      name: map['name'] as String,
      description: map['description'] as String,
      avatar: map['avatar'] as String,
      banner: map['banner'] as String,
      id: map['\$id'] as String,
      members: List<String>.from(
        (map['members'] ?? []).map((x) => x as String),
      ),
      mods: List<String>.from((map['mods'] ?? []).map((x) => x as String)),
    );
  }

  @override
  String toString() {
    return 'CommunityModel(name: $name, description: $description, avatar: $avatar, banner: $banner, id: $id, members: $members, mods: $mods)';
  }

  @override
  bool operator ==(covariant CommunityModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.description == description &&
        other.avatar == avatar &&
        other.banner == banner &&
        other.id == id &&
        listEquals(other.members, members) &&
        listEquals(other.mods, mods);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        description.hashCode ^
        avatar.hashCode ^
        banner.hashCode ^
        id.hashCode ^
        members.hashCode ^
        mods.hashCode;
  }
}
