import 'package:flutter/material.dart';
import 'package:toktik/domain/entitis/video_post.dart';

class VideoButtons extends StatelessWidget {

  final VideoPost video;

  const VideoButtons({
    super.key,
    required this.video
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.favorite, color: Colors.red)),
      ],
    );
  }
}
