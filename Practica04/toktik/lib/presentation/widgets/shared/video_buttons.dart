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
        _MetricButton(
          value: video.likes,
          iconData: Icons.favorite,
          label: 'Me gusta',
          iconColor: Colors.redAccent,
        ),
        if (video.youtubeVideoId == null) ...[
          const SizedBox(height: 16),
          _MetricButton(
            value: video.views,
            iconData: Icons.visibility_outlined,
            label: 'Vistas',
          ),
        ],
        if (video.youtubeVideoId != null) ...[
          const SizedBox(height: 16),
          _MetricButton(
            value: video.comments,
            iconData: Icons.mode_comment_outlined,
            label: 'Comentarios',
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

  const _CustomIconButton({
    required this.value,
    required this.iconData,
    iconColor,
  }) : color = iconColor ?? Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(iconData, color: color, size: 30),

        if (value > 0) Text(HumanFormats.humanReadbleNumber(value.toDouble())),
      ],
    );
  }
}

class _MetricButton extends StatelessWidget {
  final int value;
  final IconData iconData;
  final String label;
  final Color iconColor;
  final VoidCallback? onPressed;

  const _MetricButton({
    required this.value,
    required this.iconData,
    required this.label,
    this.iconColor = Colors.white,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Material(
            color: Colors.black.withValues(alpha: 0.38),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(iconData, color: iconColor, size: 25),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            HumanFormats.humanReadbleNumber(value.toDouble()),
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
              shadows: [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}
