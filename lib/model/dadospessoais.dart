class DadosPessoais {
  String nome;
  String telefone;
  String sexo;
  int idade;
  double peso;
  double altura;

  DadosPessoais({
    required this.nome,
    required this.telefone,
    required this.sexo,
    required this.idade,
    required this.peso,
    required this.altura,
  });

  double calcularIMC() {
    return peso / ((altura / 100) * (altura / 100)); 
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'telefone': telefone,
      'sexo': sexo,
      'idade': idade,
      'peso': peso,
      'altura': altura,
    };
  }

  factory DadosPessoais.fromMap(Map<String, dynamic> map) {
    return DadosPessoais(
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      sexo: map['sexo'] ?? '',
      idade: map['idade'] ?? 0,
      peso: map['peso'] ?? 0.0,
      altura: map['altura']??0,

    );
  }
}