import 'dart:math';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import './models/produto.dart';

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

Future<void> gerarCupomFiscalPDF(List<Produto> produtos) async {
  final pdf = pw.Document();
  final frase = frasesPatos[Random().nextInt(frasesPatos.length)];
  final now = DateTime.now();
  double total = produtos.fold(0, (sum, p) => sum + p.preco * p.quantidade);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(58 * PdfPageFormat.mm, double.infinity),
      margin: const pw.EdgeInsets.all(4),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'SUA LISTA DE COMPRAS',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
              ),
            ),
            pw.Center(child: pw.Text(frase, style: pw.TextStyle(fontSize: 8))),
            pw.Divider(),
            pw.Text('Data/Hora: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2,'0')}', style: pw.TextStyle(fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.Text('CUPOM NÃO FISCAL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            ...produtos.map((p) => pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(child: pw.Text(p.nome, style: pw.TextStyle(fontSize: 8))),
                pw.Text('${p.quantidade} x ${p.preco.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 8)),
                pw.Text(' = R\$ ${(p.quantidade * p.preco).toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 8)),
              ],
            )),
            pw.Divider(),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('TOTAL: R\$ ${total.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            pw.Divider(),
            pw.Center(child: pw.Text('OBRIGADO PELA PREFERÊNCIA!', style: pw.TextStyle(fontSize: 8))),
            pw.Center(child: pw.Text('ESTE DOCUMENTO NÃO É FISCAL', style: pw.TextStyle(fontSize: 8))),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
}
