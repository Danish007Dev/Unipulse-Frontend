// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_history_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatHistorySessionAdapter extends TypeAdapter<ChatHistorySession> {
  @override
  final int typeId = 5;

  @override
  ChatHistorySession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatHistorySession(
      article: fields[1] as Article,
      messages: (fields[2] as List).cast<ChatMessage>(),
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
    )..id = fields[0] as String;
  }

  @override
  void write(BinaryWriter writer, ChatHistorySession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.article)
      ..writeByte(2)
      ..write(obj.messages)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatHistorySessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
