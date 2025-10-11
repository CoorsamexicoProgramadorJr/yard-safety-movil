import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../models/menu_rep.dart';
import 'package:dotted_border/dotted_border.dart';
import '../widgets/image_input.dart';
import '../config/app_config.dart';

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
    final defaultLabelStyle = labelStyle ??
        const TextStyle(
          fontSize: 14.0,
          color: Color.fromARGB(255, 170, 171, 171),
        );

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
            color: const Color.fromRGBO(233, 242, 248, 1),
            border: Border.all(
              color: const Color.fromARGB(255, 120, 165, 202),
              width: .5,
            ),
          ),
          child: Text(
            valueText.isEmpty ? 'N/A' : valueText,
            style: defaultValueStyle,
          ),
        ),
      ],
    );
  }
}

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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: Colors.white,
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

      // Endpoint según la acción
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

      // 👇 Debug: Mostrar URL del endpoint
      print("📡 Enviando reporte a: $uri");

      final request = http.MultipartRequest("POST", uri);

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      request.fields['_method'] = 'PUT';
      
      // 🚨 ZONA Y UBICACIÓN CORREGIDAS: Se usan las IDs del reporte original.
      // Estas propiedades deben existir en tu modelo MenuRep y contener String o int.
      // Usamos .toString() para asegurar que sean Strings para el MultipartRequest.
      request.fields['ronda_ejecutada_id'] = widget.reporte.rondaEjecutadaId.toString(); 
      request.fields['zona_id'] = widget.reporte.zonaId.toString(); 
      request.fields['ubicacion_id'] = widget.reporte.ubicacionId.toString(); 

      // La descripción es el valor actual del controlador (el que el usuario puede editar)
      if (action == "reenviar") {
        request.fields['descripcion'] = _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : 'Este es un reporte reenviado automáticamente desde la app móvil';
      }

      if (action == "noEncontrado") {
        request.fields['descripcion'] = _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : 'Estatus actualizado: NO ENCONTRADO';
      }

      if (action == "solucionado") {
        request.fields['descripcion'] = _descripcionController.text.isNotEmpty
            ? _descripcionController.text
            : 'Estatus actualizado: SOLUCIONADO';
      }

      // 👇 Debug: Mostrar campos enviados
      print("🧾 Campos enviados: ${request.fields}");

      for (var image in _selectedImages) {
        request.files.add(await http.MultipartFile.fromPath(
          'imagenes[]',
          image.path,
          filename: path.basename(image.path),
        ));
      }

      // 👇 Debug: Mostrar cantidad de imágenes
      print("📸 Imágenes adjuntas: ${_selectedImages.length}");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 👇 Debug: Mostrar respuesta del servidor
      print("📥 Respuesta del servidor [${response.statusCode}]: ${response.body}");

      // Se incluye el código de estado 204 como éxito
      if (response.statusCode == 200 || 
          response.statusCode == 201 || 
          response.statusCode == 204) {
        
        _showSnackBar('✅ Acción "$action" realizada con éxito');
        if (mounted) {
          // Devolver 'true' para que la pantalla anterior recargue la lista
          Navigator.pop(context, true); 
        }
      } else {
        throw Exception('Error al enviar reporte: ${response.body}');
      }
    } catch (e) {
      print("❌ Error al enviar reporte: $e");
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
    // Carga la descripción actual del reporte en el controlador
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
            // Los siguientes campos son de solo lectura
            ReportFormField(
              labelText: 'ID del Reporte:',
              valueText: widget.reporte.id,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Zona:',
              valueText: widget.reporte.ubicacion,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Empresa:',
              valueText: widget.reporte.empresa,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Tipo de Reporte:',
              valueText: widget.reporte.tipo,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Gravedad (Status):',
              valueText: widget.reporte.gravedad,
            ),
            const SizedBox(height: 20.0),
            ReportFormField(
              labelText: 'Catálogo (Evento Principal):',
              valueText: widget.reporte.catalogo,
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              label: 'Número Económico:',
              value: widget.reporte.unidad,
            ),
            const CustomTextField(
              label: 'Placas de Unidad:',
              value: 'No especificado en reporte',
            ),
            const SizedBox(height: 20.0),
            
            // 🚨 CAMPO EDITABLE: Descripción del Reporte
            const Text(
              'Descripción del Reporte (editable):',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ingrese una descripción o modifique la existente...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 120, 165, 202),
                    width: .5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 120, 165, 202),
                    width: .5,
                  ),
                ),
                fillColor: const Color.fromRGBO(233, 242, 248, 1),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              style: const TextStyle(
                fontSize: 14.0,
                color: Color.fromARGB(255, 83, 95, 116),
              ),
            ),
            // Fin del campo editable
            
            const SizedBox(height: 30.0),
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
                  onPressed:
                      _isLoading ? null : () => _submitReport("noEncontrado"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("No Encontrado"),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Colors.deepOrangeAccent, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed:
                      _isLoading ? null : () => _submitReport("solucionado"),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Solucionado"),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}