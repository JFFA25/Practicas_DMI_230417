import 'package:flutter/material.dart';

class MessageFieldBox extends StatelessWidget {
  const MessageFieldBox({super.key, required this.onValue});

  final void Function(String value) onValue;

  @override
  Widget build(BuildContext context) {
    final outlineInputBorder = UnderlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius : BorderRadius.circular(40),
    );

    final inputDecoration = InputDecoration(
        filled: true,
        enabledBorder: outlineInputBorder,
        focusedBorder: outlineInputBorder,
        labelText: 'Escribe un mensaje...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.send_outlined),
          onPressed: () {
            print('Enviar mensaje');
          }, // aquí falta la acción de enviar
        ),   
      );
      return TextFormField(
        decoration: inputDecoration,
        onFieldSubmitted: (value) {
          print('Enviado el mensaje: $value');
        },
        onChanged: (value) {
          print('Valor cambiado: $value');
        },
      );
  }
}
