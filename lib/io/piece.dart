import 'dart:typed_data';
import 'serialization.dart';
import 'costume.dart';

class Piece extends Serializable {
  String name;
  String description;
  Uint8List image;
  Costume parent;
  bool expanded = false;

  Piece({this.name, this.description, this.image, this.parent});

  Piece.clone(Piece old) {
    name = old.name;
    description = old.description;
    image = old.image;
    parent = old.parent;
  }

  @override
  void serialize(RepSink out) {
    SName(name).serialize(out);
    SBigString(description).serialize(out);
    SInt(image.length, 4).serialize(out);
    out.add(image);
  }

  static Piece deserialize(ByteScanner input, Costume parent) {
    Piece result = Piece(parent: parent);
    result.name = SName.deserialize(input);
    result.description = SBigString.deserialize(input);
    int imageLength = SInt.deserialize(input, 4);
    result.image = Uint8List.fromList(input.popRange(imageLength));
    return result;
  }
  @override
  String toString() {
    return 'Piece{$name, "$description", ${image.length}B Image}';
  }
}
