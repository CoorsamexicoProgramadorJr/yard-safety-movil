import 'package:flutter/material.dart';
import '../models/menu_rep.dart';

class ReporteCard extends StatelessWidget {
  final MenuRep reporte;

  const ReporteCard({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // RichText para separar color del tipo y ubicación
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${reporte.tipo}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getTipoColor(reporte.tipo),
                    ),
                  ),
                  TextSpan(
                    text: '   en ${reporte.ubicacion}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 1, 21, 56),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              reporte.descripcion,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(null, 'Unidad:', reporte.unidad),
            _buildDetailRow(null, 'Estatus:', reporte.gravedad),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData? icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: const Color.fromARGB(255, 3, 232, 26)),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: color ?? const Color.fromARGB(221, 0, 0, 0)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'incidente':
        return const Color.fromARGB(255, 208, 162, 25);
      case 'accidente':
        return Colors.orange;
      case 'siniestro':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
