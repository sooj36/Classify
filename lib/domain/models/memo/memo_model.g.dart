// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoModelAdapter extends TypeAdapter<MemoModel> {
  @override
  final int typeId = 1;

  @override
  MemoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoModel(
      title: fields[1] as String,
      content: fields[2] as String,
      isImportant: fields[3] as bool,
      tags: (fields[4] as List?)?.cast<String>(),
      lastModified: fields[5] as DateTime?,
      createdAt: fields[0] as DateTime?,
      category: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MemoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.isImportant)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.lastModified)
      ..writeByte(6)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
