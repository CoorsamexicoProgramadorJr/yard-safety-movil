import 'package:flutter/material.dart';
import '../models/menu_rep.dart';

class ReporteCard extends StatelessWidget {
  final MenuRep reporte;

  const ReporteCard({super.key, required this.reporte});

  @override
  Widget build(BuildContext context) {
    final String cardTitle = '${reporte.tipo}: ${reporte.ubicacion}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cardTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 1, 21, 56),
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
            // Detalles adicionales como Empresa, Unidad, Gravedad
           /// _buildDetailRow(Icons.business, 'Empresa:', reporte.empresa),
            // Iconos eliminados de Unidad y Gravedad
            _buildDetailRow(null, 'Unidad:', reporte.unidad), // Ya no se pasa un IconData
            _buildDetailRow(null, 'Gravedad:', reporte.gravedad, color: _getGravedadColor(reporte.gravedad)), // Ya no se pasa un IconData
          ],
        ),
      ),
    );
  }

  // Se modificó IconData a ser nullable (IconData?) para que sea opcional
  Widget _buildDetailRow(IconData? icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Solo muestra el icono si no es nulo
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[700]),
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
              style: TextStyle(fontSize: 13, color: color ?? Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getGravedadColor(String gravedad) {
    switch (gravedad.toLowerCase()) {
      case 'crítica':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'media':
        return Colors.amber;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}