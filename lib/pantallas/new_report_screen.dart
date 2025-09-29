import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yardsafety/widgets/custom_text_field.dart';


class NewReportScreen extends StatefulWidget {
  final int rondaId; // ID de la ronda seleccionada
  final VoidCallback? onBack;

  NewReportScreen({required this.rondaId, this.onBack});

  @override
  _NewReportScreenState createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  List<dynamic> catalogoPeligros = [];
  List<int> catalogoEventoSeleccionado = [];

  // Controladores
  TextEditingController categoriaReporteController = TextEditingController();
  TextEditingController zonaController = TextEditingController();
  TextEditingController ubicacionController = TextEditingController();
  TextEditingController numeroEconomicoController = TextEditingController();
  TextEditingController placaController = TextEditingController();
  TextEditingController tipoUnidadController = TextEditingController();
  TextEditingController empresaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCatalogoPeligros();
  }

  Future<void> fetchCatalogoPeligros() async {
    final response = await http.get(Uri.parse(
        'http://yard-safety-web.test/api/v1/select/catalogo-peligros'));
    if (response.statusCode == 200) {
      setState(() {
        catalogoPeligros = json.decode(response.body)['data'];
      });
    } else {
      print('Error al cargar catálogo de peligros');
    }
  }

  Future<void> crearReporte() async {
    if (catalogoEventoSeleccionado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un peligro')),
      );
      return;
    }

    final body = {
      "ronda_ejecutada_id": widget.rondaId,
      "categoria_reporte_id": int.tryParse(categoriaReporteController.text),
      "catalogo_evento_id": catalogoEventoSeleccionado,
      "zona_id": int.tryParse(zonaController.text),
      "ubicacion_id": ubicacionController.text.isEmpty
          ? null
          : int.tryParse(ubicacionController.text),
      "numero_economico": numeroEconomicoController.text.isEmpty
          ? null
          : numeroEconomicoController.text,
      "placa": placaController.text.isEmpty ? null : placaController.text,
      "tipo_unidad_id": tipoUnidadController.text.isEmpty
          ? null
          : int.tryParse(tipoUnidadController.text),
      "empresa_id":
          empresaController.text.isEmpty ? null : int.tryParse(empresaController.text),
      "descripcion": descripcionController.text,
    };

    final response = await http.post(
      Uri.parse('http://yard-safety-web.test/api/v1/reportes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte creado correctamente!')),
      );
      if (widget.onBack != null) widget.onBack!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el reporte')),
      );
      print(response.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Reporte - Ronda ${widget.rondaId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) widget.onBack!();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: catalogoPeligros.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  const Text('Selecciona los peligros:',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  ...catalogoPeligros.map((p) {
                    final id = p['id'];
                    final nombre = p['nombre'];
                    final isSelected = catalogoEventoSeleccionado.contains(id);
                    return CheckboxListTile(
                      title: Text(nombre),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true)
                            catalogoEventoSeleccionado.add(id);
                          else
                            catalogoEventoSeleccionado.remove(id);
                        });
                      },
                    );
                  }).toList(),
                  CustomTextField(
                    label: const Text('ID de Categoría de Reporte'),
                    hint: 'Ingresa la categoría de reporte',
                    isDashed: false,
                    controller: categoriaReporteController,
                  ),
                  CustomTextField(
                    label: const Text('ID de Zona'),
                    hint: 'Ingresa el ID de zona',
                    isDashed: false,
                    controller: zonaController,
                  ),
                  CustomTextField(
                    label: const Text('ID de Ubicación (opcional)'),
                    hint: 'Ingresa el ID de ubicación',
                    isDashed: false,
                    controller: ubicacionController,
                  ),
                  CustomTextField(
                    label: const Text('Número Económico (opcional)'),
                    hint: 'Número económico',
                    isDashed: false,
                    controller: numeroEconomicoController,
                  ),
                  CustomTextField(
                    label: const Text('Placa (opcional)'),
                    hint: 'Placa de la unidad',
                    isDashed: false,
                    controller: placaController,
                  ),
                  CustomTextField(
                    label: const Text('Tipo de Unidad ID (opcional)'),
                    hint: 'Tipo de unidad',
                    isDashed: false,
                    controller: tipoUnidadController,
                  ),
                  CustomTextField(
                    label: const Text('Empresa ID (opcional)'),
                    hint: 'ID de empresa',
                    isDashed: false,
                    controller: empresaController,
                  ),
                  CustomTextField(
                    label: const Text('Descripción'),
                    hint: 'Ingresa la descripción del reporte',
                    isDashed: true,
                    controller: descripcionController,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: crearReporte,
                      child: const Text('Crear Reporte'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
