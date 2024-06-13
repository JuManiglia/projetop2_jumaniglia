class Tarefa {
  // campos do documento
  final String uid;
  final String data;
  final String peso;
  final String humor;
  final double altura;
  final double meta;

  Tarefa(this.uid, this.data, this.peso, this.humor, this.altura, this.meta);

  // Transforma um OBJETO em JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'uid': uid,
      'data': data,
      'peso': peso,
      'humor': humor,
      'altura': altura,
      'meta': meta,
    };
  }

  // Transforma um JSON em OBJETO
  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      json['uid'],
      json['data'],
      json['peso'],
      json['humor'],
      json['altura'],
      json['meta'],
    );
  }
}
