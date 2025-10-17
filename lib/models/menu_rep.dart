import 'package:intl/intl.dart'; // <--- 💡 Importa el paquete intl

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
  final String severidad; 
  final String severidadId; 

  // 💡 Nuevo campo para la fecha de creación (ya formateada para mostrar)
  final String createdAt; 
 
  // CAMPOS CRUCIALES EXISTENTES
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
    required this.severidad,
    required this.severidadId,
    required this.rondaEjecutadaId,
    required this.zonaId,
    required this.ubicacionId,
    required this.createdAt, // <--- 💡 Añadido al constructor
  });

  factory MenuRep.fromJson(Map<String, dynamic> json) {
    final ubicacionData = json['ubicacion'] as Map<String, dynamic>?;
    
    // 1. Extracción y Formateo de la fecha
    final String rawDate = json['created_at'] ?? '2000-01-01 00:00:00';
    String formattedDate;
    try {
      final DateTime dateTime = DateTime.parse(rawDate);
      // Formato deseado: '15 Oct, 20:45'
      // Ajusta 'es' para español si tienes la localización configurada.
      formattedDate = DateFormat('dd MMM, HH:mm', 'es').format(dateTime); 
    } catch (e) {
      // Manejar el caso si el string de la fecha es inválido
      formattedDate = 'Fecha Inválida';
    }
    
    // 2. Extracción de IDs (necesarias para re-emisión)
    final rondaEjecutadaId = json['ronda_ejecutada_id']?.toString() ?? '1'; 
    final zonaId = ubicacionData?['zona_id']?.toString() ?? '1';
    final ubicacionId = ubicacionData?['ubicacion_id']?.toString() ?? '';
    
    // 3. Extracción de los campos de Severidad
    final severidadId = json['severidad_id']?.toString() ?? 'NA';
    final severidadNombre = json['severidad_nombre']?.toString() ?? 'NA';
    
    // 4. Extracción del resto de campos
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
          
      // Asignación de los campos
      severidad: severidadNombre,
      severidadId: severidadId,
    
      rondaEjecutadaId: rondaEjecutadaId,
      zonaId: zonaId,
      ubicacionId: ubicacionId,
      createdAt: formattedDate, // <--- 💡 Asignación del campo formateado
    );
  }
}