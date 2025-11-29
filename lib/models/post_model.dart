import 'package:flutter/foundation.dart';

class PostModel {
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String communityName;
  final String communityProfilePic;
  final String username;
  final String uid;
  final String type;
  final DateTime createdAt;
  final int commentCount;
  final List<String> upvotes;
  final List<String> downvotes;
  final List<String> awards;
  PostModel({
    required this.id,
    required this.title,
    this.link,
    this.description,
    required this.communityName,
    required this.communityProfilePic,
    required this.username,
    required this.uid,
    required this.type,
    required this.createdAt,
    required this.commentCount,
    required this.upvotes,
    required this.downvotes,
    required this.awards,
  });

  PostModel copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? communityName,
    String? communityProfilePic,
    String? username,
    String? uid,
    String? type,
    DateTime? createdAt,
    int? commentCount,
    List<String>? upvotes,
    List<String>? downvotes,
    List<String>? awards,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      communityName: communityName ?? this.communityName,
      communityProfilePic: communityProfilePic ?? this.communityProfilePic,
      username: username ?? this.username,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      commentCount: commentCount ?? this.commentCount,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      
      'title': title,
      'link': link,
      'description': description,
      'communityName': communityName,
      'communityProfilePic': communityProfilePic,
      'username': username,
      'uid': uid,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'commentCount': commentCount,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'awards': awards,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['\$id'] as String,
      title: map['title'] as String,
      link: map['link'] != null ? map['link'] as String : null,
      description: map['description'] != null
          ? map['description'] as String
          : null,
      communityName: map['communityName'] as String,
      communityProfilePic: map['communityProfilePic'] as String,
      username: map['username'] as String,
      uid: map['uid'] as String,
      type: map['type'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      commentCount: map['commentCount'] as int,
      upvotes: List<String>.from(
        (map['upvotes'] ?? []).map((x) => x as String),
      ),
      downvotes: List<String>.from(
        (map['downvotes'] ?? []).map((x) => x as String),
      ),
      awards: List<String>.from((map['awards'] ?? []).map((x) => x as String)),
    );
  }

  @override
  String toString() {
    return 'PostModel(id: $id, title: $title, link: $link, description: $description, communityName: $communityName, communityProfilePic: $communityProfilePic, username: $username, uid: $uid, type: $type, createdAt: $createdAt, commentCount: $commentCount, upvotes: $upvotes, downvotes: $downvotes, awards: $awards)';
  }

  @override
  bool operator ==(covariant PostModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.link == link &&
        other.description == description &&
        other.communityName == communityName &&
        other.communityProfilePic == communityProfilePic &&
        other.username == username &&
        other.uid == uid &&
        other.type == type &&
        other.createdAt == createdAt &&
        other.commentCount == commentCount &&
        listEquals(other.upvotes, upvotes) &&
        listEquals(other.downvotes, downvotes) &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        description.hashCode ^
        communityName.hashCode ^
        communityProfilePic.hashCode ^
        username.hashCode ^
        uid.hashCode ^
        type.hashCode ^
        createdAt.hashCode ^
        commentCount.hashCode ^
        upvotes.hashCode ^
        downvotes.hashCode ^
        awards.hashCode;
  }
}
