import 'package:flutter/material.dart';
import '../models/produto.dart';

class ProdutoDetalhesPage extends StatelessWidget {
  final Produto produto;

  const ProdutoDetalhesPage({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Produto"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com Nome do Produto
            Text(
              "Produto:",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              produto.nome,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            const Text(
              "Marcas e Códigos cadastrados:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            
            // Lista de Marcas
            if (produto.marcas == null || produto.marcas!.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text("Nenhuma marca cadastrada para este produto."),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: produto.marcas!.length,
                itemBuilder: (context, index) {
                  final marca = produto.marcas![index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.label, color: Colors.blue),
                      title: Text(
                        marca.nome.isEmpty ? "Marca não informada" : marca.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.qr_code, size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                marca.codigoBarras.isEmpty 
                                  ? "Sem código" 
                                  : marca.codigoBarras,
                                style: TextStyle(fontFamily: 'Courier', fontSize: 15, color: Colors.blueGrey[700]),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          // Opcional: Copiar código de barras para o clipboard
                        },
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}