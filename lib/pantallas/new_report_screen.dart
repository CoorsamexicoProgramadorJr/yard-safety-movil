import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yardsafety/pantallas/menu_reportes_page.dart';
import 'dart:io';
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

  List<int> _selectedCondicionesInseguras = [];
  Map<String, List<dynamic>> _apiData = {};
  Map<String, dynamic> _selectedValues = {
    'peligro': null,
    'categoriaReporte': null,
    'zona': null,
    'tipoUnidad': null,
    'empresa': null,
    // 💡 CAMPO DE SEVERIDAD AÑADIDO
    'severidad': null, 
  };

  List<dynamic> _condicionesInseguras = [];
  final Map<String, TextEditingController> _controllers = {
    'numeroEconomico': TextEditingController(),
    'placa': TextEditingController(),
    'descripcion': TextEditingController(),
  };
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  // Helper para obtener el ID de un elemento seleccionado por su nombre
  int? _getIdByName(String key, String? name) {
    if (name == null) return null;
    final id = _apiData[key]?.firstWhere(
      (item) => item['nombre'] == name,
      orElse: () => null,
    )?['id'] as int?;
    
    // 💡 PRINT PARA VERIFICAR ID
    print('Dropdown: $key, Nombre: $name, ID obtenido: $id'); 
    return id;
  }

  Future<void> _loadFormData() async {
    await Future.wait([
      _fetchApiData('catalogoPeligros', 'select/catalogo-peligros'),
      _fetchApiData('categoriaReporte', 'select/tipo-reporte'),
      _fetchApiData('zona', 'select/zona'),
      _fetchApiData('tipoUnidad', 'select/tipo-unidad'),
      _fetchApiData('empresa', 'select/empresa'),
      // 💡 CARGA DE DATOS DE SEVERIDAD
      _fetchApiData('severidad', 'select/severidad'), 
    ]);
    setState(() => _isLoading = false);
  }

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

  Future<void> _fetchCondicionesInseguras(int peligroId) async {
    setState(() {
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

  Future<void> _crearReporte() async {
    final peligroId = _getIdByName('catalogoPeligros', _selectedValues['peligro'] as String?);
    final severidadId = _selectedValues['severidad'] as int?; // El ID de severidad ya está guardado.

    if (peligroId == null) {
      _showSnackbar('Selecciona un peligro');
      return;
    }
    
    // 💡 VALIDACIÓN DE SEVERIDAD
    if (severidadId == null) {
      _showSnackbar('Selecciona la severidad');
      return;
    }

    if (_selectedImages.isEmpty) {
      _showSnackbar('Por favor, agrega al menos una imagen');
      return;
    }

    if (_selectedCondicionesInseguras.isEmpty && _condicionesInseguras.isNotEmpty) {
      _showSnackbar('Selecciona al menos una condición insegura');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final uri = Uri.parse("${AppConfig.baseUrl}/reportes");
    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // CAMPOS DE FORMULARIO
    request.fields['ronda_ejecutada_id'] = widget.rondaId.toString();
    request.fields['categoria_reporte_id'] = _selectedValues['categoriaReporte']?.toString() ?? '';
    request.fields['zona_id'] = _selectedValues['zona']?.toString() ?? '';
    request.fields['tipo_unidad_id'] = _selectedValues['tipoUnidad']?.toString() ?? '';
    request.fields['empresa_id'] = _selectedValues['empresa']?.toString() ?? '';
    request.fields['descripcion'] = _controllers['descripcion']!.text;
    
    // 💡 CAMPO DE SEVERIDAD EN EL REQUEST
    request.fields['severidad_id'] = severidadId.toString(); 

    // EVENTOS Y CONDICIONES
    request.fields['catalogo_evento_id[]'] = peligroId.toString();
    for (var id in _selectedCondicionesInseguras) {
      request.fields['condicion_insegura_id[]'] = id.toString();
    }

    // UNIDAD
    if (_controllers['numeroEconomico']!.text.isNotEmpty) {
      request.fields['numero_economico'] = _controllers['numeroEconomico']!.text;
    }
    if (_controllers['placa']!.text.isNotEmpty) {
      request.fields['placa'] = _controllers['placa']!.text;
    }

    // IMÁGENES
    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      request.files.add(await http.MultipartFile.fromPath(
        'imagenes[]',
        image.path,
      ));
    }

    // 💡 PRINT PARA VERIFICAR LOS DATOS ANTES DE ENVIAR
    print('--- DATOS DEL REPORTE A ENVIAR ---');
    request.fields.forEach((k, v) => print('$k: $v'));
    print('----------------------------------');
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      _showSnackbar('Reporte creado correctamente!');

      if (widget.onBack != null) {
        widget.onBack!();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MenuReportesPage(rondaId: widget.rondaId),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _showSnackbar('Error al crear el reporte: ${response.body}');
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
                  _buildDropdownCatalog('Peligro', 'catalogoPeligros'),
                  if (_selectedValues['peligro'] != null)
                    _buildCondicionInseguraCheckboxList(),
                  // 💡 WIDGET DE SEVERIDAD AGREGADO
                  _buildDropdownCatalog('Severidad', 'severidad'), 
                  _buildDropdownCatalog('Categoría de Reporte', 'categoriaReporte'),
                  _buildDropdownCatalog('Zona', 'zona'),
                  _buildTextField('Número Económico ', 'numeroEconomico'),
                  _buildTextField('Placa ', 'placa'),
                  _buildDropdownCatalog('Tipo de Unidad ', 'tipoUnidad'),
                  _buildDropdownCatalog('Empresa ', 'empresa'),
                  _buildTextField('Descripción', 'descripcion', isDashed: true),
                  const SizedBox(height: 16),
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

  Widget _buildDropdownCatalog(String label, String key) {
    final List<dynamic>? items = _apiData[key];
    final List<String> itemNames = items?.map((item) => item['nombre'] as String).toList() ?? [];
    
    // Obtener el nombre del valor seleccionado (ya sea por ID o String)
    String? currentValueName;
    if (key == 'catalogoPeligros') {
      // El peligro guarda el nombre directamente
      currentValueName = _selectedValues['peligro'] as String?;
    } else if (_selectedValues[key] is int) {
      // Otros campos guardan el ID. Buscamos el nombre.
      final int? currentId = _selectedValues[key] as int?;
      final selectedItem = items?.firstWhere((item) => item['id'] == currentId, orElse: () => null);
      currentValueName = selectedItem?['nombre'] as String?;
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
          if (key == 'catalogoPeligros') {
            // Se maneja diferente porque activa la carga de condiciones
            _selectedValues['peligro'] = newValueName;
            final int? peligroId = _getIdByName(key, newValueName);
            if (peligroId != null) {
              _fetchCondicionesInseguras(peligroId);
            } else {
              _condicionesInseguras = [];
              _selectedCondicionesInseguras = [];
            }
          } else {
            // Para Severidad y otros, guardamos el ID
            _selectedValues[key] = _getIdByName(key, newValueName);
            // 💡 PRINT PARA VERIFICAR EL VALOR DESPUÉS DE LA SELECCIÓN
            print('Valor seleccionado para $key: ${newValueName} (ID: ${_selectedValues[key]})');
          }
        });
      },
    );
  }

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