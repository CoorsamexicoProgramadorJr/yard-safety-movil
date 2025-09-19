import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class CustomTextField extends StatelessWidget {
  final Widget label;
  final String hint;
  final bool isDashed;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isDashed = false, required TextEditingController controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 8),
          isDashed
              ? DottedBorder(
                  options: const RectDottedBorderOptions(dashPattern: [10, 10], strokeWidth: 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: TextField(
                        maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFAAAAAA)),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: hint,
                      border: InputBorder.none,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
