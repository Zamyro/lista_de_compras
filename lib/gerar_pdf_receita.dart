import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'models/receitas.dart';

Future<void> gerarPdfReceita(Receita receita) async {
  final pdf = pw.Document();

  final date = DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now());

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                receita.nome,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1),
            pw.SizedBox(height: 16),

            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.grey300),
                color: PdfColors.grey100,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Ingredientes',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  if (receita.ingredientes.isEmpty)
                    pw.Text('Nenhum ingrediente listado.', style: pw.TextStyle(fontSize: 12))
                  else
                    ...receita.ingredientes.map((ing) {
                      final quantidade = ing.quantidade.toString();
                      // final unidade = ing.quantidade.toString().isNotEmpty ? ' ${ing.quantidade}' : '';
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 2),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('> ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                            pw.Expanded(
                              child: pw.Text(
                                quantidade.isNotEmpty
                                    ? '$quantidade ${ing.nome}'
                                    : ing.nome,
                                style: pw.TextStyle(fontSize: 13, height: 1.3),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),

            pw.SizedBox(height: 22),

            pw.Text(
              'Modo de Preparo',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.lightBlue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                receita.preparo.isNotEmpty ? receita.preparo : 'Modo de preparo não informado.',
                style: pw.TextStyle(fontSize: 13, height: 1.45),
              ),
            ),

            pw.Spacer(),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Receita gerada pelo MyApp', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Text('Gerado em $date', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf.save());
}
