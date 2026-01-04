import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/produto.dart';
import 'produto_detalhes_page.dart';
import 'cadastro_produto_screen.dart';

class ProdutosListaPage extends StatelessWidget {
  const ProdutosListaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Produto>('produtos');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus Produtos"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Produto> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("Nenhum produto cadastrado."));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final produto = box.getAt(index);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                  title: Text(produto?.nome ?? "Sem nome"),
                  subtitle: Text("${produto?.marcas?.length ?? 0} marca(s) vinculada(s)"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Navega para a tela de Detalhes
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProdutoDetalhesPage(produto: produto!),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => CadastroProdutoScreen())
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}