import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';
import 'package:cooklkeme_createx_project/constant/colors.dart';
import 'package:cooklkeme_createx_project/model/video_model.dart';
import 'package:cooklkeme_createx_project/api_services/api_services.dart';
import 'package:cooklkeme_createx_project/controller/user_controller.dart';
import 'package:cooklkeme_createx_project/view/profile_screen/profile_screen.dart';

class VideoFeedScreen extends StatefulWidget {
  final Video video;

  const VideoFeedScreen({super.key, required this.video});

  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  late Future<List<Video>> _videoListFuture;
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _expandedStates = {}; // Track expansion states

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _videoListFuture = VideoService.fetchVideos();
      _videoListFuture = VideoService.fetchVideos();
  }

  Future<List<Video>> fetchAndSetVideos() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final videos = await provider.fetchVideos(); // Fetch from API
    provider.setVideos(videos);
    return videos;
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  VideoPlayerController _getOrCreateController(int index, String url) {
    if (!_controllers.containsKey(index)) {
      _controllers[index] = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
          _controllers[index]!.setLooping(true);
          _controllers[index]!.play(); // Auto-play video
        });
    }
    return _controllers[index]!;
  }

  void _toggleLike(String videoId) {
    print("Liked video ID: $videoId");
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
  final provider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: greyColor,
      body: FutureBuilder<List<Video>>(
        future: _videoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No videos found"));
          }

          final videos = snapshot.data!;

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _controllers[_currentIndex]?.play();
                if (_controllers.containsKey(_currentIndex - 1)) {
                  _controllers[_currentIndex - 1]?.pause();
                }
              });
            },
            itemBuilder: (context, index) {
              final video = videos[index];
              final controller = _getOrCreateController(index, video.url);

              return Stack(
                children: [
                  Positioned.fill(
                    child: controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),

                  Positioned(
                    child: Container(
                      height: width * 0.2,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 30, left: 10, bottom: 20),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                size: 20,
                                color: Colors.white, // Ensure visibility
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 20,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile & Follow Section
                        _buildProfileRow(context, video, width),
                        const SizedBox(height: 10),

                        // Video Description
                        _buildDescriptionText(index, video.description),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Like, Save, Share Buttons
                  Positioned(
                      right: 15,
                      bottom: 100,
                      child: Consumer<UserProvider>(
                          builder: (context, provider, child) {
                        return Column(
                          children: [
                            _buildIconButton(
                              videos[index].isLiked ? Colors.red : Colors.white,
                              context,
                              'assets/icons/heartf.svg',
                              videos[index].likes.toString(),
                              () {
                                //  print(videos.length);
                                provider.toggleLike(index);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildIconButton(
                              Colors.white,
                              context,
                              'assets/icons/comm.svg',
                              videos[index].comments.toString(),
                              () {
                                // Handle comment
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildIconButton(
                              videos[index].isSaved
                                  ? Colors.yellow
                                  : Colors.white,
                              context,
                              'assets/icons/savef.svg',
                              videos[index].saves.toString(),
                              () {
                                Provider.of<UserProvider>(context,
                                        listen: false)
                                    .setVideos(videos);
                                provider.toggleSave(index);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildIconButton(
                              Colors.white,
                              context,
                              'assets/icons/share.svg',
                              videos[index].share.toString(),
                              () {
                                // Handle share
                              },
                            ),
                          ],
                        );
                      })),
              
                ],
              );
            },
          );
        },
      ),
    );
  }



  Widget _buildIconButton(
    Color color,
    BuildContext context,
    String icon,
    String label,
    VoidCallback onTap,
  ) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: width * .05,
            backgroundColor: Colors.transparent,
            child: SvgPicture.asset(icon, // Replace with your SVG file path
                height: width * .09, // Adjust size if needed
                // width: 40,
                color: color // Apply color if needed
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProfileRow(BuildContext context, Video video, double width) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(userId: video.id),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: video.image.isNotEmpty
                    ? NetworkImage(video.image)
                    : const AssetImage('assets/images/1.png') as ImageProvider,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: Text(
                  '@${video.username}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: width * .03),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                child: Text(
                  'Follow',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText(int index, String text) {
    int maxLength = 50;
    _expandedStates.putIfAbsent(index, () => false);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedStates[index] = !_expandedStates[index]!;
        });
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _expandedStates[index]! || text.length <= maxLength
                  ? text
                  : '${text.substring(0, maxLength)}...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (text.length > maxLength)
              TextSpan(
                text: _expandedStates[index]! ? " See Less" : " See More",
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildIconButton(String icon, String label, VoidCallback onTap) {
  //   return Column(
  //     children: [
  //       GestureDetector(
  //         onTap: onTap,
  //         child: SvgPicture.asset(
  //           icon,
  //           height: 40,
  //           color: Colors.white,
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: const TextStyle(color: Colors.white, fontSize: 12),
  //       ),
  //     ],
  //   );
  // }


}
