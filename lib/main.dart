import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lista_de_compras/models/produto.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ProdutoAdapter());
  await Hive.openBox<Produto>('produtos');
  runApp(const ListaComprasApp());
}

class ListaComprasApp extends StatelessWidget {
  const ListaComprasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: ListaComprasPage(),
    );
  }
}

class ListaComprasPage extends StatefulWidget {
  @override
  _ListaComprasPageState createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  final Box<Produto> produtosBox = Hive.box<Produto>('produtos');
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  int quantidade = 1;
  double preco = 0.0;

  final frasesPatos = [
    'Quack, quack! Vamos às compras!',
    'Pato feliz, lista cheia!',
    'Compre tudo que o pato precisa!',
    'Lista de compras do pato: completa!',
    'Pato esperto, lista organizada!',
    'Compras do pato: sempre em dia!',
    'Pato no mercado, alegria garantida!',
    'Lista de compras do pato: sucesso total!',
    'Pato e compras: combinação perfeita!'
  ];

  void adicionarProduto([Produto? produto]) {
    showDialog(
      context: context,
      builder: (_) {
        if (produto != null) {
          nome = produto.nome;
          quantidade = produto.quantidade;
          preco = produto.preco;
        } else {
          nome = '';
          quantidade = 1;
          preco = 0.0;
        }

        return AlertDialog(
          title: Text(produto == null ? 'Adicionar Produto' : 'Editar Produto'),
          content: Form(
            key: _formKey,
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
                TextFormField(
                  initialValue: preco.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => value!.isEmpty ? 'Informe o preço' : null,
                  onSaved: (value) => preco = double.tryParse(value!) ?? 0.0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (produto == null) {
                    produtosBox.add(Produto(nome: nome, quantidade: quantidade, preco: preco));
                  } else {
                    produto.nome = nome;
                    produto.quantidade = quantidade;
                    produto.preco = preco;
                    produtosBox.putAt(produtosBox.values.toList().indexOf(produto), produto);
                  }
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Salvar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
          ],
        );
      }
    );
  }

  void _limparLista() {
    produtosBox.clear();
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lista de compras limpa!')),
      );
    });
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
                child: pw.Text("Lista de Compras",
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ),
              pw.Center(
                child: pw.Text(frase, style: pw.TextStyle(fontSize: 12)),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              ...produtosBox.values.map((p) => pw.Text(
                  "${p.quantidade}x ${p.nome} - R\$ ${(p.preco * p.quantidade).toStringAsFixed(2)}")),
              pw.Divider(),
              pw.Text(
                "Total: R\$ ${produtosBox.values.fold(0.0, (sum, p) => sum + p.preco * p.quantidade).toStringAsFixed(2)}",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text("Emitido em: ${DateTime.now()}",
                  style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    double total = produtosBox.values.fold(
      0.0, (sum, p) => sum + p.preco * p.quantidade);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 236, 214, 240),
        title: Text(
          'Lista de Compras', 
          style: TextStyle(color: Color.fromARGB(255, 150, 23, 175)),
        ),
        actions: [
          IconButton(
            color: Color.fromARGB(255, 150, 23, 175),
            icon: Icon(Icons.picture_as_pdf),
            onPressed: gerarPDF,
          ),
          IconButton(
            color: Color.fromARGB(255, 150, 23, 175),
            icon: Icon(Icons.delete_forever),
            onPressed: _limparLista,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.contain),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: produtosBox.listenable(),
            builder: (context, Box<Produto> box, _) {
              if (box.isEmpty) {
                return Center(child: Text('Nenhum produto adicionado.'));
              }
              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final produto = box.getAt(index)!;
                  return Dismissible(
                    key: Key(box.keys.toString()),
                    background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.delete, color: Colors.white)),
                    secondaryBackground: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (_) => {box.deleteAt(index), setState(() {})},
                    child: ListTile(
                      textColor: Color.fromARGB(255, 150, 23, 175),
                      title: Text(produto.nome),
                      subtitle: Text("${produto.quantidade}un x  R\$ ${produto.preco.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: Icon(Icons.edit, color: Color.fromARGB(255, 150, 23, 175)),
                        onPressed: () => adicionarProduto(produto),
                      ),
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
        splashColor: Color.fromARGB(255, 150, 23, 175),
        backgroundColor: Color.fromARGB(255, 236, 214, 240),
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 236, 214, 240),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: R\$ ${total.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 150, 23, 175)),
          ),
        ),
      ),
    );
  }
}