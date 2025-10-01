class MenuRep {
  final String id;
  final String tipo; // categoria_reporte_nombre
  final String descripcion;
  final String ubicacion; // zona_nombre
  final String unidad; // puede ser null
  final String empresa; // empresa_reporte (puede ser null)
  final String gravedad; // status_reporte_nombre (ej: Abierto, Cerrado, etc)
  final String catalogo; // no lo vi directo, pero podrías meter eventos[0].nombre
  final List<String> eventos;

  MenuRep({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.ubicacion,
    required this.unidad,
    required this.empresa,
    required this.gravedad,
    required this.catalogo,
    required this.eventos,
  });

  factory MenuRep.fromJson(Map<String, dynamic> json) {
    return MenuRep(
      id: json['id'].toString(),
      tipo: json['categoria_reporte_nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion']?['zona_nombre'] ?? 'Sin ubicación',
      unidad: json['unidad'] != null ? json['unidad']['numero_economico']?.toString() ?? 'NA' : 'NA',
      empresa: json['empresa_reporte'] != null ? json['empresa_reporte']['empresa_reporte']?.toString() ?? 'NA' : 'NA',
      gravedad: json['status_reporte_nombre'] ?? 'Desconocida',
      catalogo: (json['eventos'] != null && json['eventos'].isNotEmpty)
          ? json['eventos'][0]['nombre'] ?? ''
          : '',
      eventos: (json['eventos'] as List<dynamic>?)
              ?.map((e) => e['nombre'].toString())
              .toList() ??
          [],
    );
  }
}
