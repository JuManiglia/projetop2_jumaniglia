class Dieta {
  String nome;
  String cafe;
  String almoco;
  String jantar;
  double calorias;

  Dieta({
    required this.nome,
    required this.cafe,
    required this.almoco,
    required this.jantar,
    required this.calorias,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cafe': cafe,
      'almoco': almoco,
      'jantar': jantar,
      'calorias': calorias,
    };
  }

  factory Dieta.fromMap(Map<String, dynamic> map) {
    return Dieta(
      nome: map['nome'] ?? '',
      cafe: map['cafe'] ?? '',
      almoco: map['almoco'] ?? '',
      jantar: map['jantar'] ?? '',
      calorias: map['calorias']?.toDouble() ?? 0.0,
    );
  }
}
