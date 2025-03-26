import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cooklkeme_createx_project/model/video_model.dart';

class UserProvider with ChangeNotifier {
  List<Video> _videos = [];

  List<Video> get videos => _videos;

  // Fetch videos from API
  Future<List<Video>> fetchVideos() async {
    final url = Uri.parse('https://cooklikeme2.azurewebsites.net/api/videos');
    final token = await _getToken();

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _videos = data.map((json) => Video.fromJson(json)).toList();
        notifyListeners();
        return _videos;
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (error) {
      print("API Error: $error");
      throw Exception("Failed to load videos");
    }
  }

  void setVideos(List<Video> videos) {
    _videos = videos;
    notifyListeners();
  }

  Future<void> toggleLike(int index) async {
    if (index >= _videos.length) return;

    bool isCurrentlyLiked = _videos[index].isLiked;
    _videos[index].isLiked = !isCurrentlyLiked;

    if (isCurrentlyLiked) {
      if (_videos[index].likes > 0) _videos[index].likes -= 1;
    } else {
      _videos[index].likes += 1;
    }

    notifyListeners();

    // API call
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(
            'https://cooklikeme2.azurewebsites.net/api/like/${_videos[index].id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update like status");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> toggleSave(int index) async {
    if (index >= _videos.length) return;

    bool isCurrentlySaved = _videos[index].isSaved;
    _videos[index].isSaved = !isCurrentlySaved;

    if (isCurrentlySaved) {
      if (_videos[index].saves > 0) _videos[index].saves -= 1;
    } else {
      _videos[index].saves += 1;
    }

    notifyListeners();

    // API call
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(
            'https://cooklikeme2.azurewebsites.net/api/save/${_videos[index].id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update save status");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String> _getToken() async {
    return "your-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2I4NjlkZjg4YzdjNTk5NmQxNWUyNmIiLCJpYXQiOjE3NDI3MjQ1NDR9.r7qEG6GloLw7TJfl6P-GxemiWfPjnymY7HIRtG2VO40-token"; // Replace with actual token logic
  }

  // video controller

  int _currentIndex = 0;
  int get index => _currentIndex;

  void _onPageChanged(int index) {
    _currentIndex = index;

    notifyListeners();
  }
}
