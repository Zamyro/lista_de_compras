import 'package:duck_it/models/produto.dart';
import 'package:duck_it/widget/scanner_screen.dart';
import 'package:flutter/material.dart';


class CadastroProdutoScreen extends StatefulWidget {
  @override
  _CadastroProdutoScreenState createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final TextEditingController _nomeProdutoController = TextEditingController();
  
  List<Map<String, TextEditingController>> _marcasControllers = [];

  @override
  void initState() {
    super.initState();
    _adicionarNovaMarca();
  }

  void _adicionarNovaMarca() {
    setState(() {
      _marcasControllers.add({
        'nome': TextEditingController(),
        'codigo': TextEditingController(),
      });
    });
  }

  void _removerMarca(int index) {
    setState(() {
      _marcasControllers.removeAt(index);
    });
  }

  void _salvarProduto() {
    List<Marca> marcasParaSalvar = _marcasControllers.map((m) {
      return Marca(
        nome: m['nome']!.text,
        codigoBarras: m['codigo']!.text,
      );
    }).toList();

    final novoProduto = Produto(
      nome: _nomeProdutoController.text,
      preco: 0.0,
      quantidade: 1,
      marcas: marcasParaSalvar,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Novo Produto")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeProdutoController,
              decoration: InputDecoration(labelText: "Nome do Produto (Ex: Creme de Leite)"),
            ),
            SizedBox(height: 20),
            Text("Marcas e Códigos", style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(),
            
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _marcasControllers.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Marca ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerMarca(index),
                              tooltip: 'Remover esta marca',
                            )
                          ],
                        ),
                        TextField(
                          controller: _marcasControllers[index]['nome'],
                          decoration: InputDecoration(
                            labelText: "Nome da Marca",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _marcasControllers[index]['codigo'],
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "Código de Barras",
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  hintText: "Digite ou scaneie ->"
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Ink(
                              decoration: ShapeDecoration(
                                color: Colors.pinkAccent,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.qr_code_scanner, color: Colors.white),
                                iconSize: 30,
                                tooltip: 'Escanear código de barras',
                                onPressed: () async {
                                  final String? codigoLido = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ScannerScreen()),
                                  );

                                  if (codigoLido != null && codigoLido.isNotEmpty) {
                                    setState(() {
                                      _marcasControllers[index]['codigo']!.text = codigoLido;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Codigo lido: $codigoLido'))
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            TextButton.icon(
              onPressed: _adicionarNovaMarca,
              icon: Icon(Icons.add),
              label: Text("Adicionar outra marca"),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvarProduto,
              child: Text("Salvar Produto"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}