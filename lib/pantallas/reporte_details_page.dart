import 'package:flutter/material.dart';
import '../models/menu_rep.dart';
import 'package:yardsafety/pantallas/Evidencias.dart';
import 'package:dotted_border/dotted_border.dart';

// Widget reutilizable para los campos de texto normales
class ReportFormField extends StatelessWidget {
  final String labelText;
  final String initialValue;
  final bool isNumeric;
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  const ReportFormField({
    Key? key,
    required this.labelText,
    required this.initialValue,
    this.isNumeric = false,
    this.labelStyle,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: labelStyle ??
                const TextStyle(
                  fontSize: 14.0,
                  color: Color.fromARGB(255, 170, 171, 171),
                ),
          ),
        ),
        TextFormField(
          initialValue: initialValue,
          style: textStyle ??
              const TextStyle(
                fontSize: 14.0,
                color: Color.fromARGB(255, 83, 95, 116),
              ),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 120, 165, 202),
                width: .5,
              ),
            ),
            filled: true,
            fillColor: const Color.fromRGBO(233, 242, 248, 1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
        ),
      ],
    );
  }
}

// Nuevo widget con borde punteado compatible
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: TextFormField(
                initialValue: hint,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Página de detalles del reporte
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
            ReportFormField(
              labelText: 'Zona:',
              initialValue: reporte.ubicacion,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Estacionamiento:',
              initialValue: '25',
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Empresa:',
              initialValue: reporte.empresa,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Tipo de Unidad:',
              initialValue: reporte.unidad,
            ),
            const SizedBox(height: 20.0),

            // Campos con CustomTextField
            const CustomTextField(
              label: 'Número Económico:',
              hint: '12345',
            ),
            const CustomTextField(
              label: 'Placas de Unidad:',
              hint: 'XXX-XXX-XX',
            ),

            const SizedBox(height: 20.0),
            const Text(
              'Evidencias:',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
           
            const SizedBox(height: 30.0),

            // Botones alargados con borde y letras de color
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
                  onPressed: () {},
                  child: const Text(
                    "Emitir de nuevo",
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
                    "Acción 2",
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
                    "Acción 3",
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
