import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/dadospessoais.dart';

class DadosPessoaisController {
  final CollectionReference dadosPessoaisCollection =
      FirebaseFirestore.instance.collection('dados_pessoais');

  Future<void> atualizar(DadosPessoais dados) async {
    await dadosPessoaisCollection
        .doc(dados.nome) 
        .set(dados.toMap())
        .then((_) => print('Dados pessoais atualizados com sucesso!'))
        .catchError((error) => print('Erro ao atualizar os dados pessoais: $error'));
  }

  Stream<DocumentSnapshot> listar(String nome) {
    return dadosPessoaisCollection.doc(nome).snapshots();
  }

  obterDadosPessoais() {}

  void atualizarDadosPessoais(DadosPessoais dadosPessoais) {}
}