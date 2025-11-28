import 'package:hive/hive.dart';

part 'ingredientes.g.dart';

@HiveType(typeId: 4)
class Ingrediente {
  @HiveField(0)
  String nome;

  @HiveField(1)
  String quantidade;

  Ingrediente({
    required this.nome,
    required this.quantidade,
  });
}
