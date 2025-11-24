// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NotaClass.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotaAdapter extends TypeAdapter<Nota> {
  @override
  final int typeId = 1;

  @override
  Nota read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nota(
      titulo: fields[0] as String,
      texto: fields[1] as String,
      momentoCadastro: fields[2] as String,
      imageBytes: fields[3] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, Nota obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.titulo)
      ..writeByte(1)
      ..write(obj.texto)
      ..writeByte(2)
      ..write(obj.momentoCadastro)
      ..writeByte(3)
      ..write(obj.imageBytes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
