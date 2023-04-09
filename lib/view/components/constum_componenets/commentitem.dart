import 'package:esprit_alumni_frontend/view/components/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../viewmodel/profileViewModel.dart';
import '../../screens/Profile/profile.dart';

class CommentItem extends StatefulWidget {
  final String username;
  final String profilePictureUrl;
  final String comment;
  final String timestamp;
  int likes;
  final String userId;
  final String commentId;
  final List<String> likesList;
  final VoidCallback onCommentDeleted;
  final String? user;

  CommentItem({
    required this.username,
    required this.profilePictureUrl,
    required this.comment,
    required this.timestamp,
    required this.likes,
    required this.userId,
    required this.commentId,
    required this.likesList,
    required this.onCommentDeleted,
    required this.user,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isLiked = false;
  late SharedPreferences _prefs;
  String? token = "";
  String? id = "";

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      token = _prefs.getString('userId') ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    _isLiked = widget.likesList.contains(widget.userId);
    _initializePrefs();
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return FractionallySizedBox(
          widthFactor: 0.8,
          heightFactor: 0.5,
          child: AlertDialog(
            title: Text('Delete comment'),
            content: Text('Are you sure you want to delete this comment?'),
            actions: [
              TextButton(
                onPressed: () async {
                  final isDeleted = await ProfileViewModel.deleteComment(
                    token!,
                    widget.commentId,
                    context,
                  );
                  if (isDeleted) {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pop(context, false);
                  }
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('No'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      widget.onCommentDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.profilePictureUrl),
            radius: 24.0,
          ),
          SizedBox(width: 5.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () {
                    Map<String, dynamic> decodedToken =
                        JwtDecoder.decode(token!);
                    id = decodedToken['id'] ?? "";
                    if (id == widget.userId) {
                      _showDeleteConfirmationDialog();
                    }
                  },
                  child: Card(
                    elevation: 0.0,
                    color: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30.0),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Profile(
                                      user: widget.user!,
                                      isCurrentUser: false,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                widget.username,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 5.0),
                            Text(widget.comment,
                                style: TextStyle(fontSize: 16, height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: 2.0),
                    IconButton(
                      icon: _isLiked ?? false
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 20,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                              size: 20,
                            ),
                      onPressed: () async {
                        if (token != null) {
                          print("token is ${token}");
                          final updatedComment =
                              await ProfileViewModel.likeComment(
                            token!,
                            widget.commentId,
                            context,
                          );
                          if (updatedComment != null) {
                            setState(() {
                              _isLiked = !_isLiked;
                              widget.likes = updatedComment.numberOfLikes;
                            });
                          }
                        } else {
                          print("Token is not initialized yet");
                        }
                      },
                    ),
                    Text(widget.likes.toString(),
                        style: TextStyle(fontSize: 15.5)),
                    SizedBox(width: 10.0),
                    Flexible(
                      child: Text(
                        widget.timestamp,
                        style: TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
