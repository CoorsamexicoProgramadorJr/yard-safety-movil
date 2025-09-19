import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final Widget label;
  final String? value;
  final String hint;
  final List<String>? items; // Haz la lista nullable para mayor seguridad
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    required this.items, // Ahora puede ser null
    required this.onChanged,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(233, 242, 248, 1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color.fromARGB(255, 197, 227, 250)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                hint: Text(hint, style: const TextStyle(color: Color.fromARGB(115, 66, 133, 209))),
                items: (items ?? []).map((String item) { 
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: onChanged,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black45),
              ),
            ),
          ),
        ],
      ),
    );
  }
}