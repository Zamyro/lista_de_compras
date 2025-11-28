// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuracao.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfiguracaoAdapter extends TypeAdapter<Configuracao> {
  @override
  final int typeId = 2;

  @override
  Configuracao read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Configuracao(
      temaEscuro: fields[0] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Configuracao obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.temaEscuro);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfiguracaoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
