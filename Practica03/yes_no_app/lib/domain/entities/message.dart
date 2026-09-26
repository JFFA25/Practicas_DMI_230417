enum Fromwho { me, hers }

class Message {
  final String text;
  final String? imageUrl;
  final Fromwho fromwho;
  final DateTime sentAt;

  Message({
    required this.text,
    this.imageUrl,
    required this.fromwho,
    DateTime? sentAt,
  }) : sentAt = sentAt ?? DateTime.now();
}
