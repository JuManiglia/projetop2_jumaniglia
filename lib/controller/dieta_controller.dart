import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/dieta.dart';

class DietaController {
  final CollectionReference dietaCollection =
      FirebaseFirestore.instance.collection('dieta');

  Future<void> atualizar(Dieta dieta) async {
    await dietaCollection
        .doc(dieta.nome)
        .set(dieta.toMap())
        .then((_) => print('Dieta atualizada com sucesso!'))
        .catchError((error) =>
            print('Erro ao atualizar a dieta: $error'));
  }

  Stream<DocumentSnapshot> listar(String nome) {
    return dietaCollection.doc(nome).snapshots();
  }

  Future<DocumentSnapshot> obterDieta(String userId) {
    return dietaCollection.doc(userId).get();
  }

  void atualizarDieta(String userId, Dieta dieta) {
    dietaCollection
        .doc(userId)
        .set(dieta.toMap())
        .then((_) => print('Dieta atualizada com sucesso!'))
        .catchError((error) =>
            print('Erro ao atualizar a dieta: $error'));
  }
}
