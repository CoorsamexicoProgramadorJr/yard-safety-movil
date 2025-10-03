import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yardsafety/config/app_config.dart';
import 'package:yardsafety/models/rondas.dart';
import 'package:intl/intl.dart';
import 'package:yardsafety/pantallas/new_report_screen.dart';

void showRondaModal(BuildContext context, Ronda ronda) {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm', 'es');
  final String formattedTime = formatter.format(now);

  Future<void> _iniciarRonda(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Token de autenticación no encontrado.')),
      );
      return;
    }

    final url = '${AppConfig.baseUrl}/rondas/${ronda.id}';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 2, // 2 = En proceso
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Ronda actualizada a estado "En Proceso"');
        Navigator.of(context).pop(); // Cierra el modal

        // Navegar al NewReportScreen pasando el rondaId correcto
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewReportScreen(
              rondaId: ronda.id, // ✅ Aquí pasamos el id correcto
            ),
          ),
        );
      } else {
        print('Error al actualizar la ronda');
        print('Status code: ${response.statusCode}');
        print('Body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la ronda: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Iniciar ${ronda.nombre}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('Inicio:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  formattedTime,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Text('Finalización:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  ronda.horaFin ?? 'N/A',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _iniciarRonda(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Comenzar'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
