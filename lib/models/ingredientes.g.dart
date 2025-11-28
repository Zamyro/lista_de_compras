// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredientes.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredienteAdapter extends TypeAdapter<Ingrediente> {
  @override
  final int typeId = 4;

  @override
  Ingrediente read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ingrediente(
      nome: fields[0] as String,
      quantidade: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Ingrediente obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.quantidade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredienteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
