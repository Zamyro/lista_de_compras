import 'package:flutter/material.dart';

final GlobalKey receiptKey = GlobalKey(); 

String calcularTotal(List<dynamic> produtos) {
  final total = produtos.fold<double>(
    0.0,
    (previousValue, p) => previousValue + (p.preco * p.quantidade),
  );

  return total.toStringAsFixed(2);
}

Widget buildReceiptUI(String? titulo, List<dynamic> produtos) {
  return RepaintBoundary(
    key: receiptKey,
    child: Container(
      width: 300,
      padding: const EdgeInsets.all(15),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo ?? "LISTA DE COMPRAS", 
               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Text("--------------------------------", style: TextStyle(letterSpacing: 2)),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("ITEM", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.black),

          for (var p in produtos)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text("${p.quantidade}x ${p.nome}")),
                  Text("R\$ ${(p.preco * p.quantidade).toStringAsFixed(2)}"),
                ],
              ),
            ),

          const Divider(color: Colors.black),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("TOTAL:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("R\$ ${calcularTotal(produtos)}", 
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          
          const SizedBox(height: 20),
          Text("Emitido em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
          const Text("Obrigado e volte sempre!"),
        ],
      ),
    ),
  );
}