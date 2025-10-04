import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

// Asegúrate de que esta ruta a MenuRep sea correcta.
import '../models/menu_rep.dart';
import 'package:dotted_border/dotted_border.dart';
import '../widgets/image_input.dart';
import '../config/app_config.dart'; // Asegúrate de que esta ruta sea correcta

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

class ReporteDetailsPage extends StatefulWidget {
  final MenuRep reporte;

  const ReporteDetailsPage({Key? key, required this.reporte}) : super(key: key);

  @override
  _ReporteDetailsPageState createState() => _ReporteDetailsPageState();
}

class _ReporteDetailsPageState extends State<ReporteDetailsPage> {
  final List<File> _selectedImages = [];
  bool _isLoading = false;
  final TextEditingController _descripcionController = TextEditingController();

  Future<void> _submitReport(String action) async {
    if (_selectedImages.isEmpty) {
      _showSnackBar('Por favor, selecciona al menos una imagen');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      late Uri uri;

      // Endpoint según acción
      if (action == "reenviar") {
        uri = Uri.parse("${AppConfig.baseUrl}/reportes/${widget.reporte.id}");
      } else if (action == "noEncontrado") {
        uri = Uri.parse(
            "${AppConfig.baseUrl}/reportes/no-encontrado/${widget.reporte.id}");
      } else if (action == "solucionado") {
        uri = Uri.parse(
            "${AppConfig.baseUrl}/reportes/solucionado/${widget.reporte.id}");
      } else {
        throw Exception("Acción no soportada");
      }

      final request = http.MultipartRequest("POST", uri);

      // Headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['_method'] = 'PUT';
      request.fields['ronda_ejecutada_id'] = '1';
      request.fields['zona_id'] = '1';
      request.fields['ubicacion_id'] = '';

      if (action == "reenviar") {
        request.fields['descripcion'] = _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : 'Este es un reporte reenviado automáticamente desde la aplicación móvil';
      }

      if (action == "noEncontrado") {
        request.fields['descripcion'] = _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : 'Estatus actualizado: NO ENCONTRADO';
      }

      if (action == "solucionado") {
        request.fields['descripcion'] = _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : 'Estatus actualizado: NO ENCONTRADO';
      }

      // Imágenes (común a todas las acciones)
      for (var image in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagenes[]',
          image.path,
          filename: path.basename(image.path),
        ));
      }

      print("Enviando campos: ${request.fields}");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Acción "$action" realizada con éxito');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Error al enviar reporte: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _descripcionController.text = widget.reporte.descripcion;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

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
        title: Text('Reporte (${widget.reporte.id})'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Campos con datos del Reporte ---
            ReportFormField(
              labelText: 'ID del Reporte:',
              valueText: widget.reporte.id,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Zona:',
              valueText: widget.reporte.ubicacion, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Empresa:',
              valueText: widget.reporte.empresa, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Tipo de Reporte:',
              valueText: widget.reporte.tipo, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Gravedad (Status):',
              valueText: widget.reporte.gravedad, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Catálogo (Evento Principal):',
              valueText: widget.reporte.catalogo, // <- Dato del reporte
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              label: 'Número Económico:',
              value: widget.reporte.unidad, // <- Dato del reporte
            ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                widget.reporte.descripcion.isEmpty
                    ? 'Sin descripción detallada.'
                    : widget.reporte.descripcion, // <- Dato del reporte
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
                const SizedBox(height: 12),
                // Componente para subir imágenes
                ImageInput(
                  images: _selectedImages,
                  onImagesChanged: (images) {
                    setState(() {
                      _selectedImages.clear();
                      _selectedImages.addAll(images);
                    });
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _submitReport("reenviar"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Emitir de nuevo"),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _submitReport("noEncontrado"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("No Encontrado"),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.deepOrangeAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _submitReport("solucionado"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Solucionado"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        )
        ,
      )
      ,
    );
  }
}