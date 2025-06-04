// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 2;

  @override
  TodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoModel(
      todoContent: fields[1] as String,
      isImportant: fields[2] as bool?,
      isveryImportant: fields[3] as bool?,
      lastModified: fields[4] as DateTime?,
      createdAt: fields[0] as DateTime?,
      isDone: fields[5] as bool?,
      todoId: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.createdAt)
      ..writeByte(1)
      ..write(obj.todoContent)
      ..writeByte(2)
      ..write(obj.isImportant)
      ..writeByte(3)
      ..write(obj.isveryImportant)
      ..writeByte(4)
      ..write(obj.lastModified)
      ..writeByte(5)
      ..write(obj.isDone)
      ..writeByte(6)
      ..write(obj.todoId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
