import 'package:flutter/material.dart';
import 'package:toktik/infrastructure/services/youtube_data_api.dart';

class VideoCommentsSheet extends StatefulWidget {
  final Future<List<YoutubeComment>> Function() loadComments;

  const VideoCommentsSheet({super.key, required this.loadComments});

  @override
  State<VideoCommentsSheet> createState() => _VideoCommentsSheetState();
}

class _VideoCommentsSheetState extends State<VideoCommentsSheet> {
  late Future<List<YoutubeComment>> _comments;

  @override
  void initState() {
    super.initState();
    _comments = widget.loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: FutureBuilder<List<YoutubeComment>>(
          future: _comments,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No se pudieron cargar los comentarios: '
                      '${snapshot.error}'),
                ),
              );
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final comments = snapshot.data ?? const <YoutubeComment>[];
            if (comments.isEmpty) {
              return const Center(child: Text('Este video no tiene comentarios.'));
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                const ListTile(
                  title: Text(
                    'Comentarios',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                for (final comment in comments)
                  ListTile(
                    title: Text(comment.author),
                    subtitle: Text(comment.text),
                    trailing: comment.likes > 0
                        ? Text('${comment.likes} ♥')
                        : null,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
