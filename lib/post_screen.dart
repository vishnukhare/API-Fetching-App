import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading_indicator/loading_indicator.dart';
import 'post_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Post>? posts = [];
  bool isLoading = true;
  String? errorMessage;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      _updateConnectionStatus(result);
    });

    fetchPosts();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // result = await _connectivity.checkConnectivity();
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print('Could not check connectivity status: $e');
      return;
    }
    if (!mounted) {
      return;
    }
    _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus =
          result.isNotEmpty ? result.first : ConnectivityResult.none;
    });
    if (_connectionStatus != ConnectivityResult.none && posts == null) {
      fetchPosts();
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> parsedList = jsonDecode(response.body);
        setState(() {
          posts = parsedList.map((json) => Post.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load posts. Status code: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blog Posts',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (_connectionStatus == ConnectivityResult.none) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 48.0),
            SizedBox(height: 8.0),
            Text(
              'No internet connection. Please check your network settings.',
              style: TextStyle(fontSize: 16.0, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                initConnectivity();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.width * 0.1,
              child: Align(
                alignment: Alignment.center,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.blue, Colors.purple],
                  strokeWidth: 2,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text('Loading posts...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    } else if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48.0),
            SizedBox(height: 8.0),
            Text(
              'Failed to fetch posts. Please check your internet connection and try again.',
              style: TextStyle(fontSize: 16.0, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                fetchPosts();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    } else if (posts == null || posts!.isEmpty) {
      return Center(
        child: Text('No posts found.', style: TextStyle(fontSize: 16.0)),
      );
    } else {
      return ListView.separated(
        itemCount: posts!.length,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          final post = posts![index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 6.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.0, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
