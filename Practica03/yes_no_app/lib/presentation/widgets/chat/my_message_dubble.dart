import 'package:flutter/material.dart';

class MyMessageDubble extends StatelessWidget {
  const MyMessageDubble({super.key});

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

   return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children:[
      Container(
        decoration:BoxDecoration( 
          color: colors.primary,
          borderRadius: BorderRadius.circular(20)
        ),
       child: Padding(
         padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
         child: Text('Hola Hueto , Soy Tu Fan',style:TextStyle(color:Colors.white)),
       )
      ),
      const SizedBox(height: 10,),
    ],
   );
  }
}