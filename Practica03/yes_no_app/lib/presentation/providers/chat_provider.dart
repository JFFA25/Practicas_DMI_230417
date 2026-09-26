import 'package:flutter/material.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  final getYesNoAnswer = GetYesNoAnswer();
  final scrollController = ScrollController();

  List<Message> messagesLists = [
    Message(text: 'Hola Hueto', fromwho: Fromwho.me),
    Message(text: 'Ya sacaste el album, Daños Luz?', fromwho: Fromwho.me),
  ];

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final message = Message(text: trimmedText, fromwho: Fromwho.me);
    messagesLists.add(message);
    notifyListeners();
    moveScrollToBottom();

    if (trimmedText.endsWith('?')) {
      await herReply();
    }
  }

  Future<void> herReply() async {
    final herMessage = await getYesNoAnswer.getAnswer();
    messagesLists.add(herMessage);
    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
