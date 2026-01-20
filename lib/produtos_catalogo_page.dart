import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/produto.dart';
import 'produto_detalhes_page.dart';
import 'cadastro_produto_screen.dart';

class ProdutosCatalogoPage extends StatefulWidget {
  const ProdutosCatalogoPage({super.key});

  @override
  State<ProdutosCatalogoPage> createState() => _ProdutosCatalogoPageState();
}

class _ProdutosCatalogoPageState extends State<ProdutosCatalogoPage> {
  late Box<Produto> catalogoBox;

  @override
  void initState() {
    super.initState();
    catalogoBox = Hive.box<Produto>('produtos_catalogo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produtos cadastrados')),
      body: ValueListenableBuilder(
        valueListenable: catalogoBox.listenable(),
        builder: (_, Box<Produto> box, __) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (_, index) {
              final produto = box.getAt(index)!;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                title: Text(produto.nome),
                subtitle: Text("${produto.marcas?.length ?? 0} marca(s) vinculada(s)"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProdutoDetalhesPage(produto: produto),
                    ),
                  );
                },
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

  void adicionarProduto() {
    // modal de cadastro (nome, código, preço)
  }
}
