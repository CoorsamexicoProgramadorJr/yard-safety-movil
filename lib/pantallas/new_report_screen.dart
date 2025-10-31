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
  final int rondaId; 
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
    'severidad': null, 
  };

  List<dynamic> _condicionesInseguras = [];
  final Map<String, TextEditingController> _controllers = {
    'numeroEconomico': TextEditingController(),
    'placa': TextEditingController(),
    'descripcion': TextEditingController(),
    'descripcionOtro': TextEditingController(),
  };
  final List<File> _selectedImages = [];

  bool get _peligroSeleccionadoEsOtro {
    return _selectedValues['peligro'] == 'Otro';
  }

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  int? _getIdByName(String key, String? name) {
    if (name == null) return null;
    final id = _apiData[key]?.firstWhere(
      (item) => item['nombre'] == name,
      orElse: () => null,
    )?['id'] as int?;
    return id;
  }

  Future<void> _loadFormData() async {
    await Future.wait([
      _fetchApiData('catalogoPeligros', 'select/catalogo-peligros'),
      _fetchApiData('categoriaReporte', 'select/tipo-reporte'),
      _fetchApiData('zona', 'select/zona'),
      _fetchApiData('tipoUnidad', 'select/tipo-unidad'),
      _fetchApiData('empresa', 'select/empresa'),
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
    final severidadId = _selectedValues['severidad'] as int?; 

    if (peligroId == null) {
      _showSnackbar('Selecciona un peligro');
      return;
    }
    
    if (severidadId == null) {
      _showSnackbar('Selecciona la severidad');
      return;
    }

    if (_selectedImages.isEmpty) {
      _showSnackbar('Por favor, agrega al menos una imagen');
      return;
    }
    
    if (_peligroSeleccionadoEsOtro && _controllers['descripcionOtro']!.text.trim().isEmpty) {
      _showSnackbar('Debes ingresar la descripción adicional para el peligro "Otro".');
      return;
    }

    if (!_peligroSeleccionadoEsOtro && _selectedCondicionesInseguras.isEmpty && _condicionesInseguras.isNotEmpty) {
      _showSnackbar('Selecciona al menos una condición insegura');
      return;
    }

    // Lógica para determinar el clasificacion_id
    String clasificacionIdAEnviar = '1'; 
    if (_peligroSeleccionadoEsOtro) {
      // Usamos '15' si el peligro es 'Otro', basado en tu JSON de reporte exitoso.
      clasificacionIdAEnviar = '15'; 
    } else {
      // Usamos '1' como valor por defecto para la clasificación general de reportes normales.
      clasificacionIdAEnviar = '1';
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
    
    // 1️⃣ CLASIFICACIÓN (Condicional)
    request.fields['clasificacion_id'] = clasificacionIdAEnviar; 
    
    request.fields['categoria_reporte_id'] = _selectedValues['categoriaReporte']?.toString() ?? '';
    request.fields['zona_id'] = _selectedValues['zona']?.toString() ?? '';
    request.fields['tipo_unidad_id'] = _selectedValues['tipoUnidad']?.toString() ?? '';
    request.fields['empresa_id'] = _selectedValues['empresa']?.toString() ?? '';
    request.fields['descripcion'] = _controllers['descripcion']!.text;
    request.fields['severidad_id'] = severidadId.toString(); 

    // LÓGICA DE EVENTOS (Condiciones Inseguras o "Otro")
    request.fields['catalogo_evento_id[]'] = peligroId.toString();

    if (_peligroSeleccionadoEsOtro) {
      // 2️⃣ CORRECCIÓN DE CAMPO OTRO: Usamos 'descripcion_otro' que es lo que el backend espera
      request.fields['descripcion_otro'] = _controllers['descripcionOtro']!.text.trim(); 
    } else {
      for (var id in _selectedCondicionesInseguras) {
        request.fields['condicion_insegura_id[]'] = id.toString();
      }
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

  Widget _buildDropdownCatalog(String label, String key) {
    final List<dynamic>? items = _apiData[key];
    final List<String> itemNames = items?.map((item) => item['nombre'] as String).toList() ?? [];
    
    String? currentValueName;
    if (key == 'catalogoPeligros') {
      currentValueName = _selectedValues['peligro'] as String?;
    } else if (_selectedValues[key] is int) {
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
            _selectedValues['peligro'] = newValueName;
            final int? peligroId = _getIdByName(key, newValueName);
            
            // Si el peligro cambia, limpiamos las condiciones y el campo "Otro"
            _condicionesInseguras = [];
            _selectedCondicionesInseguras = [];
            _controllers['descripcionOtro']!.clear(); 
            
            // Si el peligro NO es "Otro", cargamos las condiciones inseguras
            if (peligroId != null && newValueName != 'Otro') {
              _fetchCondicionesInseguras(peligroId);
            }

          } else {
            _selectedValues[key] = _getIdByName(key, newValueName);
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
      maxLines: 1, 
    );
  }
  
  Widget _buildOtroDescriptionField() {
    return CustomTextField(
      label: const Text('Descripción del evento "Otro"'),
      hint: 'Detalla aquí el peligro que identificaste',
      isDashed: true,
      maxLines: 3, 
      controller: _controllers['descripcionOtro']!,
    );
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
                    if (_peligroSeleccionadoEsOtro)
                      _buildOtroDescriptionField()
                    else
                      _buildCondicionInseguraCheckboxList(),
                  
                  _buildDropdownCatalog('Severidad', 'severidad'), 
                  _buildDropdownCatalog('Categoría de Reporte', 'categoriaReporte'),
                  _buildDropdownCatalog('Zona', 'zona'),
                  _buildTextField('Número Económico ', 'numeroEconomico'),
                  _buildTextField('Placa ', 'placa'),
                  _buildDropdownCatalog('Tipo de Unidad ', 'tipoUnidad'),
                  _buildDropdownCatalog('Empresa ', 'empresa'),
                  CustomTextField(
                    label: const Text('Descripción'),
                    hint: 'Detalla aquí la descripción del evento',
                    isDashed: true,
                    controller: _controllers['descripcion']!,
                    maxLines: 3,
                  ),
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
}