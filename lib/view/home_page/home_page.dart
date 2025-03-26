import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cooklkeme_createx_project/constant/colors.dart';
import 'package:cooklkeme_createx_project/model/video_model.dart';
import 'package:cooklkeme_createx_project/model/profile_model.dart';
import 'package:cooklkeme_createx_project/api_services/api_services.dart';
import 'package:cooklkeme_createx_project/controller/user_controller.dart';
import 'package:cooklkeme_createx_project/view/profile_screen/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<Video>> _videoListFuture;
  late Future<List<UserModel>> _userListFuture;
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _expandedStates = {};
  int _currentIndex = 0;
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: 3);
    _videoListFuture = VideoService.fetchVideos();
    // _videoListFuture = fetchAndSetVideos();
  }

  Future<List<Video>> fetchAndSetVideos() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    final videos = await provider.fetchVideos(); // Fetch from API
    provider.setVideos(videos); // Store in provider
    return videos;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeVideo(int index, String url) {
    if (!_controllers.containsKey(index)) {
      _controllers[index] = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
          if (index == _currentIndex) {
            _playVideo(index);
          }
        }).catchError((error) {
          print("Error loading video: $error");
        });
    }
  }

  void _playVideo(int index) {
    _pauseAllVideos();
    if (_controllers.containsKey(index)) {
      _controllers[index]?.play();
      _controllers[index]?.setLooping(true);
    }
  }

  void _pauseAllVideos() {
    for (var controller in _controllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _playVideo(index);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: greyColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        shape: const CircleBorder(),
        backgroundColor: dOrangeButtonColor,
        child: const Icon(Icons.add, size: 35, color: whiteTextColor),
      ),
      bottomNavigationBar: BottomAppBar(
        height: width * .2,
        color: Colors.black.withOpacity(0.4),
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        child: Row(
          children: [
            _buildNavItem('assets/icons/home.svg', "Home", 0, context),
            _buildNavItem('assets/icons/explore.svg', "Explore", 1, context),
            const Expanded(child: SizedBox()), // Space for FAB
            _buildNavItem('assets/icons/commnet.svg', "Inbox", 2, context),
            _buildNavItem('assets/icons/proo.svg', "Profile", 3, context),
          ],
        ),
      ),
      body: _getSelectedScreen(),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildTabView(); // Video PageView with tabs
      case 1:
        return const Center(
            child:
                Text("Explore Screen", style: TextStyle(color: Colors.white)));
      case 2:
        return const Center(
            child: Text("Inbox Screen", style: TextStyle(color: Colors.white)));
      case 3:
        return const ProfileScreen(
          userId: '',
        );
      default:
        return _buildTabView();
    }
  }

  Widget _buildTabView() {
    return Stack(
      children: [
        Positioned.fill(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFollowingScreen(),
              const Center(
                  child: Text("Tab 3 Content",
                      style: TextStyle(color: Colors.white))),
              const Center(
                  child: Text("Tab 4 Content",
                      style: TextStyle(color: Colors.white))),
              _buildForYouScreen(),
              const Center(
                  child: Text("Tab 5 Content",
                      style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
        Positioned(
          top: 25,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.black.withOpacity(0.4),
            padding: const EdgeInsets.only(top: 5, bottom: 8),
            child: TabBar(
              controller: _tabController,
              labelColor: whiteTextColor,
              unselectedLabelColor: greyColor,
              indicatorColor: whiteTextColor,
              indicatorSize: TabBarIndicatorSize.label,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              dividerColor: Colors.transparent,
              labelPadding: const EdgeInsets.symmetric(horizontal: 10),
              labelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10), // Moves the icon down
                      Icon(Icons.bar_chart, size: 25, color: whiteTextColor),
                    ],
                  ),
                ),

                Tab(text: "Map"),
                Tab(text: "Following"),
                Tab(text: "For You"),

                // 🔍 Search icon (right)
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 10), // Moves the icon down
                      FaIcon(FontAwesomeIcons.magnifyingGlass,
                          size: 20, color: whiteTextColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForYouScreen() {
    var width = MediaQuery.of(context).size.width;
    final provider = Provider.of<UserProvider>(context, listen: false);
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

        return PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: videos.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            _initializeVideo(index, videos[index].url);
            // print(videos[index].likes.toString());
            // print(videos[index].comments.toString());
            return GestureDetector(
              onTap: () {
                // Play/Pause Toggle
                if (_controllers[index]!.value.isPlaying) {
                  _controllers[index]!.pause();
                } else {
                  _controllers[index]!.play();
                }
                setState(() {});
              },
              child: Stack(
                children: [
                  // Video Player
                  Positioned.fill(
                    child: _controllers.containsKey(index) &&
                            _controllers[index]!.value.isInitialized
                        ? Center(
                            child: AspectRatio(
                              aspectRatio:
                                  _controllers[index]!.value.aspectRatio,
                              child: VideoPlayer(_controllers[index]!),
                            ),
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),

                  // Play/Pause Icon
                  if (_controllers[index]!.value.isPlaying == false)
                    Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),

                  // User info & description
                  Positioned(
                    bottom: 18,
                    left: 15,
                    right: 15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                        userId: videos[index]
                                            .id), // Ensure correct userId
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        videos[index].image.isNotEmpty
                                            ? NetworkImage(
                                                videos[index].image.toString())
                                            : const AssetImage(
                                                    'assets/images/1.png')
                                                as ImageProvider,
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      '@${videos[index].username}',
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
                            // SizedBox(width: width * .03),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.white, width: 1)),
                                child: const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 1),
                                    child: Text(
                                      'Follow',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                        _buildDescriptionText(index, videos[index].description),
                      ],
                    ),
                  ),

                  // Buttons (Like, Comment, Save, Share)
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
              ),
            );
          },
        );
      },
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

  Widget _buildDescriptionText(int index, String text) {
    int maxLength = 50;

    // Ensure expansion state is initialized
    _expandedStates.putIfAbsent(index, () => false);

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedStates[index] = !_expandedStates[index]!; // Toggle expansion
        });
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _expandedStates[index]! || text.length <= maxLength
                  ? text
                  : '${text.substring(0, maxLength)}...',
              style: const TextStyle(color: whiteTextColor, fontSize: 16),
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

  Widget _buildFollowingScreen() {
    return const Center(
      child: Text("Following Screen (Coming Soon)",
          style: TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  Widget _buildNavItem(
      String icon, String label, int index, BuildContext Context) {
    var width = MediaQuery.of(Context).size.width;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              height: width * .07,
              width: 40,
              color:
                  _selectedIndex == index ? orangeButtonColor : whiteTextColor,
            ),
            Text(label,
                style: TextStyle(
                    color: _selectedIndex == index
                        ? orangeButtonColor
                        : whiteTextColor,
                    fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // void toggleLike(
  //   int index,
  //   List<Video> videos,
  // ) async {
  //   setState(() {
  //     videos[index].isLiked = !videos[index].isLiked;
  //     videos[index].likes += videos[index].isLiked ? 1 : -1; // Update count
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           'https://cooklikeme2.azurewebsites.net/api/like/${videos[index].id}'),
  //       headers: {
  //         'Authorization':
  //             'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2I4NjlkZjg4YzdjNTk5NmQxNWUyNmIiLCJpYXQiOjE3NDI3MjQ1NDR9.r7qEG6GloLw7TJfl6P-GxemiWfPjnymY7HIRtG2VO40',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       setState(() {
  //         videos[index].isLiked = !videos[index].isLiked;
  //         videos[index].likes += videos[index].isLiked ? 1 : -1;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       videos[index].isLiked = !videos[index].isLiked;
  //       videos[index].likes += videos[index].isLiked ? 1 : -1;
  //     });
  //   }
  // }

  // void toggleSave(int index, List<Video> videos) async {
  //   setState(() {
  //     videos[index].isSaved = !videos[index].isSaved;
  //     videos[index].saves += videos[index].isSaved ? 1 : -1;
  //   });

  //   try {
  //     final response = await http.post(
  //       Uri.parse(
  //           'https://cooklikeme2.azurewebsites.net/api/save/${videos[index].id}'),
  //       headers: {
  //         'Authorization':
  //             'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2I4NjlkZjg4YzdjNTk5NmQxNWUyNmIiLCJpYXQiOjE3NDI3MjQ1NDR9.r7qEG6GloLw7TJfl6P-GxemiWfPjnymY7HIRtG2VO40',
  //         'Content-Type': 'application/json',
  //       },
  //     );

  //     if (response.statusCode != 200) {
  //       setState(() {
  //         videos[index].isSaved = !videos[index].isSaved;
  //         videos[index].saves += videos[index].isSaved ? 1 : -1;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       videos[index].isSaved = !videos[index].isSaved;
  //       videos[index].saves += videos[index].isSaved ? 1 : -1;
  //     });
  //   }
  // }
}
