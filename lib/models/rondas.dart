class Ronda {
  final String id;
  final String titulo;
  final String inicio;
  final String fin;
  final bool disponible;

  Ronda({
    required this.id,
    required this.titulo,
    required this.inicio,
    required this.fin,
    this.disponible = false,
  });
  // contructor para crear una instancia para las rondas 
  //Instancia es cuando a un modelo le metes datos por un metodo contructor 

  factory Ronda.fromJson(Map<String, dynamic> json) {
    return Ronda(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      // Asume que las claves son 'inicio' y 'fin' en el JSON
      inicio: json['inicio'] as String,
      fin: json['fin'] as String,
      disponible: json['disponible'] as bool,
    );
  }
}