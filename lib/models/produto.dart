import 'package:hive/hive.dart';

part 'produto.g.dart';

@HiveType(typeId: 5)
class Marca {
  @HiveField(1)
  String nome;

  @HiveField(2)
  String codigoBarras;

  Marca({required this.nome, required this.codigoBarras});
}

@HiveType(typeId: 0)
class Produto extends HiveObject{
  @HiveField(0)
  String nome;
  
  @HiveField(1)
  double preco;
  
  @HiveField(2)
  int quantidade;

  @HiveField(3)
  List<Marca>? marcas;

  Produto({
    required this.nome,
    required this.preco,
    required this.quantidade,
    this.marcas
  });
}
