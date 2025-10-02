import 'package:flutter/material.dart';
// Asegúrate de que esta ruta a MenuRep sea correcta.
import '../models/menu_rep.dart'; 
import 'package:yardsafety/pantallas/Evidencias.dart';
import 'package:dotted_border/dotted_border.dart';


// ===============================================
// WIDGETS DE SÓLO LECTURA (READ-ONLY)
// ===============================================

// Widget reutilizable para mostrar valores en estilo de campo de texto normal (NO editable)
class ReportFormField extends StatelessWidget {
  final String labelText;
  final String valueText;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const ReportFormField({
    Key? key,
    required this.labelText,
    required this.valueText,
    this.labelStyle,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Estilo por defecto para la etiqueta
    final defaultLabelStyle = labelStyle ??
        const TextStyle(
          fontSize: 14.0,
          color: Color.fromARGB(255, 170, 171, 171),
        );

    // Estilo por defecto para el valor
    final defaultValueStyle = valueStyle ??
        const TextStyle(
          fontSize: 14.0,
          color: Color.fromARGB(255, 83, 95, 116),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: defaultLabelStyle,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: const Color.fromRGBO(233, 242, 248, 1), // Color de fondo
            border: Border.all(
              color: const Color.fromARGB(255, 120, 165, 202), // Borde
              width: .5,
            ),
          ),
          child: Text(
            // Muestra 'N/A' si el valor está vacío
            valueText.isEmpty ? 'N/A' : valueText, 
            style: defaultValueStyle,
          ),
        ),
      ],
    );
  }
}

// Widget para mostrar valores con borde punteado (NO editable)
class CustomTextField extends StatelessWidget {
  final String label;
  final String value;

  const CustomTextField({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.black54)),
          const SizedBox(height: 8),
          DottedBorder(
            // **¡CORRECCIÓN! Se elimina el parámetro 'dashPattern' que causa el error.**
            // Ahora solo se pasa el widget hijo.
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: Colors.white, // Fondo del área de valor
              child: Text(
                value.isEmpty ? 'N/A' : value,
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color.fromARGB(255, 83, 95, 116),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class ReporteDetailsPage extends StatelessWidget {
  final MenuRep reporte;

  const ReporteDetailsPage({Key? key, required this.reporte})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Reporte (${reporte.id})'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Campos con datos del Reporte ---

            ReportFormField(
              labelText: 'ID del Reporte:',
              valueText: reporte.id,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Zona:',
              valueText: reporte.ubicacion, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
           
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Empresa:',
              valueText: reporte.empresa, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Tipo de Reporte:',
              valueText: reporte.tipo, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Gravedad (Status):',
              valueText: reporte.gravedad, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Catálogo (Evento Principal):',
              valueText: reporte.catalogo, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            
            // Usamos el campo 'unidad' que contiene el número económico
            CustomTextField(
              label: 'Número Económico:',
              value: reporte.unidad, // <- Dato del reporte
            ),
            
            // Las placas no están en MenuRep, usamos un valor placeholder
            const CustomTextField(
              label: 'Placas de Unidad:',
              value: 'No especificado en reporte',
            ),

            const SizedBox(height: 20.0),
            const Text(
              'Descripción del Reporte:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            // Muestra la descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                reporte.descripcion.isEmpty ? 'Sin descripción detallada.' : reporte.descripcion, // <- Dato del reporte
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Color.fromARGB(255, 83, 95, 116),
                ),
              ),
            ),
            
            const SizedBox(height: 30.0),

            // --- Botones de Acción ---
            
            const Text(
              'Acciones:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15.0),

            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                     // Lógica para ir a la pantalla de Evidencias
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => EvidenciasScreen(reporteId: reporte.id)),
                    // );
                  },
                  child: const Text(
                    "Ver Evidencias",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.green, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Emitir de nuevo",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Cerrar Reporte",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}