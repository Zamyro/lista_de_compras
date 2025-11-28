import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lista_de_compras/models/ingredientes.dart';
import 'package:lista_de_compras/models/receitas.dart';
import 'package:lista_de_compras/receita_detalhes_page.dart';

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
      builder: (_) => AlertDialog(
        title: Text("Apagar Receita"),
        content: Text("Tem certeza que deseja apagar a receita \"$receita\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Apagar"),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await apagarReceita(receita);
    }
  }

  void adicionarReceita() async {
    Receita novaReceita = Receita(nome: '', ingredientes: [], preparo: '');
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nova Receita"),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Nome da Receita'),
          onChanged: (value) => novaReceita = Receita(
            nome: value,
            ingredientes: [],
            preparo: '',
          ),
        ),
        actions: [
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas'),
        backgroundColor: const Color.fromARGB(100, 0, 195, 255),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Receita>('receitas').listenable(),
        builder: (context, Box<Receita> receitasBox, _) {
          if (receitasBox.isEmpty) {
            return const Center(child: Text('Nenhuma receita adicionada.'));
          }

          return ListView.builder(
            itemCount: receitasBox.length,
            itemBuilder: (context, i) {
              Receita r = receitasBox.getAt(i)!;
              return ListTile(
                title: Text(r.nome),
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
                  icon: const Icon(Icons.delete),
                  onPressed: () => receitasBox.deleteAt(i),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarReceita,
        child: const Icon(Icons.add),
      ),
    );
  }
}
