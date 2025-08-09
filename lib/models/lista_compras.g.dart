// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lista_compras.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListaComprasAdapter extends TypeAdapter<ListaCompras> {
  @override
  final int typeId = 0;

  @override
  ListaCompras read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ListaCompras(
      nome: fields[0] as String,
      produtos: (fields[1] as List).cast<Produto>(),
    );
  }

  @override
  void write(BinaryWriter writer, ListaCompras obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.produtos);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListaComprasAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
