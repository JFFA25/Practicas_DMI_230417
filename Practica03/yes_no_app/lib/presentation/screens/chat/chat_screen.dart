import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_dubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_dubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/shared/message_field_box.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://images.genius.com/63660b8598fe1b71a40aa24b6cd58592.1000x1000x1.jpg',
            ),
          ),
        ),
        title: const Text('Luis Humberto Navejas'),
      ),
      body: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: chatProvider.scrollController,
                itemCount: chatProvider.messagesLists.length,
                itemBuilder: (context, index) {
                  final message = chatProvider.messagesLists[index];
                  return (message.fromwho == Fromwho.hers)
                      ? HerMessageDubble()
                      : MyMessageDubble(message: message);
                },
              ),
            ),
            //Caja de texto
            MessageFieldBox(onValue: chatProvider.sendMessage),
          ],
        ),
      ),
    );
  }
}
