import 'package:duck_it/models/produto.dart';
import 'package:hive/hive.dart';

part 'item_lista_compras.g.dart';

@HiveType(typeId: 1)
class ItemLista extends HiveObject{
  @HiveField(0)
  Produto produto;

  @HiveField(1)
  int quantidade;

  @HiveField(2)
  double precoPago;

  @HiveField(4)
  DateTime data;

  ItemLista({
    required this.produto,
    this.quantidade = 1,
    this.precoPago = 0,
    DateTime? data,
  }) : data = data ?? DateTime.now();
}
