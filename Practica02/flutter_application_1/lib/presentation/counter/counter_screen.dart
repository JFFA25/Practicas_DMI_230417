import 'package:flutter/material.dart';

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int clickCounter = 0;

  Color _getCounterColor() {
    if (clickCounter > 0) {
      return Colors.green;
    }
    if (clickCounter < 0) {
      return Colors.red;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Counter Screen',
          style: TextStyle(fontFamily: 'tf2', fontSize: 22),
        ),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            clickCounter++;
          });
        },
        child: const Icon(Icons.plus_one),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$clickCounter',
              style: TextStyle(
                fontSize: 160,
                fontWeight: FontWeight.w100,
                fontFamily: 'tf2',
                color: _getCounterColor(),
              ),
            ),
            const Text(
              'Clicks',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'tf2', 
              ),
            ),
          ],
        ),
      ),
    );
  }
}
