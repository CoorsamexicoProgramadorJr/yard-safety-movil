import 'package:flutter/material.dart';
import 'package:yardsafety/models/rondas.dart';

import 'ronda_modal.dart';

class RondaCard extends StatelessWidget {
  final Ronda ronda;

  const RondaCard({super.key, required this.ronda});

  @override
  Widget build(BuildContext context) {
    final icon = ronda.disponible
        ? IconButton(
            icon: const Icon(Icons.play_circle_outline, color: Colors.blue),
            onPressed: () => showRondaModal(
              context,
              titulo: ronda.titulo,
              inicio: ronda.inicio,
              fin: ronda.fin,
            ),
          )
        : const Icon(Icons.access_time, color: Colors.grey);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(color: Color.fromARGB(255, 224, 224, 224), width: 1.0),
      ),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: icon,
        title: Text(
          ronda.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Empieza el ${ronda.inicio}',
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
