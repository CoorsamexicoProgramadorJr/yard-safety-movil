import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
// Asegúrate de que estas rutas sean correctas
import 'package:yardsafety/widgets/custom_text_field.dart'; 
import 'package:yardsafety/widgets/custom_dropdown.dart';
import 'package:yardsafety/widgets/image_input.dart';

import '../config/app_config.dart';

class NewReportScreen extends StatefulWidget {
  final int rondaId; // ID de la ronda seleccionada
  final VoidCallback? onBack;

  NewReportScreen({required this.rondaId, this.onBack});

  @override
  _NewReportScreenState createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  bool _isLoading = true;
  
  // Lista de IDs para las Condiciones Inseguras (Checkbox)
  List<int> _selectedCondicionesInseguras = []; 
  
  // Mapeo de datos de la API
  Map<String, List<dynamic>> _apiData = {};
  
  // Valores seleccionados. 'peligro' guarda el nombre (String) para el CustomDropdown, el resto el ID (int).
  Map<String, dynamic> _selectedValues = {
    'peligro': null, 
    'categoriaReporte': null,
    'zona': null,
    'tipoUnidad': null,
    'empresa': null,
  };

  // Lista de condiciones inseguras cargadas para el peligro seleccionado
  List<dynamic> _condicionesInseguras = [];

  final Map<String, TextEditingController> _controllers = {
    'ubicacion': TextEditingController(),
    'numeroEconomico': TextEditingController(),
    'placa': TextEditingController(),
    'descripcion': TextEditingController(),
  };
  
  // Lista para almacenar las imágenes seleccionadas
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  // Busca el ID del item seleccionado a partir de su nombre (usado para CustomDropdown)
  int? _getIdByName(String key, String? name) {
    if (name == null) return null;
    return _apiData[key]?.firstWhere(
      (item) => item['nombre'] == name,
      orElse: () => null,
    )?['id'] as int?;
  }

  // Carga todos los datos necesarios desde las APIs.
  Future<void> _loadFormData() async {
    await Future.wait([
      _fetchApiData('catalogoPeligros', 'select/catalogo-peligros'),
      _fetchApiData('categoriaReporte', 'select/tipo-reporte'),
      _fetchApiData('zona', 'select/zona'),
      _fetchApiData('tipoUnidad', 'select/tipo-unidad'),
      _fetchApiData('empresa', 'select/empresa'),
    ]);
    setState(() => _isLoading = false);
  }

  // Función genérica para obtener datos de una API protegida.
  Future<void> _fetchApiData(String key, String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: {
        "Content-Type": "application/json",
         "Authorization": "Bearer $token",
         },
    );

    if (response.statusCode == 200) {
      _apiData[key] = json.decode(response.body)['data'];
    } else {
      print('Error al cargar $key: ${response.body}');
    }
  }
  
  // Obtener Condiciones Inseguras por ID de Peligro
  Future<void> _fetchCondicionesInseguras(int peligroId) async {
    setState(() {
      // Limpiamos las condiciones anteriores y los valores seleccionados
      _condicionesInseguras = [];
      _selectedCondicionesInseguras = [];
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final endpoint = 'select/condicion-insegura/$peligroId';
    
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/$endpoint'),
      headers: {
        "Content-Type": "application/json", 
        "Authorization": "Bearer $token",
        },
    );

    if (response.statusCode == 200) {
      setState(() {
        _condicionesInseguras = json.decode(response.body)['data'];
      });
    } else {
      print('Error al cargar condiciones inseguras: ${response.body}');
      _showSnackbar('Error al cargar las condiciones inseguras');
    }
  }

  // Envía el reporte a la API.
  Future<void> _crearReporte() async {
    final peligroId = _getIdByName('catalogoPeligros', _selectedValues['peligro'] as String?);

    if (peligroId == null) {
      _showSnackbar('Selecciona un peligro');
      return;
    }

    if (_selectedImages.isEmpty) {
      _showSnackbar('Por favor, agrega al menos una imagen');
      return;
    }

    // Validación de condiciones inseguras si existen
    if (_selectedCondicionesInseguras.isEmpty && _condicionesInseguras.isNotEmpty) {
      _showSnackbar('Selecciona al menos una condición insegura');
      return;
    }

    // Mapeo del body. Nota: 'catalogo_evento_id' debe ser una lista, por eso usamos [peligroId]
    final body = {
      "ronda_ejecutada_id": widget.rondaId,
      "categoria_reporte_id": _selectedValues['categoriaReporte'],
      "catalogo_evento_id": [peligroId],
      "zona_id": _selectedValues['zona'],
      // Condición insegura se envía como una lista de IDs
      "condicion_insegura_id": _selectedCondicionesInseguras,
      "ubicacion_id": _controllers['ubicacion']!.text.isEmpty ? null : int.tryParse(_controllers['ubicacion']!.text),
      "numero_economico": _controllers['numeroEconomico']!.text.isEmpty ? null : _controllers['numeroEconomico']!.text,
      "placa": _controllers['placa']!.text.isEmpty ? null : _controllers['placa']!.text,
      "tipo_unidad_id": _selectedValues['tipoUnidad'],
      "empresa_id": _selectedValues['empresa'],
      "descripcion": _controllers['descripcion']!.text,
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    
    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}/reportes"),
      headers: {
        "Content-Type": "application/json",
        "Acept": "application/json",
        "Authorization": "Bearer $token",
       },
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSnackbar('Reporte creado correctamente!');
      if (widget.onBack != null) widget.onBack!();
    } else {
      String errorMessage = 'Error al crear el reporte';
      try {
        final errorJson = json.decode(response.body);
        errorMessage += ': ${errorJson['message'] ?? response.statusCode}';
      } catch (e) {
        // No se pudo decodificar el cuerpo
      }
      _showSnackbar(errorMessage);
      print(response.body);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo Reporte - Ronda ${widget.rondaId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  // 1. Dropdown para Peligros
                  _buildDropdownCatalog('Peligro', 'catalogoPeligros'),

                  // 2. Checkbox List para Condiciones Inseguras (si hay un peligro seleccionado)
                  if (_selectedValues['peligro'] != null)
                    _buildCondicionInseguraCheckboxList(),

                  // 3. Demás Dropdowns usando CustomDropdown
                  _buildDropdownCatalog('Categoría de Reporte', 'categoriaReporte'),
                  _buildDropdownCatalog('Zona', 'zona'),
                  
                  // Text Fields
                  _buildTextField('ID de Ubicación (opcional)', 'ubicacion'),
                  _buildTextField('Número Económico (opcional)', 'numeroEconomico'),
                  _buildTextField('Placa (opcional)', 'placa'),
                  
                  // Más Dropdowns
                  _buildDropdownCatalog('Tipo de Unidad ID (opcional)', 'tipoUnidad'),
                  _buildDropdownCatalog('Empresa ID (opcional)', 'empresa'),
                  
                  _buildTextField('Descripción', 'descripcion', isDashed: true),
                  const SizedBox(height: 16),
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
                  Center(
                    child: ElevatedButton(
                      onPressed: _crearReporte,
                      child: const Text('Crear Reporte'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Widget para todos los catálogos (Peligro, Zona, Empresa, etc.) usando CustomDropdown
  Widget _buildDropdownCatalog(String label, String key) {
    final List<dynamic>? items = _apiData[key];
    final List<String> itemNames = items?.map((item) => item['nombre'] as String).toList() ?? [];
    
    // 1. Intentar obtener el ID (si está guardado como ID)
    final int? currentId = _selectedValues[key] is int ? _selectedValues[key] as int? : null;
    
    String? currentValueName;

    if (currentId != null) {
      // Si tenemos un ID, buscamos el nombre
      final selectedItem = items?.firstWhere((item) => item['id'] == currentId, orElse: () => null);
      currentValueName = selectedItem?['nombre'] as String?;
    } else if (_selectedValues[key] is String) {
      // Si no tenemos ID, pero tenemos un nombre (solo pasa con 'peligro'), usamos ese nombre
      currentValueName = _selectedValues[key] as String?;
    }

    if (items == null || items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text('Cargando $label...', style: const TextStyle(color: Colors.grey)),
      );
    }

    return CustomDropdown(
      label: Text(label),
      hint: 'Selecciona un/a $label',
      value: currentValueName,
      items: itemNames,
      onChanged: (String? newValueName) {
        setState(() {
          // Si es el catálogo de Peligros, guardamos el nombre.
          if (key == 'catalogoPeligros') {
            _selectedValues['peligro'] = newValueName; 
            final int? peligroId = _getIdByName(key, newValueName);
            
            if (peligroId != null) {
              _fetchCondicionesInseguras(peligroId); // Cargar condiciones
            } else {
              _condicionesInseguras = [];
              _selectedCondicionesInseguras = [];
            }
          } else {
            // Para el resto de catálogos, guardamos el ID
            _selectedValues[key] = _getIdByName(key, newValueName);
          }
        });
      },
    );
  }

  // Widget para la lista de Checkboxes de Condiciones Inseguras
  Widget _buildCondicionInseguraCheckboxList() {
    if (_condicionesInseguras.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 15.0),
        child: Text(
          'No hay condiciones inseguras asociadas a este peligro.',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 8.0),
          child: Text('Selecciona las condiciones inseguras:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ..._condicionesInseguras.map((c) {
          final id = c['id'] as int;
          final isSelected = _selectedCondicionesInseguras.contains(id);
          return CheckboxListTile(
            title: Text(c['nombre']),
            value: isSelected,
            onChanged: (bool? value) => setState(() {
              if (value == true) {
                _selectedCondicionesInseguras.add(id);
              } else {
                _selectedCondicionesInseguras.remove(id);
              }
            }),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTextField(String label, String key, {bool isDashed = false}) {
    return CustomTextField(
      label: Text(label),
      hint: label,
      isDashed: isDashed,
      controller: _controllers[key]!,
    );
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}