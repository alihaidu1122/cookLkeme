class UserModel {
  final String id;
  final String username;
  final String profileImage;
  final String description;
  final int followers;
  final int following;
  final int posts;

  UserModel({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.description,
    required this.followers,
    required this.following,
    required this.posts,
  });

  // Convert JSON to Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("Parsing user JSON: $json"); // Debugging

    return UserModel(
      id: json['id'] ?? '', // ✅ Fix key mapping
      username: json['username'] ?? 'Unknown',
      profileImage: json['picture'] ??
          'https://example.com/default-avatar.png', // ✅ Match API key
      description: json['description'] ?? 'No bio available',
      followers: (json['followers'] as List?)?.length ?? 0, // ✅ Handle list
      following: (json['followings'] as List?)?.length ?? 0, // ✅ Handle list
      posts: json['posts'] ?? 0,
    );
  }

  // get length => null;
}
