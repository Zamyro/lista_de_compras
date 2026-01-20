// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_lista_compras.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemListaAdapter extends TypeAdapter<ItemLista> {
  @override
  final int typeId = 1;

  @override
  ItemLista read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemLista(
      produto: fields[0] as Produto,
      quantidade: fields[1] as int,
      precoPago: fields[2] as double,
      data: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemLista obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.produto)
      ..writeByte(1)
      ..write(obj.quantidade)
      ..writeByte(2)
      ..write(obj.precoPago)
      ..writeByte(4)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemListaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
