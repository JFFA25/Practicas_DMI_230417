import 'package:flutter/material.dart';

class ExpandableCaption extends StatefulWidget {
  final String title;
  final String description;

  const ExpandableCaption({
    super.key,
    required this.title,
    this.description = '',
  });

  @override
  State<ExpandableCaption> createState() => _ExpandableCaptionState();
}

class _ExpandableCaptionState extends State<ExpandableCaption> {
  static const _collapsedDescriptionLines = 2;
  static const _maxExpandedHeightFactor = 0.4;
  bool _expanded = false;

  @override
  void didUpdateWidget(covariant ExpandableCaption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.description != widget.description) {
      _expanded = false;
    }
  }

  bool _descriptionOverflows(
    String description,
    TextStyle style,
    double width,
  ) {
    if (description.length > 180) return true;
    final painter = TextPainter(
      text: TextSpan(text: description, style: style),
      textDirection: Directionality.of(context),
      maxLines: _collapsedDescriptionLines,
    )..layout(maxWidth: width);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.titleLarge?.copyWith(
      color: Colors.white,
      shadows: const [Shadow(blurRadius: 8, color: Colors.black)],
    );
    final bodyStyle = textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
    );
    final hintStyle = textTheme.bodySmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final description = widget.description.trim();
    final hasDescription = description.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : size.width * 0.6;
        final canExpand =
            description.length > 180 ||
            (hasDescription &&
                _descriptionOverflows(description, bodyStyle!, width));

        return SizedBox(
          width: size.width * 0.6,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.bottomLeft,
            child: _expanded && canExpand
                ? Container(
                    constraints: BoxConstraints(
                      maxHeight: size.height * _maxExpandedHeightFactor,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: titleStyle),
                        if (hasDescription) ...[
                          const SizedBox(height: 8),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Text(description, style: bodyStyle),
                            ),
                          ),
                        ],
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => setState(() => _expanded = false),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 32),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('Ver menos', style: hintStyle),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titleStyle,
                      ),
                      if (hasDescription) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          maxLines: _collapsedDescriptionLines,
                          overflow: TextOverflow.ellipsis,
                          style: bodyStyle,
                        ),
                      ],
                      if (canExpand)
                        TextButton(
                          onPressed: () => setState(() => _expanded = true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('... más', style: hintStyle),
                        ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
