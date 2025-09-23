import 'package:flutter/material.dart';
import 'package:yardsafety/models/rondas.dart';
import 'package:yardsafety/widgets/ronda_modal.dart';
import 'package:yardsafety/pantallas/menuRep.dart'; // Asegúrate de importar la pantalla a la que quieres navegar

class RondaCard extends StatelessWidget {
  final Ronda ronda;

  const RondaCard({super.key, required this.ronda});

  @override
  Widget build(BuildContext context) {
    // Lógica para determinar el ícono de la tarjeta
    final Widget leadingIcon = (ronda.statusRondaId == 2)
        ? const Icon(Icons.play_circle_outline, color: Colors.blue)
        : const Icon(Icons.access_time, color: Colors.grey);

    // Formatear la fecha y la hora para el subtítulo
    String subtitleText = 'Horario no disponible';
    if (ronda.horaInicio != null && ronda.horaInicio!.isNotEmpty) {
      try {
        final DateTime inicio = DateTime.parse(ronda.horaInicio!.split(' ')[0]);
        final String hora = ronda.horaInicio!.split(' ')[1].substring(0, 5);
        
        // Mapeo de meses de inglés a español
        final Map<int, String> meses = {
          1: 'Enero', 2: 'Febrero', 3: 'Marzo', 4: 'Abril', 5: 'Mayo', 6: 'Junio',
          7: 'Julio', 8: 'Agosto', 9: 'Septiembre', 10: 'Octubre', 11: 'Noviembre', 12: 'Diciembre',
        };
        final String formattedDate = "${inicio.day} de ${meses[inicio.month]}";
        subtitleText = 'Empieza el $formattedDate a las $hora';
      } catch (e) {
        subtitleText = 'Empieza el ${ronda.horaInicio}';
      }
    }

    return Card(
      elevation: 0,
      color: Colors.transparent, 
      margin: const EdgeInsets.only(bottom: 15.0),
      child: ListTile(
        onTap: () {
          if (ronda.statusRondaId == 2 ) {
            // Si la ronda ya está en proceso, navega directamente a la pantalla de reportes.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuReportesPage()),
            );
          } else {
            // Si no está en proceso, muestra el modal para iniciarla.
            showRondaModal(context, ronda);
          }
        },
          leading: Container(
      padding: const EdgeInsets.all(15.0), // espacio interno
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // gris clarito para fondo del icono
        borderRadius: BorderRadius.circular(8.0), // bordes redondeados
      ),
      child: (ronda.statusRondaId == 2)
          ? const Icon(Icons.play_circle_outline, color: Colors.blue)
          : const Icon(Icons.access_time, color: Colors.grey),
    ),
    title: Text(
      ronda.nombre,
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text(
      subtitleText,
      style: const TextStyle(color: Colors.grey),
    ),
  ),
);
  }
}