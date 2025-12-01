
class CommentModel {
  final String id;
  final String text;
  final String postId;
  final String username;
  final String profilePic;
  final DateTime createdAt;

  CommentModel({
    required this.id,

    required this.username,

    required this.createdAt,
    required this.text,
    required this.postId,
    required this.profilePic,
  });

  CommentModel copyWith({
    String? id,
    String? text,
    String? postId,
    String? username,
    String? profilePic,
    DateTime? createdAt,
  }) {
    return CommentModel(
      id: id ?? this.id,

      username: username ?? this.username,

      createdAt: createdAt ?? this.createdAt,
      text: text ?? this.text,
      postId: postId ?? this.postId,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,

      'createdAt': createdAt.toIso8601String(),
      'text': text,
      'postId': postId,
      'profilePic': profilePic,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['\$id'] as String,

      username: map['username'] as String,

      createdAt: DateTime.parse(map['createdAt'] as String),
      text: map['text'] as String,
      postId: map['postId'] as String,
      profilePic: map['profilePic'] as String,
    );
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, text: $text, postId: $postId, username: $username, profilePic: $profilePic, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant CommentModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.postId == postId &&
        other.username == username &&
        other.createdAt == createdAt &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        createdAt.hashCode ^
        text.hashCode ^
        postId.hashCode ^
        profilePic.hashCode;
  }
}
