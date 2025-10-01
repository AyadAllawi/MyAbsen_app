import 'package:flutter/material.dart';

class SuccessCard extends StatelessWidget {
  final String message;

  const SuccessCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 32),
        title: Text(
          message,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
