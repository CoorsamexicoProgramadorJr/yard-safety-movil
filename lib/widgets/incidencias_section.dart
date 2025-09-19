import 'package:flutter/material.dart';
import 'incidencia_modal.dart';

class IncidenciasSection extends StatelessWidget {
  const IncidenciasSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Incidencias:", style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Mostrar Incidencias", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: () => IncidenciaModal.show(context),
              child: Container(
                width: 35,
                height: 35,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
