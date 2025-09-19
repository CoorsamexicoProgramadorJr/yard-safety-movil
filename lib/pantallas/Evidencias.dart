import 'dart:io';
import 'package:flutter/material.dart';

class EvidenciasPage extends StatefulWidget {
  final List<File> imagenes;

  const EvidenciasPage({super.key, required this.imagenes});

  @override
  State<EvidenciasPage> createState() => _EvidenciasPageState();
}

class _EvidenciasPageState extends State<EvidenciasPage> {
  final List<File> _imagenesSeleccionadas = [];

  void _eliminarImagenes() {
    setState(() {
      widget.imagenes.removeWhere((imagen) => _imagenesSeleccionadas.contains(imagen));
      _imagenesSeleccionadas.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evidencias'),
        actions: [
          if (_imagenesSeleccionadas.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _eliminarImagenes,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: widget.imagenes.length,
          itemBuilder: (context, index) {
            final imagen = widget.imagenes[index];
            final isSelected = _imagenesSeleccionadas.contains(imagen);
            return Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    imagen,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _imagenesSeleccionadas.add(imagen);
                        } else {
                          _imagenesSeleccionadas.remove(imagen);
                        }
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue;
                      }
                      return Colors.white;
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}