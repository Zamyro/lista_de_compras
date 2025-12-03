import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:duck_it/models/produto.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import './widget/campo_preco_widget.dart';

class ListaComprasPage extends StatefulWidget {
  final String listaNome;

  const ListaComprasPage({
    super.key,
    required this.listaNome
  });

  @override
  _ListaComprasPageState createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  int quantidade = 1;
  double preco = 0.0;
  String? listaAtual;
  Box<Produto>? produtosBox;

  final frasesPatos = [
    'O Senhor é meu pastor; nada me faltará. - Salmos 23:1',
    'Confia no Senhor de todo o teu coração. - Provérbios 3:5',
    'Tudo posso naquele que me fortalece. - Filipenses 4:13',

  ];

  @override
  void initState() {
    super.initState();
    abrirBox();
  }

  Future<void> abrirBox() async {
    await Hive.openBox<Produto>('produtos_${widget.listaNome}');
    produtosBox = Hive.box<Produto>('produtos_${widget.listaNome}');
    setState(() {});
  }

  void adicionarProduto([Produto? produto]) {
    if (produtosBox == null) return;

    if (produto == null) {
      nome = '';
      quantidade = 1;
      preco = 0.0;
    } else {
      nome = produto.nome;
      quantidade = produto.quantidade;
      preco = produto.preco;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(produto == null ? 'Adicionar Produto' : 'Editar Produto'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: nome,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) => value!.isEmpty ? 'Informe o nome do produto' : null,
                    onSaved: (value) => nome = value!,
                  ),
                  TextFormField(
                    initialValue: quantidade.toString(),
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Informe a quantidade' : null,
                    onSaved: (value) => quantidade = int.tryParse(value!) ?? 1,
                  ),
                  CampoPreco(
                    valorInicial: produto?.preco,
                    onSaved: (value) { 
                      preco = value;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (produto == null) {
                    produtosBox?.add(Produto(nome: nome, quantidade: quantidade, preco: preco));
                  } else {
                    produto.nome = nome;
                    produto.quantidade = quantidade;
                    produto.preco = preco;
                    produtosBox?.putAt(produtosBox!.values.toList().indexOf(produto), produto);
                  }
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text('Salvar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _limparLista() {
    produtosBox?.clear();
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista de compras limpa!')),
      );
    });
  }

  Future<void> apagarLista(String nome) async {
    var listasBox = Hive.box<String>('listas');

    int index = listasBox.values.toList().indexOf(nome);
    if (index != -1) {
      await listasBox.deleteAt(index);
    }

    await Hive.deleteBoxFromDisk('produtos_$nome');

    if (listaAtual == nome) {
      if (listasBox.isNotEmpty) {
        listaAtual = listasBox.values.first;
        await Hive.openBox<Produto>('produtos_$listaAtual');
        produtosBox = Hive.box<Produto>('produtos_$listaAtual');
      } else {
        listaAtual = null;
        produtosBox = null;
      }
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lista $nome apagada!')),
    );
  }

  Future<void> confirmarApagarLista(String nome) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Apagar "$nome"?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    if (confirmou == true) {
      await apagarLista(nome);
    }
  }

  Future<void> _confirmarLimpeza() async {
    bool? confirmacao = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar Lista'),
          content:
              const Text('Você tem certeza que deseja limpar a lista de compras?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Limpar Lista'),
            ),
          ],
        );
      },
    );

    if (confirmacao == true) {
      _limparLista();
    }
  }

  void gerarPDF() async {
    final pdf = pw.Document();
    final frase = frasesPatos[Random().nextInt(frasesPatos.length)];

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(listaAtual ?? 'Lista de Compras',
                    style:
                        pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text(frase, style: const pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              ...produtosBox!.values.map((p) => pw.Text(
                  "${p.quantidade}x ${p.nome} - R\$ ${(p.preco * p.quantidade).toStringAsFixed(2)}")),
              pw.Divider(),
              pw.Text(
                "Total: R\$ ${produtosBox?.values.fold(0.0, (sum, p) => sum + p.preco * p.quantidade).toStringAsFixed(2)}",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Emitido em: ${DateTime.now()}",
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  void adicionarLista() async {
    String novaLista = '';
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nova Lista"),
        content: TextField(
          decoration: const InputDecoration(labelText: "Nome da lista"),
          onChanged: (value) => novaLista = value,
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (novaLista.isNotEmpty) {
                Hive.box<String>('listas').add(novaLista);
                Hive.openBox<Produto>('produtos_$novaLista');
                setState(() {
                  listaAtual = novaLista;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Adicionar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (produtosBox == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double total = produtosBox!.values.fold(
      0.0,
      (sum, p) => sum + p.preco * p.quantidade,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(listaAtual ?? 'Lista de Compras'),
        backgroundColor: Colors.pinkAccent.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: gerarPDF,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmarLimpeza,
          ),
        ],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: produtosBox!.listenable(),
            builder: (context, Box<Produto> box, _) {
              if (box.isEmpty) {
                return const Center(child: Text('Nenhum produto adicionado.'));
              }
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final produto = box.getAt(index)!;
                  return Dismissible(
                    key: Key(produto.nome + index.toString()),
                    background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white)),
                    secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (_) {
                      box.deleteAt(index);
                      setState(() {});
                    },
                    child: ListTile(
                      title: Text(produto.nome),
                      subtitle: Text(
                          "${produto.quantidade}un x  R\$ ${produto.preco.toStringAsFixed(2)}"),
                      onTap: () => adicionarProduto(produto),
                      trailing: Text("Clique para editar"),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => adicionarProduto(),
        splashColor: Colors.pink,
        backgroundColor: Colors.pinkAccent.shade100,
        child: const Icon(
          Icons.add,
          color: Colors.black
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pinkAccent.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: R\$ ${total.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
