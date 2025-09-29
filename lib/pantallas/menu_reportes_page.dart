import 'package:flutter/material.dart';
import '../models/menu_rep.dart';
import '../widgets/reporte_card.dart';
import 'reporte_details_page.dart';
import 'new_report_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MenuReportesPage extends StatefulWidget {
  const MenuReportesPage({super.key});

  @override
  State<MenuReportesPage> createState() => _MenuReportesPageState();
}

class _MenuReportesPageState extends State<MenuReportesPage> {
  List<MenuRep>? reportes;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse("http://yard-safety-web.test/api/v1/reportes"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final lista = (data['data'] as List)
            .map((e) => MenuRep.fromJson(e))
            .toList();

        setState(() {
          reportes = lista;
          cargando = false;
        });
      } else {
        setState(() {
          reportes = [];
          cargando = false;
        });
      }
    } catch (e) {
      print("Error al cargar reportes: $e");
      setState(() {
        reportes = [];
        cargando = false;
      });
    }
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
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : reportes == null || reportes!.isEmpty
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
                            builder: (context) =>
                                ReporteDetailsPage(reporte: reporte),
                          ),
                        );
                      },
                      child: ReporteCard(reporte: reporte),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí debes decidir qué rondaId usar. Por ejemplo 1 como placeholder.
          final int rondaIdSeleccionada = 1;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewReportScreen(
                rondaId: rondaIdSeleccionada,
                onBack: () {
                  Navigator.pop(context);
                  _cargarReportes(); // recarga la lista al regresar
                },
              ),
            ),
          );
        },
        label: const Text('Nuevo Reporte'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 54, 195, 242),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
