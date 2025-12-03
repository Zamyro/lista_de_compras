import 'package:flutter/material.dart';
import 'package:duck_it/adicionar_receita_page.dart';
import 'package:duck_it/widget/gerar_pdf_receita.dart';
import 'package:duck_it/models/receitas.dart';
import 'package:duck_it/models/ingredientes.dart';
import 'package:duck_it/widget/gerar_texto_receita.dart';

class ReceitaDetalhesPage extends StatelessWidget {
  final Receita receita;

  const ReceitaDetalhesPage({super.key, required this.receita});

  void mostrarOpcoesDeCompartilhamento(BuildContext context, Receita receita) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Como deseja compartilhar?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 📄 PDF
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text("Exportar como PDF"),
                onTap: () {
                  Navigator.pop(context);
                  gerarPdfReceita(receita);
                },
              ),

              // 📝 Texto
              ListTile(
                leading: const Icon(Icons.text_snippet, color: Colors.blue),
                title: const Text("Compartilhar como Texto"),
                onTap: () {
                  Navigator.pop(context);
                  compartilharComoTexto(receita);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          receita.nome,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orangeAccent.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => mostrarOpcoesDeCompartilhamento(context, receita),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdicionarReceitaPage(receita: receita),
                ),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===== Ingredientes =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Ingredientes",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...receita.ingredientes.map(
                    (Ingrediente ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Text("• ",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              '${ing.quantidade} ${ing.nome}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Modo de Preparo =====
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Modo de preparo",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    receita.preparo,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
