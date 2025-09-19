import 'package:flutter/material.dart';
import 'package:yardsafety/pantallas/newrepo.dart';
//import 'package:yardsafety/services/api__service.dart'; // Mantener para uso futuro con la API
//import 'dart:io'; // Necesario para File, aunque los datos dummy no tendrán archivos reales

import '../models/menu_rep.dart';
import '../widgets/reporte_card.dart';
import 'reporte_details_page.dart';

class MenuReportesPage extends StatefulWidget {
  const MenuReportesPage({super.key});

  @override
  State<MenuReportesPage> createState() => _MenuReportesPageState();
}

class _MenuReportesPageState extends State<MenuReportesPage> {
  List<MenuRep>? reportes;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    // Simular un retraso como si fuera una llamada a la API
    await Future.delayed(const Duration(seconds: 1));

    // Datos de ejemplo para demostración, usando la estructura completa de MenuRep
    setState(() {
      reportes = [
        MenuRep(
          id: '1',
          unidad: 'Quinta',
          ubicacion: 'Entrada Principal',
          descripcion: 'Falla en el sistema de seguridad de la quinta.',
          tipo: 'Incidencia',
          gravedad: 'Alta',
          catalogo: 'seguridad',
          imagenes: [], empresa: '', // No hay archivos File reales en los datos dummy
        ),
        MenuRep(
          id: '2',
          unidad: 'NA',
          ubicacion: 'Pasillo C, Sección 2',
          descripcion: 'Cables eléctricos expuestos y sueltos cerca de la zona de mantenimiento. Riesgo de tropiezo y electrocución.',
          tipo: 'Objeto de Riesgo',
          gravedad: 'Crítica',
          catalogo: 'seguridad',
          imagenes: [], empresa: '',
        ),
        MenuRep(
          id: '3',
          unidad: 'Quinta',
          ubicacion: 'Sector 3',
          descripcion: 'pieza rota en la parte superior de la quinta .',
          tipo: 'Incidencia',
          gravedad: 'Media',
          catalogo: 'seguridad',
          imagenes: [], empresa: '',
        ),
        MenuRep(
          id: '4',
        
          unidad: 'NA',
          ubicacion: 'Área de Grúas',
          descripcion: 'Barrera de seguridad dañada alrededor del área de operación de la grúa. Acceso no restringido.',
          tipo: 'Objeto de Riesgo',
          gravedad: 'Alta',
          catalogo: 'seguridad',
          imagenes: [], empresa: '',
        ),
        
         MenuRep(
          id: '5',
       
          unidad: 'Carro ',
          ubicacion: 'Patio 4, estacionamiento 10',
          descripcion: 'Proyector no funciona correctamente, interrupciones durante la presentación.',
          tipo: 'Incidencia',
          gravedad: 'Baja',
          catalogo: 'seguridad',
          imagenes: [], empresa: '',
        ),
      ];
    });

    // esto nos va a ayudar cuando tengamos una api real
    /*
    try {
      final lista = await ApiService.obtenerReportes();
      setState(() {
        reportes = lista;
      });
    } catch (e) {
      print('Error al cargar reportes: $e');
      setState(() {
        reportes = []; // Carga una lista vacía para evitar errores en la UI
      });
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Menú de Reportes';

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reportes == null
          ? const Center(child: CircularProgressIndicator())
          : reportes!.isEmpty
              ? const Center(child: Text('No hay reportes disponibles.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: reportes!.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes![index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReporteDetailsPage(reporte: reporte),
                          ),
                        );
                      },
                      // Asegúrate de que ReporteCard esté diseñado para mostrar los campos relevantes
                      child: ReporteCard(reporte: reporte),
                    );
                  },
                ),
       floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Añade un padding inferior para separarlo del borde
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuye los botones equitativamente
          children: [
            
            // No necesitamos SizedBox(height: 10) aquí porque están en una Row
            // Botón original "Agregar Reporte" (ahora para Incidencia)
            FloatingActionButton.extended(
              heroTag: "addReporteIncidencia", // Etiqueta única
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewReportScreen(
                      onBack: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              label: const Text(''),
              icon: const Icon(Icons.add),
             backgroundColor: const Color.fromARGB(255, 54, 195, 242), // Un color diferente para distinguirlo
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // Cambiado a centerFloat
    );
  }
}