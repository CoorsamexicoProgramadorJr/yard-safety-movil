import 'package:flutter/material.dart';
import 'package:yardsafety/models/rondas.dart';
import 'package:yardsafety/widgets/ronda_modal.dart';
import 'package:yardsafety/pantallas/menu_reportes_page.dart'; 

class RondaCard extends StatelessWidget {
  final Ronda ronda;
  // Mantenemos onTap como obligatorio por si lo necesitas, aunque la lógica de navegación
  // está dentro del widget. 
  final VoidCallback onTap; 
  // NUEVO: Callback opcional para la acción de finalizar
  final VoidCallback? onFinish; 

  const RondaCard({
    super.key, 
    required this.ronda, 
    required this.onTap, 
    this.onFinish, // Nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {

    // Lógica para determinar el ícono de la tarjeta
    // Usamos 'statusRondaId == 2' para indicar que está en ejecución (color azul)
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
      elevation: 4, // Añadido un poco de sombra para destacar
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              // Lógica interna para la navegación
              if (ronda.statusRondaId == 2 ) {
                // Si la ronda ya está en proceso, navega directamente a la pantalla de reportes.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuReportesPage(rondaId: ronda.rondaEjecutadaId)),
                );
              } else {
                // Si no está en proceso, muestra el modal para iniciarla.
                showRondaModal(context, ronda);
              }
              // También ejecutamos el onTap recibido, si es necesario, aunque en este caso ya lo manejamos arriba.
              // onTap();
            },
            leading: Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: leadingIcon,
            ),
            title: Text(
              ronda.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitleText,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: onFinish != null
                ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue)
                : const Icon(Icons.lock_clock, size: 16, color: Colors.grey),
          ),
          
          // ===================================
          // BOTÓN DE FINALIZAR RONDA (CONDICIONAL)
          // ===================================
          if (onFinish != null) 
            Container(
              padding: const EdgeInsets.only(left: 20.0, right: 15.0, bottom: 15.0),
              child: ElevatedButton.icon(
                onPressed: onFinish, // Llama a _finalizarRonda de ReportesPage
                icon: const Icon(Icons.done_all, size: 20),
                label: const Text('FINALIZAR '),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700, 
                  foregroundColor: Colors.white,
             
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}