import 'package:flutter/material.dart';

class HerMessageDubble extends StatelessWidget {
  const HerMessageDubble({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text('Hola Fan', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 5),
        // Todo: Imagen
        _ImageBubble(),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _ImageBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        "https://yesno.wtf/assets/no/21-05540164de4e3229609f106e468fa8e7.gif",
         width: size.width * 0.7,
         height: 150,
         fit: BoxFit.cover,
      ),
    );
  }
}
