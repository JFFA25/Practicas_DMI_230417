import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';

class VideoButtons extends StatelessWidget {
  final VideoPost video;
  final VoidCallback? onCommentsPressed;
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback onPreviousPressed;
  final VoidCallback onNextPressed;

  const VideoButtons({
    super.key,
    required this.video,
    required this.canGoPrevious,
    required this.canGoNext,
    required this.onPreviousPressed,
    required this.onNextPressed,
    this.onCommentsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NavigationButton(
          icon: Icons.keyboard_arrow_up,
          tooltip: 'Video anterior',
          onPressed: canGoPrevious ? onPreviousPressed : null,
        ),
        const SizedBox(height: 8),
        _CustomIconButton(
          value: video.likes,
          iconColor: Colors.red,
          iconData: Icons.favorite,
        ),
        const SizedBox(height: 20),
        _CustomIconButton(
          value: video.views,
          iconData: Icons.remove_red_eye_outlined,
        ),

        if (video.youtubeVideoId != null) ...[
          const SizedBox(height: 20),
          _CustomIconButton(
            value: video.comments,
            iconData: Icons.mode_comment_outlined,
            onPressed: onCommentsPressed,
          ),
        ],

        const SizedBox(height: 8),
        _NavigationButton(
          icon: Icons.keyboard_arrow_down,
          tooltip: 'Siguiente video',
          onPressed: canGoNext ? onNextPressed : null,
        ),
        const SizedBox(height: 20),
        SpinPerfect(
          infinite: true,
          duration: const Duration(seconds: 5),
          child: const _CustomIconButton(
            value: 0,
            iconData: Icons.play_circle_outline,
          ),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _NavigationButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: onPressed == null ? Colors.white38 : Colors.white,
        size: 36,
      ),
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  final int value;
  final IconData iconData;
  final Color? color;
  final VoidCallback? onPressed;

  const _CustomIconButton({
    required this.value,
    required this.iconData,
    this.onPressed,
    iconColor,
  }) : color = iconColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed ?? () {},
          icon: Icon(iconData, color: color, size: 30),
        ),

        if (value > 0) Text(HumanFormats.humanReadbleNumber(value.toDouble())),
      ],
    );
  }
}
