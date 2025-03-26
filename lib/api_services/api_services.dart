import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cooklkeme_createx_project/model/video_model.dart';
import 'package:cooklkeme_createx_project/model/profile_model.dart';

class VideoService {
  static const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2I4NjlkZjg4YzdjNTk5NmQxNWUyNmIiLCJpYXQiOjE3NDI3MjQ1NDR9.r7qEG6GloLw7TJfl6P-GxemiWfPjnymY7HIRtG2VO40";

  static Future<List<Video>> fetchVideos() async {
    final response = await http.get(
      Uri.parse(
          'https://cooklikeme2.azurewebsites.net/api/post/get-trending-posts?pageNumber=5&itemsPerPage=5'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    // print("Response Status Code: ${response.statusCode}");
    // print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);

      if (jsonData.containsKey('posts')) {
        final List<dynamic> videoList = jsonData['posts'];
        return videoList.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format: "posts" key not found.');
      }
    } else {
      throw Exception('Failed to load videos: ${response.body}');
    }
  }

  
}












class UserService {
  static Future<UserModel?> fetchUserProfile(String userId) async {
    final url =
        'https://cooklikeme2.azurewebsites.net/api/users/other-user-profile?userId=$userId';
    print("Fetching profile from: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization':
              'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI2N2I4NjlkZjg4YzdjNTk5NmQxNWUyNmIiLCJpYXQiOjE3NDI3MjQ1NDR9.r7qEG6GloLw7TJfl6P-GxemiWfPjnymY7HIRtG2VO40', // Replace with actual token
          'Content-Type': 'application/json',
        },
      );

      // print("Response Status Code: ${response.statusCode}");
      // print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData.containsKey('profile')) {
          print("Profile Data: ${jsonData['profile']}");
          return UserModel.fromJson(jsonData['profile']);
        } else {
          print("Error: 'profile' key not found in response");
        }
      } else {
        print("Error: API responded with status code ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }

    return null; 
  }
}
