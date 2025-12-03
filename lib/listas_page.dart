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
  late Box<String> listasBox;

  @override
  void initState() {
    super.initState();
    listasBox = Hive.box<String>('listas');
  }

  void adicionarLista(BuildContext context) async {
    String novaLista = "";

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Criar nova lista", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          decoration: const InputDecoration(
            labelText: "Nome da lista",
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => novaLista = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async{
              if (novaLista.isNotEmpty) {
                await listasBox.add(novaLista);
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  Future<void> confirmarExcluir(String nome) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Apagar lista \"$nome\"?"),
        content: const Text("Essa ação não pode ser desfeita."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancelar",
                style: TextStyle(color: Colors.black)
              )
          ),
          TextButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Excluir",
                style: TextStyle(color: Colors.white)
              )
          ),
        ],
      ),
    );
    if (confirmar == true) {
      final index = listasBox.values.toList().indexOf(nome);
      if (index != -1) {
        listasBox.deleteAt(index);
        await Hive.deleteBoxFromDisk('produtos_$nome');
        setState(() {});
      }
    }
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
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent.shade100,
        onPressed: () => adicionarLista(context),
        child: const Icon(
          Icons.add,
          color: Colors.black
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: listasBox.listenable(),
        builder: (context, Box<String> box, _) {
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
            itemBuilder: (context, i) {
              String nome = box.getAt(i)!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ListaComprasPage(listaNome: nome),
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
                        nome,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => confirmarExcluir(nome),
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
