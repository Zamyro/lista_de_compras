import 'package:hive/hive.dart';

part 'produto.g.dart';

@HiveType(typeId: 0)
class Produto {
  @HiveField(0)
  String nome;
  
  @HiveField(1)
  double preco;
  
  @HiveField(2)
  int quantidade;

  Produto({
    required this.nome,
    required this.preco,
    required this.quantidade
  });
}
