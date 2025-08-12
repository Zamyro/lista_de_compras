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
  await Hive.openBox<String>('listas');
  
  var listasBox = Hive.box<String>('listas');
  if (listasBox.isEmpty) listasBox.add("Lista Principal");
  for (var nome in listasBox.values) {
    await Hive.openBox<Produto>('produtos_$nome');
  }
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
  final _formKey = GlobalKey<FormState>();
  String nome = '';
  int quantidade = 1;
  double preco = 0.0;
  String? listaAtual;
  Box<Produto>? produtosBox;

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

  @override
  void initState() {
    super.initState();
    abrirBoxes();
  }

  Future<void> abrirBoxes() async {
    var listasBox = Hive.box<String>('listas');
    listaAtual = listasBox.values.first;

    await Hive.openBox<Produto>('produtos_$listaAtual');
    produtosBox = Hive.box<Produto>('produtos_$listaAtual');

    setState(() {});
  }
  
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

    if (listasBox.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não pode apagar a última lista!')),
      );
      return;
    }

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
          content: const Text('Você tem certeza que deseja limpar a lista de compras?'),
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
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
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
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double total = produtosBox!.values.fold(
      0.0, (sum, p) => sum + p.preco * p.quantidade);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 236, 214, 240),
        title: Text(
          listaAtual ?? 'Lista de Compras',
          style: const TextStyle(color: Color.fromARGB(255, 150, 23, 175)),
        ),
        actions: [
          IconButton(
            color: const Color.fromARGB(255, 150, 23, 175),
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: gerarPDF,
          ),
          IconButton(
            color: const Color.fromARGB(255, 150, 23, 175),
            icon: const Icon(Icons.delete_forever),
            onPressed: _confirmarLimpeza,
          ),
        ],
      ),
      drawer: Drawer(
        width: 250,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 236, 214, 240)),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 150, 23, 175)),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Adicionar nova lista",
                      style: TextStyle(color: Colors.white)),
                  onPressed: adicionarLista,
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<String>('listas').listenable(),
                builder: (context, Box<String> listasBox, _) {
                  return ListView.builder(
                    itemCount: listasBox.length,
                    itemBuilder: (context, index) {
                      String nomeLista = listasBox.getAt(index)!;
                      return ListTile(
                        title: Text(nomeLista),
                        onTap: () {
                          setState(() {
                            listaAtual = nomeLista;
                          });
                          Navigator.pop(context);
                        },
                        trailing: IconButton(
                          color: const Color.fromARGB(255, 211, 156, 223),
                          icon: const Icon(Icons.delete),
                          onPressed: () => confirmarApagarLista(nomeLista),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
                    onDismissed: (_) =>
                        {box.deleteAt(index), setState(() {})},
                    child: ListTile(
                      textColor: const Color.fromARGB(255, 150, 23, 175),
                      title: Text(produto.nome),
                      subtitle: Text(
                          "${produto.quantidade}un x  R\$ ${produto.preco.toStringAsFixed(2)}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Color.fromARGB(255, 150, 23, 175)),
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
        splashColor: const Color.fromARGB(255, 150, 23, 175),
        backgroundColor: const Color.fromARGB(255, 236, 214, 240),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 236, 214, 240),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: R\$ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 150, 23, 175)),
          ),
        ),
      ),
    );
  }
}