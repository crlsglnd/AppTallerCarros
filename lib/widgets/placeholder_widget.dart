import 'package:flutter/material.dart';

class PlaceholderWidget extends StatelessWidget {
  final String text;
  const PlaceholderWidget({super.key, this.text = 'Placeholder'});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: const TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
}
