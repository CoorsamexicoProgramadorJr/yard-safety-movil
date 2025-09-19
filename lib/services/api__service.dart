import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import '../models/menu_rep.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.1.73/yard-safety-backend';

  // --- Método para obtener reportes ---
  static Future<List<MenuRep>> obtenerReportes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/reportes_get.php'));

      if (response.statusCode == 200) {
        // La solicitud fue exitosa, decodifica los datos JSON
        final List<dynamic> jsonList = json.decode(response.body);

        // Mapea la lista JSON a una lista de objetos MenuRep
        return jsonList.map((json) => MenuRep.fromJson(json)).toList();
      } else {
        // Si la solicitud no fue exitosa
        throw Exception('Error al cargar reportes. Código: ${response.statusCode}');
      }
    } catch (e) {
      // Maneja errores de conexión o del servidor
      print('Fallo la conexión con la API: $e');
      return []; // Devuelve una lista vacía para evitar que la app se rompa
    }
  }

  // --- El método para subir reportes que ya tenías ---
  static Future<void> subirReporte(Map<String, dynamic> reporte, List<File> imagenes) async {
    var uri = Uri.parse("$_baseUrl/reportes_create.php");
    var request = http.MultipartRequest('POST', uri);

    // Agregar campos del reporte
    reporte.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    // Agregar imágenes
    for (var img in imagenes) {
      var file = await http.MultipartFile.fromPath(
        'imagenes[]',
        img.path,
        filename: basename(img.path),
      );
      request.files.add(file);
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      print("✅ Reporte subido correctamente");
    } else {
      print("❌ Error al subir reporte: ${response.statusCode}");
    }
  }
}