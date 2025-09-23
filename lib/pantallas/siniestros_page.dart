import 'package:flutter/material.dart';
/// Modelo de datos para un siniestro
class Siniestro {
  final String id;
  final String tipoSiniestro;
  final String unidad;
  final String fecha;

  Siniestro({
    required this.id,
    required this.tipoSiniestro,
    required this.unidad,
    required this.fecha,
  });
}

class SiniestrosPage extends StatelessWidget {
  const SiniestrosPage({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Menú De Siniestros';

    // Datos de ejemplo (mock). Luego los reemplazas con la API/BD
    final List<Siniestro> siniestros = List.generate(
      5,
      (i) => Siniestro(
        id: "SIN-${i + 1}",
        tipoSiniestro: "Tipo de siniestro #${i + 1}",
        unidad: "Unidad ${i + 1}",
        fecha: "2025-08-${i + 1}",
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(title),
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 20),
        itemCount: siniestros.length,
        itemBuilder: (context, index) {
          final siniestro = siniestros[index];
          return Card(
             color: Colors.transparent,        
             elevation:0,                  
             shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            
            child: ListTile(
              title: Text(
                siniestro.tipoSiniestro,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siniestro.unidad,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Fecha: ${siniestro.fecha}",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Editar ${siniestro.id}')),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 150.0), 
         
        child: FloatingActionButton(
          onPressed: () {
             // **CORRECCIÓN:** Llama a la función showIncidenciaModal directamente
           //showIncidenciaModal(context, onBack: () {  });
          },
          backgroundColor: Colors.blue,
           shape: RoundedRectangleBorder(   
           borderRadius: BorderRadius.circular(1000.0),
          side: const BorderSide(
        color: Color.fromARGB(255, 0, 149, 255), width: 1.0),
    ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
