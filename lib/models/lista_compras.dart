import 'package:hive/hive.dart';
import 'produto.dart';

part 'lista_compras.g.dart';

@HiveType(typeId: 1)
class ListaCompras extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  List<Produto> produtos;

  ListaCompras({
    required this.nome,
    required this.produtos,
  });
  
}