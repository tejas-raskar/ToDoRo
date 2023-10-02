import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  final Color backgroundColor;
  final Color color;
  const Button(
      {super.key,
      required this.text,
      required this.onClicked,
      this.backgroundColor = Colors.black,
      this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
      onPressed: onClicked,
      child: Text(text, style:  TextStyle(fontSize: 20, color: color)),
    );
  }
}
