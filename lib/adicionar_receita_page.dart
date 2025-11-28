import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lista_de_compras/models/ingredientes.dart';
import 'package:lista_de_compras/models/receitas.dart';

class AdicionarReceitaPage extends StatefulWidget {
  final Receita? receita;

  const AdicionarReceitaPage({super.key, this.receita});

  @override
  State<AdicionarReceitaPage> createState() => _AdicionarReceitaPageState();
}

class _AdicionarReceitaPageState extends State<AdicionarReceitaPage> {
  late TextEditingController nomeController;
  late TextEditingController preparoController;

  List<Ingrediente> ingredientes = [];

  @override
  void initState() {
    super.initState();

    nomeController = TextEditingController(text: widget.receita?.nome ?? '');
    preparoController = TextEditingController(text: widget.receita?.preparo ?? '');

    ingredientes = widget.receita?.ingredientes.toList() ?? [];
  }

  void adicionarIngrediente() {
    showDialog(
      context: context,
      builder: (_) {
        String nome = "";
        String quantidade = "";
        return AlertDialog(
          title: const Text("Adicionar Ingrediente"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Nome"),
                onChanged: (v) => nome = v,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Quantidade"),
                onChanged: (v) => quantidade = v,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              child: const Text("Adicionar"),
              onPressed: () {
                setState(() {
                  ingredientes.add(Ingrediente(nome: nome, quantidade: quantidade));
                });
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void salvar() {
    final box = Hive.box<Receita>('receitas');

    if (widget.receita == null) {
      Hive.box<Receita>('receitas').add(
        Receita(
          nome: nomeController.text,
          ingredientes: ingredientes,
          preparo: preparoController.text,
        ),
      );
    } else {
      widget.receita!.nome = nomeController.text;
      widget.receita!.ingredientes = ingredientes;
      widget.receita!.preparo = preparoController.text;
      box.putAt(box.values.toList().indexOf(widget.receita!), widget.receita!);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receita == null ? "Adicionar Receita" : "Editar Receita"),
        backgroundColor: const Color.fromARGB(100, 0, 195, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome da Receita",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Ingredientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ingredientes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar"),
                  onPressed: adicionarIngrediente,
                )
              ],
            ),
            const SizedBox(height: 10),

            if (ingredientes.isEmpty)
              const Text("Nenhum ingrediente adicionado."),

            ...ingredientes.map((ing) {
              return Card(
                child: ListTile(
                  title: Text(ing.nome),
                  subtitle: Text("Quantidade: ${ing.quantidade}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => ingredientes.remove(ing));
                    },
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Modo de Preparo
            const Text(
              "Modo de Preparo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: preparoController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: "Descreva aqui todo o passo a passo...\n\nUse parágrafos, pontos e quebras de linha.",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: salvar,
              child: const Text("Salvar Receita"),
            ),
          ],
        ),
      ),
    );
  }
}
