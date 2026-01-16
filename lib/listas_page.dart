import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:duck_it/lista_compras_page.dart';

class ListasPage extends StatefulWidget {
  const ListasPage({super.key});

  @override
  State<ListasPage> createState() => _ListasPageState();
}

class _ListasPageState extends State<ListasPage> {
  late final Box<String> listasBox;

  @override
  void initState() {
    super.initState();
    listasBox = Hive.box<String>('listas');
  }

  Future<void> adicionarLista() async {
    String nomeLista = "";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Criar nova lista",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Nome da lista",
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => nomeLista = v.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              if (nomeLista.isEmpty) return;

              // Evita listas duplicadas
              if (listasBox.values.contains(nomeLista)) {
                Navigator.pop(context);
                return;
              }

              await listasBox.add(nomeLista);
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<void> excluirLista(String nomeLista) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Excluir "$nomeLista"?'),
        content: const Text("Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final index = listasBox.values.toList().indexOf(nomeLista);
    if (index == -1) return;

    await listasBox.deleteAt(index);

    final boxName = 'produtos_$nomeLista';
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Listas de Compras",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent.shade100,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent.shade100,
        onPressed: adicionarLista,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: ValueListenableBuilder(
        valueListenable: listasBox.listenable(),
        builder: (_, Box<String> box, __) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma lista criada ainda.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (_, i) {
              final nomeLista = box.getAt(i)!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ListaComprasPage(listaNome: nomeLista),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      title: Text(
                        nomeLista,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => excluirLista(nomeLista),
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
