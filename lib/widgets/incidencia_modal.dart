import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class IncidenciaModal {
  static Future<List<File>?> show(BuildContext context) async {
    List<String> incidenciasSeleccionadas = [];
    List<File> imagenesTomadas = [];
    
    final List<String> incidencias = [
      'Problema técnico',
      'Falla de sistema',
      'Consulta general',
      'Problema de red',
      'Daño en la unidad',
      'Fuga de líquido',
      'Ruido inusual',
      'Problema de frenos',
      'Fallo eléctrico',
      'Neumático desinflado',
      'Otro problema'
    ];

    return showDialog<List<File>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> abrirCamara() async {
              final picker = ImagePicker();
              final pickedFile = await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null) {
                setState(() {
                  imagenesTomadas.add(File(pickedFile.path));
                });
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ingrese su Incidencia',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      const Text('Seleccione su Incidencia:'),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 150.0,
                        child: SingleChildScrollView(
                          child: Column(
                            children: incidencias.map((incidencia) {
                              return CheckboxListTile(
                                title: Text(incidencia),
                                value: incidenciasSeleccionadas.contains(incidencia),
                                onChanged: (bool? isChecked) {
                                  setState(() {
                                    if (isChecked == true) {
                                      incidenciasSeleccionadas.add(incidencia);
                                    } else {
                                      incidenciasSeleccionadas.remove(incidencia);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Text('Describa el problema que se presenta:'),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color.fromARGB(255, 141, 136, 136)),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const TextField(
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            hintText: 'Descripción del problema',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Adjunte evidencias:'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: abrirCamara,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        icon: const Icon(Icons.camera_alt, color: Colors.blue),
                        label: const Text('Tomar Foto', style: TextStyle(color: Colors.blue)),
                      ),
                      // Mostrar todas las imágenes guardadas
                      if (imagenesTomadas.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: imagenesTomadas.map((imageFile) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.file(
                                      imageFile,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          imagenesTomadas.remove(imageFile);
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, null),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, imagenesTomadas);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                              ),
                              child: const Text('Guardar'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}