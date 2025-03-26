class Video {
  final String url;
  final String id;
  final String description;
  final String username;
  int likes;
  final int comments;
  final String image;
   int saves;
  final int share;
  bool isLiked;
  bool isSaved;
    // final String url;
  String? thumbnail; // Add a field for storing the thumbnail


  Video({
    required this.url,
    required this.id,
    required this.description,
    required this.username,
    required this.likes,
    required this.comments,
    required this.image,
    required this.saves,
    required this.share,
    required this.isLiked,
    required this.isSaved,
    this.thumbnail
    
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      url: json['video'] ?? '',
      id: json['_id'] ?? '',
      description: json['description'] ?? 'No description',
      username: json['owner']?['name'] ?? 'Unknown',
      image: json['owner']?['picture'] ??
          'https://www.w3schools.com/howto/img_avatar.png',
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      saves: json['saves'] ?? 0,
      share: json['shares'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }
}
