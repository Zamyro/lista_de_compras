import 'package:share_plus/share_plus.dart';
import '../models/receitas.dart';

void compartilharComoTexto(Receita receita) {
  final texto = StringBuffer()
    ..writeln("📘 ${receita.nome}\n")
    ..writeln("🍽 Ingredientes:")
    ..writeAll(
      receita.ingredientes.map(
        (i) => "• ${i.quantidade} de ${i.nome}\n",
      ),
    )
    ..writeln("\n👨‍🍳 Modo de Preparo:\n${receita.preparo}");

  Share.share(texto.toString());
}
