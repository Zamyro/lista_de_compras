import 'package:hive/hive.dart';
import 'package:lista_de_compras/models/ingredientes.dart';

part 'receitas.g.dart';

@HiveType(typeId: 3)
class Receita {
  @HiveField(0)
  String nome;

  @HiveField(1)
  List<Ingrediente> ingredientes;

  @HiveField(2)
  String preparo;

  Receita({
    required this.nome,
    required this.ingredientes,
    required this.preparo,
  });
}