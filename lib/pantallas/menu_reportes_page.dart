import 'package:flutter/material.dart';
import 'package:yardsafety/pantallas/login.dart';
import '../config/app_config.dart';
import '../models/menu_rep.dart';
import '../widgets/reporte_card.dart';
import 'reporte_details_page.dart';
import 'new_report_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MenuReportesPage extends StatefulWidget {
  final int rondaId;

  const MenuReportesPage({super.key, required this.rondaId});

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

  Future<void> _cargarReportes({bool showLoading = true}) async {
    // Si la lista ya tiene datos, solo actualiza en segundo plano sin mostrar el spinner.
    if (showLoading || reportes == null || reportes!.isEmpty) {
        setState(() => cargando = true);
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/reportes"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          'Accept': 'application/json'
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
        // En caso de error, limpia la lista y detén la carga
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
 
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Eliminar el token de autenticación
    await prefs.remove('token'); 
    // 2. Navegar a la pantalla de Login y eliminar todas las rutas anteriores
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, 
      );
    }
  }

  // ==========================================================
  // Implementación del Pull-to-Refresh (como en la otra pantalla)
  // ==========================================================
  Future<void> _handleRefresh() async {
    await _cargarReportes(showLoading: false);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : reportes == null || reportes!.isEmpty
              ? const Center(child: Text('No hay reportes disponibles.'))
              : RefreshIndicator( // 💡 Agregamos RefreshIndicator
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 20),
                      itemCount: reportes!.length,
                      itemBuilder: (context, index) {
                        final reporte = reportes![index];
                        return InkWell(
                          onTap: () async { // 💡 Usamos async/await aquí
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReporteDetailsPage(reporte: reporte),
                              ),
                            );
                            // Si la página de detalles regresa con `true`, significa que hubo un cambio
                            if (result == true) { 
                              _cargarReportes(); // Recargamos la lista
                            }
                          },
                          child: ReporteCard(reporte: reporte),
                        );
                      },
                    ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async { // 💡 Usamos async/await aquí
          // Aquí debes decidir qué rondaId usar. Por ejemplo 1 como placeholder.
          final int rondaEjecutadaId = 0;

          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewReportScreen(
                rondaId: widget.rondaId,
                // El callback onBack ya no es necesario si usamos await/result
                // onBack: () {
                //   Navigator.pop(context);
                //   _cargarReportes(); 
                // },
              ),
            ),
          );
          
          // Si la pantalla de nuevo reporte regresa con `true`, recarga la lista
          if (result == true) {
            _cargarReportes();
          }
        },
        label: const Text('Nuevo Reporte'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color.fromARGB(255, 54, 195, 242),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}