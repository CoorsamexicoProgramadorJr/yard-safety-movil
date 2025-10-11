class MenuRep {
  final String id;
  final String tipo; // categoria_reporte_nombre
  final String descripcion;
  final String ubicacion; // zona_nombre
  final String unidad; // puede ser null
  final String empresa; // empresa_reporte (puede ser null)
  final String gravedad; // status_reporte_nombre (ej: Abierto, Cerrado, etc)
  final String catalogo; // eventos[0].nombre
  final List<String> eventos;
  
  // 💡 CAMPOS CRUCIALES AÑADIDOS
  final String rondaEjecutadaId;
  final String zonaId;
  final String ubicacionId;

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
    // Inicialización de los nuevos campos
    required this.rondaEjecutadaId,
    required this.zonaId,
    required this.ubicacionId,
  });

  factory MenuRep.fromJson(Map<String, dynamic> json) {
    final ubicacionData = json['ubicacion'] as Map<String, dynamic>?;
    
    // 1. Extracción de IDs (necesarias para re-emisión)
    // Asumimos 'ronda_ejecutada_id' en el nivel raíz o un valor por defecto.
    final rondaEjecutadaId = json['ronda_ejecutada_id']?.toString() ?? '1'; 
    
    // Las IDs de Zona y Ubicación están anidadas.
    final zonaId = ubicacionData?['zona_id']?.toString() ?? '1';
    final ubicacionId = ubicacionData?['ubicacion_id']?.toString() ?? '';
    
    // 2. Extracción del resto de campos
    return MenuRep(
      id: json['id']?.toString() ?? '',
      tipo: json['categoria_reporte_nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      
      // Se extrae el nombre de la zona desde el objeto anidado
      ubicacion: ubicacionData?['zona_nombre'] ?? 'Sin ubicación',
      
      unidad: json['unidad'] != null 
          ? json['unidad']['numero_economico']?.toString() ?? 'NA' 
          : 'NA',
      empresa: json['empresa_reporte'] != null 
          ? json['empresa_reporte']['empresa_reporte']?.toString() ?? 'NA' 
          : 'NA',
      gravedad: json['status_reporte_nombre'] ?? 'Desconocida',
      
      catalogo: (json['eventos'] != null && json['eventos'].isNotEmpty)
          ? json['eventos'][0]['nombre'] ?? ''
          : '',
      eventos: (json['eventos'] as List<dynamic>?)
              ?.map((e) => e['nombre'].toString())
              .toList() ??
          [],
          
      // 3. Asignación de los nuevos campos (solución al error de compilación)
      rondaEjecutadaId: rondaEjecutadaId,
      zonaId: zonaId,
      ubicacionId: ubicacionId,
    );
  }
}