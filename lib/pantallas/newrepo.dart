import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yardsafety/services/api__service.dart';
import 'package:yardsafety/widgets/custom_dropdown.dart';
import 'package:yardsafety/widgets/custom_text_field.dart';

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  String? _selectedZona;
  String? _selectedEstacionamiento;
  String? _selectedEmpresa;
  String? _selectedcatalogo;
  String _tipoReporte = "incidencia"; // Valor inicial
  String? _selectedTipoUnidad;
  String _gravedad = "Baja";

  final TextEditingController _numeroEconomicoController = TextEditingController();
  final TextEditingController _placasUnidadController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  final List<String> zonas = ['Zona A', 'Zona B', 'Zona C'];
  final List<String> estacionamientos = ['Estac. 1', 'Estac. 2', 'Estac. 3'];
  final List<String> empresas = ['Empresa X', 'Empresa Y', 'Empresa Z'];
  final List<String> tiposUnidad = ['Camión', 'Automóvil', 'Motocicleta'];
  final List<String> tipoReporteOptions = ['incidencia', 'Peligro'];
  final List<String> gravedadOptions = ['Baja', 'Media', 'Alta'];
  final List<String> catalogo = ['obstaculo', 'siniestro', 'falla arquitectura'];

  List<File> _imagenesSeleccionadas = [];
    
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _numeroEconomicoController.dispose();
    _placasUnidadController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardarReporte() async {
    Map<String, dynamic> reporte = {
      "zona": _selectedZona,
      "estacionamiento": _selectedEstacionamiento,
      "empresa": _selectedEmpresa,
      "descripcion": _descripcionController.text,
      "gravedad": _gravedad,
    };

    await ApiService.subirReporte(reporte, _imagenesSeleccionadas);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reporte enviado correctamente ✅")),
    );

    setState(() {
      _selectedZona = null;
      _selectedEstacionamiento = null;
      _selectedEmpresa = null;
      _selectedTipoUnidad = null;
      _descripcionController.clear();
      _numeroEconomicoController.clear();
      _placasUnidadController.clear();
      _imagenesSeleccionadas.clear();
      _tipoReporte = "incidencia"; // Resetear el tipo de reporte
    });
  }

  void _tomarFoto() async {
    final XFile? foto = await _picker.pickImage(source: ImageSource.camera);
    if (foto != null) {
      setState(() {
        _imagenesSeleccionadas.add(File(foto.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle labelStyle = TextStyle(
      color: Color.fromARGB(255, 14, 42, 65),
      fontSize: 13.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: widget.onBack),
        title: const Text("Nuevo Reporte de Incidencias"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Nuevo CustomDropdown para seleccionar el tipo de reporte
            CustomDropdown(
              label: const Text("Tipo de Reporte", style: labelStyle),
              value: _tipoReporte,
              hint: "Seleccione un tipo de reporte",
              items: tipoReporteOptions,
              onChanged: (v) => setState(() => _tipoReporte = v!),
            ),

            CustomDropdown(
              label: const Text("Zona", style: labelStyle),
              value: _selectedZona,
              hint: "Seleccione una zona",
              items: zonas,
              onChanged: (v) => setState(() => _selectedZona = v),
            ),
            
            CustomDropdown(
              label: const Text("Estacionamiento", style: labelStyle),
              value: _selectedEstacionamiento,
              hint: "Buscar un estacionamiento",
              items: estacionamientos,
              onChanged: (v) => setState(() => _selectedEstacionamiento = v),
            ),
            
            CustomDropdown(
              label: const Text("Empresa", style: labelStyle),
              value: _selectedEmpresa,
              hint: "Seleccione una empresa",
              items: empresas,
              onChanged: (v) => setState(() => _selectedEmpresa = v),
            ),

             if (_tipoReporte == "Peligro")
             CustomDropdown(
              label: const Text("Catalogo de peligros ", style: labelStyle),
              value: _selectedcatalogo,
              hint: "Slecciona el peligro a reportar ",
              items: catalogo,
              onChanged: (v) => setState(() => _selectedcatalogo = v),
            ),
          
            if (_tipoReporte == "incidencia")
              CustomDropdown(
                label: const Text("Tipo de Unidad", style: labelStyle),
                value: _selectedTipoUnidad,
                hint: "Seleccione un tipo de unidad",
                items: tiposUnidad,
                onChanged: (v) => setState(() => _selectedTipoUnidad = v),
              ),

            if (_tipoReporte == "incidencia")
              CustomTextField(
                label: const Text("Número Económico", style: labelStyle),
                hint: "Ingrese Número Económico",
                controller: _numeroEconomicoController,
              ),

            if (_tipoReporte == "incidencia")
              CustomTextField(
                label: const Text("Placas de Unidad", style: labelStyle),
                hint: "Ingrese Placas",
                controller: _placasUnidadController,
              ),

            CustomTextField(
              label: const Text("Descripción", style: labelStyle),
              hint: "Describe el problema",
              controller: _descripcionController,
            ),

            CustomDropdown(
              label: const Text("Peligro", style: labelStyle),
              value: _gravedad,
              hint: "Seleccione gravedad",
              items: gravedadOptions,
              onChanged: (v) => setState(() => _gravedad = v ?? "Baja"),
            ),
            
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _tomarFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar Foto"),
            ),

            const SizedBox(height: 10),

            if (_imagenesSeleccionadas.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Fotos adjuntas:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _imagenesSeleccionadas.map((file) {
                      return Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
                ],
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
         padding: const EdgeInsets.all(20),
         child: ElevatedButton(
            onPressed: _guardarReporte,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 14, 42, 65),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text("Guardar"),
         ),
      ),
    );
  }
}