import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:duck_it/widget/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import 'package:duck_it/models/produto.dart';
import 'package:duck_it/widget/campo_preco_widget.dart';
import 'package:duck_it/widget/receipt_widget.dart';

class ListaComprasPage extends StatefulWidget {
  final String listaNome;

  const ListaComprasPage({
    super.key,
    required this.listaNome,
  });

  @override
  State<ListaComprasPage> createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey receiptKey = GlobalKey();

  Box<Produto>? produtosBox;

  String nome = '';
  int quantidade = 1;
  double preco = 0.0;

  final frases = [
    'O Senhor é meu pastor; nada me faltará. - Salmos 23:1',
    'Confia no Senhor de todo o teu coração. - Provérbios 3:5',
    'Tudo posso naquele que me fortalece. - Filipenses 4:13',
  ];

  @override
  void initState() {
    super.initState();
    _abrirBox();
  }

  Future<void> _abrirBox() async {
    final boxName = 'produtos_${widget.listaNome}';
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Produto>(boxName);
    }
    produtosBox = Hive.box<Produto>(boxName);
    setState(() {});
  }

  /* ================ BUSCA DE PRODUTOS ================ */

  Produto? buscarProdutoPorCodigo(String codigo) {
      if (produtosBox == null) return null;

      for (final produto in produtosBox!.values) {
        final encontrou = produto.marcas?.any(
          (m) => m.codigoBarras == codigo,
        );

        if (encontrou == true) {
          return produto;
        }
      }
      return null;
  }


  /* ===================== PRODUTOS ===================== */

  void adicionarOuEditarProduto([Produto? produto]) {
    if (produtosBox == null) return;

    String? codigoLido;

    if (produto != null) {
      nome = produto.nome;
      quantidade = produto.quantidade;
      preco = produto.preco;
    } else {
      nome = '';
      quantidade = 1;
      preco = 0.0;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(produto == null ? 'Adicionar Produto' : 'Editar Produto'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Buscar por código de barras'),
                  onPressed: () async {
                    final codigo = await Navigator.push<String?>(
                      context,
                      MaterialPageRoute(builder: (_) => ScannerScreen()),
                    );

                    if (codigo == null || codigo.isEmpty) return;

                    final produtoEncontrado = buscarProdutoPorCodigo(codigo);

                    if (produtoEncontrado != null) {
                      setState(() {
                        nome = produtoEncontrado.nome;
                        quantidade = 1;
                        preco = produtoEncontrado.preco;
                        codigoLido = codigo;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Produto encontrado: ${produtoEncontrado.nome}',
                          ),
                        ),
                      );
                    } else {
                      codigoLido = codigo;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Produto não encontrado. Informe o nome manualmente.',
                          ),
                        ),
                      );
                    }
                  },
                ),
                TextFormField(
                  initialValue: nome,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o nome' : null,
                  onSaved: (v) => nome = v!,
                ),
                TextFormField(
                  initialValue: quantidade.toString(),
                  decoration: const InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a quantidade' : null,
                  onSaved: (v) =>
                      quantidade = int.tryParse(v!) ?? 1,
                ),
                CampoPreco(
                  valorInicial: produto?.preco,
                  onSaved: (v) => preco = v,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              _formKey.currentState!.save();

              if (produto == null) {
                produtosBox!.add(
                  Produto(
                    nome: nome,
                    quantidade: quantidade,
                    preco: preco,
                    marcas: [],
                  ),
                );
              } else {
                produto
                  ..nome = nome
                  ..quantidade = quantidade
                  ..preco = preco;
                produto.save();
              }

              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void limparLista() async {
    await produtosBox?.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lista limpa')),
    );
  }

  /* ===================== PDF ===================== */

  void gerarPDF() async {
    final pdf = pw.Document();
    final frase = frases[Random().nextInt(frases.length)];

    pdf.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                widget.listaNome,
                style: pw.TextStyle(
                    fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 5),
            pw.Center(child: pw.Text(frase)),
            pw.Divider(),
            ...produtosBox!.values.map(
              (p) => pw.Text(
                '${p.quantidade}x ${p.nome} - R\$ ${(p.preco * p.quantidade).toStringAsFixed(2)}',
              ),
            ),
            pw.Divider(),
            pw.Text(
              'Total: R\$ ${_total().toStringAsFixed(2)}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  /* ===================== PNG ===================== */

  Future<void> salvarPNG() async {
    try {
      final boundary =
          receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file =
          File('${dir.path}/recibo_${widget.listaNome}.png');

      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Recibo da lista ${widget.listaNome}',
      );
    } catch (e) {
      debugPrint('Erro ao salvar PNG: $e');
    }
  }

  double _total() {
    return produtosBox!.values.fold(
      0,
      (sum, p) => sum + p.preco * p.quantidade,
    );
  }

  /* ===================== UI ===================== */

  @override
  Widget build(BuildContext context) {
    if (produtosBox == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listaNome),
        backgroundColor: Colors.pinkAccent.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: gerarPDF,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: salvarPNG,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: limparLista,
          ),
        ],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: produtosBox!.listenable(),
            builder: (_, Box<Produto> box, __) {
              if (box.isEmpty) {
                return const Center(
                  child: Text('Nenhum produto adicionado'),
                );
              }

              return ListView.builder(
                itemCount: box.length,
                itemBuilder: (_, i) {
                  final produto = box.getAt(i)!;
                  return Dismissible(
                    key: Key('${produto.nome}-$i'),
                    background: Container(color: Colors.red),
                    onDismissed: (_) => produto.delete(),
                    child: ListTile(
                      title: Text(produto.nome),
                      subtitle: Text(
                        '${produto.quantidade}x R\$ ${produto.preco.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        'R\$ ${(produto.preco * produto.quantidade).toStringAsFixed(2)}',
                      ),
                      onTap: () => adicionarOuEditarProduto(produto),
                    ),
                  );
                },
              );
            },
          ),

          /// Recibo invisível para PNG
          Transform.translate(
            offset: const Offset(-2000, -2000),
            child: RepaintBoundary(
              key: receiptKey,
              child: buildReceiptUI(
                widget.listaNome,
                produtosBox!.values.toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent.shade100,
        onPressed: () => adicionarOuEditarProduto(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.pinkAccent.shade100,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Total: R\$ ${_total().toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
