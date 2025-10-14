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

  // 💡 FUNCIÓN DE ORDENAMIENTO POR SEVERIDAD
  void _sortReports(List<MenuRep> list) {
    // Definimos la prioridad: 1 = Alta, 2 = Media, 3 = Baja
    int getSeveridadPriority(String severidad) {
      switch (severidad.toLowerCase()) {
        case 'gravedad alta':
          return 1;
        case 'gravedad media':
          return 2;
        case 'gravedad baja':
          return 3;
        default:
          return 4; // Menor prioridad para desconocidos
      }
    }

    list.sort((a, b) {
      final priorityA = getSeveridadPriority(a.severidad);
      final priorityB = getSeveridadPriority(b.severidad);
      
      // Compara las prioridades: 1 (Alta) debe ir antes que 2 (Media)
      return priorityA.compareTo(priorityB);
    });
  }
  // -------------------------------------------------------------

  Future<void> _cargarReportes({bool showLoading = true}) async {
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

        // 💡 Aplicamos el ORDENAMIENTO después de obtener los datos
        _sortReports(lista); 

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
 
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false, 
      );
    }
  }

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
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 20),
                      itemCount: reportes!.length,
                      itemBuilder: (context, index) {
                        final reporte = reportes![index];
                        return InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ReporteDetailsPage(reporte: reporte),
                              ),
                            );
                            if (result == true) { 
                              _cargarReportes();
                            }
                          },
                          child: ReporteCard(reporte: reporte),
                        );
                      },
                    ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewReportScreen(
                rondaId: widget.rondaId,
              ),
            ),
          );
          
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