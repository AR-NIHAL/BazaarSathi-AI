// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bazaar_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BazaarItemAdapter extends TypeAdapter<BazaarItem> {
  @override
  final int typeId = 0;

  @override
  BazaarItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BazaarItem(
      id: fields[0] as String,
      itemName: fields[1] as String,
      quantity: fields[2] as String,
      category: fields[3] as String,
      isChecked: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BazaarItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.itemName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BazaarItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
