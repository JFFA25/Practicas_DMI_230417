import 'package:flutter/material.dart';
import 'package:yes_no_app/presentation/widgets/chat/my_message_dubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_dubble.dart';

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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 100,
                itemBuilder: (context, index) {
                  return(index % 2 == 0)
                      ? const HerMessageDubble()
                      : const MyMessageDubble();
                },
              ), // <-- Aquí cierra el ListView.builder de forma correcta
            ), // <-- Aquí cierra el Expanded

            const Text('Mundo'),
          ],
        ),
      ),
    );
  }
}
