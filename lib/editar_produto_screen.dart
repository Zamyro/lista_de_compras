import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/produto.dart';
import '../widget/scanner_screen.dart';

class EditarProdutoScreen extends StatefulWidget {
  final Produto produto;

  const EditarProdutoScreen({Key? key, required this.produto}) : super(key: key);

  @override
  State<EditarProdutoScreen> createState() => _EditarProdutoScreenState();
}

class _EditarProdutoScreenState extends State<EditarProdutoScreen> {
  late List<Map<String, TextEditingController>> _marcasControllers;

  @override
  void initState() {
    super.initState();

    _marcasControllers = widget.produto.marcas!.map((marca) {
      return {
        'nome': TextEditingController(text: marca.nome),
        'codigo': TextEditingController(text: marca.codigoBarras),
      };
    }).toList();
  }

  void _adicionarMarca() {
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

  void _salvarAlteracoes() {
    widget.produto.marcas = _marcasControllers.map((m) {
      return Marca(
        nome: m['nome']!.text,
        codigoBarras: m['codigo']!.text,
      );
    }).toList();

    widget.produto.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marcas atualizadas com sucesso')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (var m in _marcasControllers) {
      m['nome']?.dispose();
      m['codigo']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar ${widget.produto.nome}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _marcasControllers.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Marca ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerMarca(index),
                            )
                          ],
                        ),
                        TextField(
                          controller: _marcasControllers[index]['nome'],
                          decoration: const InputDecoration(labelText: 'Nome da Marca'),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _marcasControllers[index]['codigo'],
                                decoration: const InputDecoration(
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
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: _adicionarMarca,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar nova marca'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _salvarAlteracoes,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }
}
