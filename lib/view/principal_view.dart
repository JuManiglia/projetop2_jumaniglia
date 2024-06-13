import 'package:flutter/material.dart';
import 'package:projetop2_jumaniglia/main.dart';
import '../controller/login_controller.dart';
import '../controller/tarefa_controller.dart';
import '../model/tarefa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controller/dieta_controller.dart';
import '../model/dieta.dart';


class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  var txtData = TextEditingController();
  var txtPeso = TextEditingController();
  String? selectedHumor;
  final List<String> humores = ['Feliz', 'Triste', 'Neutro', 'Ansioso', 'Estressado'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seus Registros'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              LoginController().logout();
              Navigator.pop(context);
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.pink),
              child: Text(
                'MENU',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: Text('Pesquisar'),
              onTap: () {
                _showPesquisarDialog(context);
              },
            ),
            ListTile(
              title: Text('Dados Pessoais'),
              onTap: () {
                _showDadosPessoaisDialog(context);
              },
            ),
            ListTile(
            title: Text('Dieta'),
            onTap: () {
            _showDietaDialog(context);
                },
               ),
            
            ListTile(
              title: Text('Sobre Nós'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Sobre Nós"),
                      content: Text(
                          "Somos uma empresa fundada em 2024, com o objetivo de te auxiliar no processo de emagrecimento. Com um metódo intuitivo, permite que você visualize sua evolução rumo à sua meta!"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("OK"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('dados_pessoais')
            .doc(LoginController().idUsuario)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Erro ao carregar dados pessoais"));
          } else {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final double altura = userData['altura'];
            final double meta = userData['meta'];

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: TarefaController().listar().snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return Center(
                        child: Text("Falha na conexão."),
                      );
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      final dados = snapshot.requireData;
                      if (dados.size > 0) {
                        return ListView.builder(
                          itemCount: dados.size,
                          itemBuilder: (context, index) {
                            String id = dados.docs[index].id;
                            dynamic item = dados.docs[index].data();

                            double peso = double.parse(item['peso']);
                            double imc = peso / ((altura / 100) * (altura / 100));
                            double diferencaPeso = peso - meta;
                            String mensagemMeta = diferencaPeso > 0
                                ? 'Falta emagrecer ${diferencaPeso.toStringAsFixed(2)} kg para atingir a meta.'
                                : 'Falta engordar ${(-diferencaPeso).toStringAsFixed(2)} kg para atingir a meta.';

                            return Card(
                              child: ListTile(
                                title: Text(item['data']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Peso: ${item['peso']} kg - Humor: ${item['humor']}'),
                                    Text('IMC: ${imc.toStringAsFixed(2)}'),
                                    Text(mensagemMeta),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 80,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          txtData.text = item['data'];
                                          txtPeso.text = item['peso'];
                                          setState(() {
                                            selectedHumor = item['humor'];
                                          });
                                          salvarTarefa(context, docId: id);
                                        },
                                        icon: Icon(Icons.edit_rounded),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          TarefaController().excluir(context, id);
                                        },
                                        icon: Icon(Icons.delete_rounded),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {},
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text("Nenhum registro encontrado."),
                        );
                      }
                  }
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          salvarTarefa(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void salvarTarefa(BuildContext context, {String? docId}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text((docId == null) ? "Adicionar" : "Editar Registro"),
          content: SizedBox(
            height: 300,
            width: 300,
            child: Column(
              children: [
                TextField(
                  controller: txtData,
                  decoration: InputDecoration(
                    labelText: 'Data',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: txtPeso,
                  decoration: InputDecoration(
                    labelText: 'Peso',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: selectedHumor,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedHumor = newValue;
                    });
                  },
                  items: humores.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Humor',
                    prefixIcon: Icon(Icons.mood),
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 10),
          actions: [
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                txtData.clear();
                txtPeso.clear();
                setState(() {
                  selectedHumor = null;
                });
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Salvar"),
              onPressed: () async {
                final userId = LoginController().idUsuario;
                final userDoc = await FirebaseFirestore.instance.collection('dados_pessoais').doc(userId).get();
                final userData = userDoc.data();
                final double altura = userData?['altura'] ?? 0;
                final double meta = userData?['meta'] ?? 0;

                var t = Tarefa(
                  LoginController().idUsuario,
                  txtData.text,
                  txtPeso.text,
                  selectedHumor ?? '',
                  altura,
                  meta,
                );

                if (docId == null) {
                  TarefaController().adicionar(context, t);
                } else {
                  TarefaController().atualizar(context, docId, t);
                }

                txtData.clear();
                txtPeso.clear();
                setState(() {
                  selectedHumor = null;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showPesquisarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var searchData = TextEditingController();
        return AlertDialog(
          title: Text("Pesquisar por Data"),
          content: TextField(
            controller: searchData,
            decoration: InputDecoration(
              labelText: 'Digite a data (dd/mm/aaaa)',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text("Pesquisar"),
              onPressed: () {
                
                String searchDate = searchData.text;
                _searchByDate(context, searchDate);
              },
            ),
          ],
        );
      },
    );
  }

  void _searchByDate(BuildContext context, String searchDate) async {
  if (searchDate.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor, digite uma data.'),
      ),
    );
    return;
  }

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('registros')
        .where('uid', isEqualTo: LoginController().idUsuario)
        .where('data', isEqualTo: searchDate)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          var data = querySnapshot.docs.first.data();
          return AlertDialog(
            title: Text("Resultado da Pesquisa"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Data: ${data['data']}"),
                Text("Peso: ${data['peso']}"),
                Text("Humor: ${data['humor']}"),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Fechar"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nenhum registro encontrado para a data especificada.'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao buscar registros: $e'),
      ),
    );
  }
}



  void _showDadosPessoaisDialog(BuildContext context) async {
  var userId = LoginController().idUsuario;
  var document = await FirebaseFirestore.instance.collection('dados_pessoais').doc(userId).get();

  if (document.exists) {
    var data = document.data();
    var txtNome = TextEditingController(text: data?['nome']);
    var txtEmail = TextEditingController(text: data?['email']);
    var txtTelefone = TextEditingController(text: data?['telefone']);
    var txtAltura = TextEditingController(text: data?['altura']?.toString() ?? '');
    var txtPesoatual = TextEditingController(text: data?['peso_atual']?.toString() ?? '');
    var txtMeta = TextEditingController(text: data?['meta']?.toString() ?? '');
    double altura = double.tryParse(data?['altura']?.toString() ?? '') ?? 0;
    double pesoAtual = double.tryParse(data?['peso_atual']?.toString() ?? '') ?? 0;
    double meta = double.tryParse(data?['meta']?.toString() ?? '') ?? 0;

    // Calcular o IMC
    double imc = pesoAtual / ((altura / 100) * (altura / 100));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isEditing = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Dados Pessoais"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: txtNome,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !isEditing,
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: txtEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !isEditing,
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: txtTelefone,
                    decoration: InputDecoration(
                      labelText: 'Telefone',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !isEditing,
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: txtAltura,
                    decoration: InputDecoration(
                      labelText: 'Altura (cm)',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !isEditing,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        altura = double.tryParse(value) ?? 0;
                        imc = pesoAtual / ((altura / 100) * (altura / 100)); // Recalcular IMC
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: txtPesoatual,
                    decoration: InputDecoration(
                      labelText: 'Peso Atual (kg)',
                      prefixIcon: Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !isEditing,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        pesoAtual = double.tryParse(value) ?? 0;
                        imc = pesoAtual / ((altura / 100) * (altura / 100)); // Recalcular IMC
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: txtMeta,
                    decoration: InputDecoration(
                      labelText: 'Meta (kg)',
                      prefixIcon: Icon(Icons.flag),
                      border: OutlineInputBorder(),
                    ),
                    readOnly: !isEditing,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        meta = double.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Text("IMC: ${imc.toStringAsFixed(2)}"),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isEditing)
                  ElevatedButton(
                    child: Text("Salvar"),
                    onPressed: () {
                      var dadosPessoais = {
                        'nome': txtNome.text,
                        'email': txtEmail.text,
                        'telefone': txtTelefone.text,
                        'altura': altura,
                        'peso_atual': pesoAtual,
                        'meta': meta,
                      };

                      FirebaseFirestore.instance
                          .collection('dados_pessoais')
                          .doc(LoginController().idUsuario)
                          .set(dadosPessoais);

                      setState(() {
                        isEditing = false;
                      });

                      Navigator.of(context).pop();
                    },
                  )
                else
                  ElevatedButton(
                    child: Text("Editar"),
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nenhum dado pessoal encontrado.'),
      ),
    );
  }
  
}

void _showDietaDialog(BuildContext context) async {
  var userId = LoginController().idUsuario;
  var document = await FirebaseFirestore.instance.collection('dieta').doc(userId).get();

  if (document.exists) {
    var data = document.data();
    var txtCafe = TextEditingController(text: data?['café da manhã']);
    var txtAlmoco = TextEditingController(text: data?['almoço']);
    var txtJantar = TextEditingController(text: data?['jantar']);
    var txtCaloria = TextEditingController(text: data?['calorias']?.toString() ?? '');
    double caloria = double.tryParse(data?['calorias']?.toString() ?? '') ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isEditing = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Dieta"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: txtCafe,
                      decoration: InputDecoration(
                        labelText: 'Café da manhã',
                        prefixIcon: Icon(Icons.free_breakfast),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: !isEditing,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: txtAlmoco,
                      decoration: InputDecoration(
                        labelText: 'Almoço',
                        prefixIcon: Icon(Icons.lunch_dining),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: !isEditing,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: txtJantar,
                      decoration: InputDecoration(
                        labelText: 'Jantar',
                        prefixIcon: Icon(Icons.dinner_dining),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: !isEditing,
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: txtCaloria,
                      decoration: InputDecoration(
                        labelText: 'Calorias recomendadas',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      readOnly: !isEditing,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          caloria = double.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (isEditing)
                  ElevatedButton(
                    child: Text("Salvar"),
                    onPressed: () {
                      var dieta = {
                        'café da manhã': txtCafe.text,
                        'almoço': txtAlmoco.text,
                        'jantar': txtJantar.text,
                        'calorias': caloria,
                      };

                      FirebaseFirestore.instance
                          .collection('dieta')
                          .doc(LoginController().idUsuario)
                          .set(dieta);

                      setState(() {
                        isEditing = false;
                      });

                      Navigator.of(context).pop();
                    },
                  )
                else
                  ElevatedButton(
                    child: Text("Editar"),
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  } else {
    print('Document does not exist');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nenhuma dieta encontrada.'),
      ),
    );
  }
}

}