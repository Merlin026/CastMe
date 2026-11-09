import 'package:castme/design_course/home_design_course.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:url_launcher/url_launcher.dart';

class ActorViewMentorVideos extends StatelessWidget {
  const ActorViewMentorVideos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
        );
        return false;
      },
      child: MaterialApp(
        title: 'Mentor Videos',
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Mentor Videos"),
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DesignCourseHomeScreen()),
                );
              },
            ),
          ),
          body: UserViewDriversWidget(),
        ),
      ),
    );
  }
}

class UserViewDriversWidget extends StatefulWidget {
  const UserViewDriversWidget({Key? key}) : super(key: key);

  @override
  State<UserViewDriversWidget> createState() => _UserViewDriversState();
}

class _UserViewDriversState extends State<UserViewDriversWidget> {
  List<Map<String, dynamic>> driverData = [];
  List<Map<String, dynamic>> filteredDriverData = [];
  String baseUrl = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    for (Map<String, dynamic> data in driverData) {
      VideoPlayerController? videoPlayerController = data['controller'];
      ChewieController? chewieController = data['chewieController'];
      videoPlayerController?.dispose();
      chewieController?.dispose();
    }
    super.dispose();
  }

  void filterDriverData(String query) {
    setState(() {
      searchQuery = query;
      filteredDriverData = driverData
          .where((data) =>
      data["title"] != null &&
          data["title"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by title...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: filterDriverData,
          ),
        ),
        Expanded(
          child: filteredDriverData.isNotEmpty
              ? ListView.builder(
            itemCount: filteredDriverData.length,
            itemBuilder: (context, index) {
              return buildCard(index);
            },
          )
              : const Center(
            child: Text('No data available'),
          ),
        ),
      ],
    );
  }

  Widget buildCard(int index) {
    final videoData = filteredDriverData[index];

    // Check if the video URL is valid
    if (videoData["videos"] == null || videoData["videos"].isEmpty) {
      return Card(
        child: Column(
          children: const [
            SizedBox(height: 10),
            Text('Invalid video URL'),
          ],
        ),
      );
    }

    // Use pre-initialized controllers
    VideoPlayerController? videoPlayerController = videoData['controller'];
    ChewieController? chewieController = videoData['chewieController'];

    // If controllers are not initialized, initialize them
    if (videoPlayerController == null || chewieController == null) {
      String videoUrl = baseUrl + videoData["videos"];
      videoPlayerController = VideoPlayerController.network(videoUrl);
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: false, // Set to false to avoid autoplay during search
        looping: false,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              'Error loading video: $errorMessage',
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      // Store the controllers in the data map
      videoData['controller'] = videoPlayerController;
      videoData['chewieController'] = chewieController;
    }

    return Card(
      child: Column(
        children: [
          Container(
            height: 200,
            child: Chewie(controller: chewieController!),
          ),
          const SizedBox(height: 10),
          Text(
            videoData["title"] ?? 'No Title',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(videoData["description"] ?? 'No Description'),
          const SizedBox(height: 5),
          Text(videoData["date"] ?? 'No Date'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.thumb_up),
                onPressed: () {
                  showToast('Liked');
                },
              ),
              IconButton(
                icon: const Icon(Icons.comment),
                onPressed: () async {
                  await viewComments(videoData['notification_id'].toString());
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await launchUrl(Uri.parse(baseUrl + videoData["videos"]));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> getData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? '';
      String lid = sh.getString("lid") ?? '';
      baseUrl = ip + '/';

      final response = await http.post(
        Uri.parse("$baseUrl/api/actor_view_metor_videos"),
        body: {},
      );

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          List<Map<String, dynamic>> data =
          List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

          // Ensure that each item has a 'title' field
          for (var item in data) {
            item['title'] = item['title'] ?? 'No Title';
          }

          setState(() {
            driverData = data;
            filteredDriverData = data;
          });
        } else {
          showToast("Failed: ${jsonDecode(response.body)['message']}");
        }
      } else {
        showToast("Failed to load data. Server returned ${response.statusCode}");
      }
    } catch (error) {
      showToast("Error fetching data");
    }
  }

  Future<void> viewComments(String notificationId) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    TextEditingController commentController = TextEditingController();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/view_comment_based_videos"),
        body: {'notification_id': notificationId},
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        List comments = res['status'] == 'ok' ? res['data'] : [];

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.black.withOpacity(0.8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Comments Title
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Comments List
                    Flexible(
                      child: comments.isNotEmpty
                          ? SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  comments[index]['user_name'] != null &&
                                      comments[index]['user_name']
                                          .isNotEmpty
                                      ? comments[index]['user_name']
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  comments[index]['comment'] ?? ' ',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                          : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Be the first to comment!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Comment Input Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Add a comment...',
                                hintStyle:
                                const TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.white24,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              String commentText =
                              commentController.text.trim();
                              if (commentText.isNotEmpty) {
                                postComment(
                                    notificationId,
                                    commentText,
                                    setState,
                                    commentController,
                                    comments);
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    // Close Button
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      } else {
        showToast("Failed to load comments");
      }
    } catch (error) {
      showToast("Error loading comments");
    }
  }

  Future<void> postComment(
      String notificationId,
      String commentText,
      Function setState,
      TextEditingController commentController,
      List comments) async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    String lid = sh.getString("lid") ?? '';
    String name = sh.getString("name") ?? '';

    final response = await http.post(
      Uri.parse("$baseUrl/api/submit_comment"),
      body: {
        'video_id': notificationId,
        'comment': commentText,
        'lid': lid,
      },
    );

    if (response.statusCode == 200) {
      final res = jsonDecode(response.body);
      if (res['status'] == 'success') {
        showToast("Comment posted successfully");

        // Clear the text field after submitting the comment
        commentController.clear();

        // Add the new comment to the list directly
        setState(() {
          comments.insert(0, {
            'photo': 'default-avatar-url',
            'user_name': name,
            'comment': commentText,
          });
        });
      } else {
        showToast("Failed to post comment");
      }
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}