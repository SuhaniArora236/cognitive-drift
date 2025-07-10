// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thought_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThoughtLogAdapter extends TypeAdapter<ThoughtLog> {
  @override
  final int typeId = 0;

  @override
  ThoughtLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThoughtLog(
      trigger: fields[0] as String,
      automaticThought: fields[1] as String,
      distortionType: fields[2] as String,
      emotion: fields[3] as String,
      intensity: fields[4] as int,
      reframe: fields[5] as String?,
      dateLogged: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ThoughtLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.trigger)
      ..writeByte(1)
      ..write(obj.automaticThought)
      ..writeByte(2)
      ..write(obj.distortionType)
      ..writeByte(3)
      ..write(obj.emotion)
      ..writeByte(4)
      ..write(obj.intensity)
      ..writeByte(5)
      ..write(obj.reframe)
      ..writeByte(6)
      ..write(obj.dateLogged);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThoughtLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
