import 'package:flutter/material.dart';

class AddReportButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddReportButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 150.0),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1000.0),
          side: const BorderSide(
            color: Color.fromARGB(255, 0, 149, 255),
            width: 1.0,
          ),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
