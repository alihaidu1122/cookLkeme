import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cooklkeme_createx_project/constant/colors.dart';
import 'package:cooklkeme_createx_project/model/video_model.dart';
import 'package:cooklkeme_createx_project/model/profile_model.dart';
import 'package:cooklkeme_createx_project/view/video_feed_screen.dart';
import 'package:cooklkeme_createx_project/api_services/api_services.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Video>> _videoListFuture;
  UserModel? userModel;
  bool isLoading = true;
  final Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    loadUserProfile();
    _videoListFuture = VideoService.fetchVideos();
  }
  

  
  Future<void> loadUserProfile() async {
    try {
      UserModel? profile = await UserService.fetchUserProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        userModel = profile;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
     appBar: AppBar(
  centerTitle: true,
  title: Text(
    userModel?.username.toString() ?? 'Unkown',
    style: const TextStyle(color: whiteTextColor, fontSize: 15),
  ),
  backgroundColor: lightDarkColor60,
  leading: IconButton(
    icon: const Icon(
      Icons.arrow_back_ios,
      color: whiteTextColor,
      size: 15,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  ),
),

      backgroundColor: Colors.black,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none, // Allow the avatar to overflow
                      alignment: Alignment.center,
                      children: [
                        ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30)),
                            child: Container(child: buildCoverImage())),
                        Positioned(
                            bottom: -40,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.black,
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.grey[800],
                                backgroundImage:
                                    userModel?.profileImage != null &&
                                            userModel!.profileImage!.isNotEmpty
                                        ? NetworkImage(userModel!.profileImage!)
                                        : null, // Set null to use child instead
                                child: userModel?.profileImage == null ||
                                        userModel!.profileImage!.isEmpty
                                    ? const Icon(Icons.person,
                                        size: 48, color: Colors.white)
                                    : null, // Show icon only when no image
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Text(
                      userModel?.username ?? "Unknown",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userModel != null
                          ? "@${userModel!.username}"
                          : "@unknown",
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildStatColumn(userModel?.posts ?? 0, "Posts"),
                          buildStatColumn(
                              userModel?.followers ?? 0, "Followers"),
                          buildStatColumn(
                              userModel?.following ?? 0, "Following"),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: width * .34,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orangeButtonColor,
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Follow",
                              style: TextStyle(color: whiteTextColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: width * .34,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dOrangeButtonColor,
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Message",
                              style: TextStyle(color: whiteTextColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                     Padding(
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(color: Color(0xFF393532),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  "Recent Posts",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                        height: width * .99,
                        width: double.infinity,
                        child: _buildForYouScreen())
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildStatColumn(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          Text(
            "$value",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget buildCoverImage() {
    if (userModel?.profileImage != null &&
        userModel!.profileImage!.isNotEmpty) {
      return Image.network(
        userModel!.profileImage!,
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[800],
            child: const Icon(Icons.image, size: 50, color: Colors.white),
          );
        },
      );
    } else {
      return Container(
        width: double.infinity,
        height: 150,
        color: Colors.grey[800], // Background color
        child: const Icon(Icons.image, size: 50, color: Colors.white),
      );
    }
  }

  Widget _buildForYouScreen() {
    var width = MediaQuery.of(context).size.width;

    return FutureBuilder<List<Video>>(
      future: _videoListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No videos found"));
        }

        final videos = snapshot.data!;

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];

            return FutureBuilder<File?>(
              future: generateThumbnail(video.url),
              builder: (context, thumbnailSnapshot) {
                if (thumbnailSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (thumbnailSnapshot.hasError ||
                    thumbnailSnapshot.data == null) {
                  return Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.video_collection,
                        size: 50, color: Colors.white),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoFeedScreen(video: video),
                      ),
                    );
                  },
                  child: GridTile(
                    child: Container(
                      height: width * .3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: FileImage(thumbnailSnapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<File?> generateThumbnail(String videoUrl) async {
    try {
      final directory = await getTemporaryDirectory();
      final String? thumbPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: directory.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 100,
        quality: 75,
      );

      if (thumbPath == null || thumbPath.isEmpty) {
        return null; // Fallback to default image
      }

      return File(thumbPath);
    } catch (e) {
      print("Thumbnail generation error: $e");
      return null; // Fallback to default image
    }
  }
}
