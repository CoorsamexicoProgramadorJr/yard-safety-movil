// models/menu_rep.dart
import 'dart:io';

class MenuRep {
  final String id;
  final String empresa;
  final String unidad;
  final String ubicacion;
  final String descripcion;
  final String tipo;
  final String gravedad;
  final String catalogo;
  final List<File> imagenes;

  MenuRep({
    required this.id,
    required this.empresa,
    required this.unidad,
    required this.ubicacion,
    required this.descripcion,
    required this.tipo,
    required this.gravedad,
     required this.catalogo,
    required this.imagenes,
   
  });

  factory MenuRep.fromJson(Map<String, dynamic> json) {
    return MenuRep(
      id: json['id'].toString(),
      empresa: json['empresa'] ?? '',
      unidad: json['unidad'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipo: json['tipo'] ?? '',
      gravedad: json['gravedad'] ?? '',
      catalogo: json['catalogo'],
      imagenes: [], // Asumimos que las imágenes no vienen en el GET inicial
    );
  }
}