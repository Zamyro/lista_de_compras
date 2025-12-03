import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:duck_it/models/ingredientes.dart';
import 'package:duck_it/models/receitas.dart';
import 'package:duck_it/receita_detalhes_page.dart';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  Receita? receitaAtual;
  Box<Ingrediente>? ingredientesBox;

  @override
  void initState() {
    super.initState();
    abrirBoxes();
  }

  Future<void> abrirBoxes() async {
    var receitasBox = Hive.box<Receita>('receitas');
    receitaAtual = receitasBox.values.first;

    await Hive.openBox<Ingrediente>('ingredientes_$receitaAtual');
    ingredientesBox = Hive.box<Ingrediente>('ingredientes_$receitaAtual');

    setState(() {});
  }

  Future<void> apagarReceita(String receita) async {
    var receitasBox = Hive.box<Receita>('receitas');

    int index = receitasBox.values.toList().indexOf(
      receitasBox.values.firstWhere((r) => r.nome == receita),
    );
    if (index != -1) {
      receitasBox.deleteAt(index);
      await Hive.deleteBoxFromDisk('ingredientes_$receita');
    }

    await Hive.deleteBoxFromDisk('ingredientes_$receita');

    if (receitaAtual == receita) {
      if (receitasBox.isNotEmpty) {
        receitaAtual = receitasBox.values.first;
        await Hive.openBox<Ingrediente>('ingredientes_$receitaAtual');
        ingredientesBox = Hive.box<Ingrediente>('ingredientes_$receitaAtual');
      } else {
        receitaAtual = null;
        ingredientesBox = null;
      }
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Receita "$receita" apagada.')),
    );
  }

  Future<void> confirmarApagarReceita(String receita) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Apagar Receita"),
        content: Text("Tem certeza que deseja apagar a receita \"$receita\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await apagarReceita(receita);
    }
  }

  void adicionarReceita(BuildContext context) async {
    Receita novaReceita = Receita(nome: '', ingredientes: [], preparo: '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Nova Receita", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Nome da Receita',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => novaReceita = Receita(
            nome: value,
            ingredientes: [],
            preparo: '',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (novaReceita.nome.isNotEmpty) {
                Hive.box<Receita>('receitas').add(novaReceita);
                Hive.openBox('ingredientes_$novaReceita');
                setState(() {
                  receitaAtual = novaReceita;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receitas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent.shade100,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent.shade100,
        onPressed: () => adicionarReceita(context),
        child: const Icon(
          Icons.add,
          color: Colors.black
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Receita>('receitas').listenable(),
        builder: (context, Box<Receita> receitasBox, _) {
          if (receitasBox.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma receita adicionada.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              )
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: receitasBox.length,
            itemBuilder: (context, i) {
              Receita r = receitasBox.getAt(i)!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReceitasPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      title: Text(
                        r.nome,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      titleTextStyle: const TextStyle(fontSize: 24, color: Colors.black),
                      onTap: () async {
                        receitaAtual = r;
                        final ingredientesBoxName = 'ingredientes_${receitaAtual!.nome}';
                        if (!Hive.isBoxOpen(ingredientesBoxName)) {
                          await Hive.openBox<Ingrediente>(ingredientesBoxName);
                        }
                        ingredientesBox = Hive.box<Ingrediente>(ingredientesBoxName);
                        setState(() {});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReceitaDetalhesPage(receita: receitaAtual!),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmarApagarReceita(r.nome),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
