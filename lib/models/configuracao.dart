import 'package:hive/hive.dart';

part 'configuracao.g.dart';

@HiveType(typeId: 2)
class Configuracao {
  static const String boxName = 'configuracao';

  @HiveField(0)
  bool temaEscuro;

  Configuracao({
    required this.temaEscuro
  });
}