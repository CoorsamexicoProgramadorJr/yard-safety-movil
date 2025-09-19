import 'package:flutter/material.dart';

class ReporteObjetoRiesgoPage extends StatelessWidget {
  const ReporteObjetoRiesgoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte por Objeto de Riesgo'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Aquí se creará el formulario para reportes de objetos de riesgo. Puedes añadir campos como tipo de objeto, ubicación, descripción del riesgo, etc.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}