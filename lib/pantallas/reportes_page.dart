import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yardsafety/config/app_config.dart';
import 'package:yardsafety/models/rondas.dart';
import 'package:yardsafety/pantallas/login.dart';
import '../widgets/ronda_card.dart';
import 'new_report_screen.dart';
import 'package:intl/intl.dart'; // <-- 1. Importar para el formato de fecha

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  _ReportesPageState createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  bool _showNewReportScreen = false;
  List<Ronda> _rondas = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedRondaId;
  String _userName = "Usuario"; 

  @override

  void initState() {
    super.initState();
    _loadUserData();
    _fetchRondas();
  }

  // <-- 3. Nuevo método para cargar el nombre del usuario
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    final String? nombre = prefs.getString('nombreCompleto');

    if (mounted) {
      setState(() {
      
        _userName = nombre ?? 'Usuario';
      });
    }
  }

  Future<void> _fetchRondas() async {
    // ... (Tu código actual de _fetchRondas) ...
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _error = 'Token de autenticación no encontrado. Redirigiendo...';
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/rondas"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final resp = json.decode(response.body);
        final List<dynamic> rondasJson = resp['data'];

        if (mounted) {
          setState(() {
            _rondas = rondasJson.map((json) => Ronda.fromJson(json)).toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error =
                'Error al cargar las rondas. Código de estado: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error de conexión: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _openNewReportScreen(int rondaId) {
    setState(() {
      _selectedRondaId = rondaId;
      _showNewReportScreen = true;
    });
  }

  void _backToRondas() {
    setState(() {
      _showNewReportScreen = false;
      _selectedRondaId = null;
      _fetchRondas();
    });
  }

  @override
  Widget build(BuildContext context) {

    final String formattedDate = DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'es_ES').format(DateTime.now());
    
    Widget mainContent;

    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      mainContent = Center(
        child: Text(_error ?? 'Ocurrió un error desconocido'),
      );
    } else if (_rondas.isEmpty) {
      mainContent = const Center(
        child: Text('No hay rondas disponibles.'),
      );
    } else {
      mainContent = SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5. Usar el nombre del usuario cargado
            Text('Bienvenido, $_userName',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // 6. Usar la fecha formateada
            Text('Hoy es ${formattedDate.capitalize()}', // capitalize() para que inicie con mayúscula
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 32),
            const Text('RONDAS',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              children: _rondas
                  .map(
                    (r) => RondaCard(
                      ronda: r,
                      onTap: () => _openNewReportScreen(r.id),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _showNewReportScreen ? 1 : 0,
        children: [
          mainContent,
          if (_selectedRondaId != null)
            NewReportScreen(
              rondaId: _selectedRondaId!,
              onBack: _backToRondas,
            ),
        ],
      ),
    );
  }
}
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}