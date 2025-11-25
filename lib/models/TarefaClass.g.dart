// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TarefaClass.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TarefaAdapter extends TypeAdapter<Tarefa> {
  @override
  final int typeId = 2;

  @override
  Tarefa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Tarefa(
      id: fields[0] as int,
      titulo: fields[1] as String,
      concluida: fields[2] as bool,
      momentoCadastro: fields[3] as String,
      dataAlarme: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Tarefa obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.titulo)
      ..writeByte(2)
      ..write(obj.concluida)
      ..writeByte(3)
      ..write(obj.momentoCadastro)
      ..writeByte(4)
      ..write(obj.dataAlarme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TarefaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
