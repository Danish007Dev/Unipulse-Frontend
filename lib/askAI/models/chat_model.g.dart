// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 4;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      text: fields[0] as String,
      type: fields[1] as ChatMessageType,
      isBookmarked: fields[2] as bool,
      originalQuestion: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.isBookmarked)
      ..writeByte(3)
      ..write(obj.originalQuestion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChatMessageTypeAdapter extends TypeAdapter<ChatMessageType> {
  @override
  final int typeId = 3;

  @override
  ChatMessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChatMessageType.user;
      case 1:
        return ChatMessageType.bot;
      case 2:
        return ChatMessageType.error;
      default:
        return ChatMessageType.user;
    }
  }

  @override
  void write(BinaryWriter writer, ChatMessageType obj) {
    switch (obj) {
      case ChatMessageType.user:
        writer.writeByte(0);
        break;
      case ChatMessageType.bot:
        writer.writeByte(1);
        break;
      case ChatMessageType.error:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
