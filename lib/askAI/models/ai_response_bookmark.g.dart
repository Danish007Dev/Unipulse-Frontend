// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_response_bookmark.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AiResponseBookmarkAdapter extends TypeAdapter<AiResponseBookmark> {
  @override
  final int typeId = 2;

  @override
  AiResponseBookmark read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AiResponseBookmark(
      id: fields[0] as int,
      question: fields[1] as String,
      answer: fields[2] as String,
      createdAt: fields[3] as DateTime,
      originalArticle: fields[4] as Article,
    );
  }

  @override
  void write(BinaryWriter writer, AiResponseBookmark obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.originalArticle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiResponseBookmarkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
