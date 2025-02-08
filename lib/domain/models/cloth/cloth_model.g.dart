// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cloth_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothModelAdapter extends TypeAdapter<ClothModel> {
  @override
  final int typeId = 0;

  @override
  ClothModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClothModel(
      id: fields[0] as String?,
      file: fields[10] as XFile?,
      response: fields[2] as String?,
      major: fields[3] as String?,
      minor: fields[4] as String?,
      color: fields[5] as String?,
      material: fields[6] as String?,
      season: fields[7] as String?,
      localImagePath: fields[8] as String?,
      remoteImagePath: fields[9] as String?,
      createdAt: fields[1] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ClothModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.response)
      ..writeByte(3)
      ..write(obj.major)
      ..writeByte(4)
      ..write(obj.minor)
      ..writeByte(5)
      ..write(obj.color)
      ..writeByte(6)
      ..write(obj.material)
      ..writeByte(7)
      ..write(obj.season)
      ..writeByte(8)
      ..write(obj.localImagePath)
      ..writeByte(9)
      ..write(obj.remoteImagePath)
      ..writeByte(10)
      ..write(obj.file);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
