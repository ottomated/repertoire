import 'piece.dart';
import 'dancer.dart';
import 'serialization.dart';
import 'dance.dart';

class Costume extends Serializable {
  String name;
  String description;
  DancerPart dancerPart;
  List<Piece> pieces;
  Dance parent;

  Costume(
      {this.name, this.description, this.pieces, this.dancerPart, this.parent});

  Costume.clone(Costume old) {
    name = old.name;
    description = old.description;
    pieces = old.pieces.map((p) => Piece.clone(p)).toList();
    dancerPart = old.dancerPart;
    parent = old.parent;
  }

  @override
  void serialize(RepSink out) {
    SName(name).serialize(out);
    SBigString(description).serialize(out);
    SInt(dancerPart.index, 1).serialize(out);
    SInt(pieces.length, 1).serialize(out);
    pieces.forEach((p) => p.serialize(out));
  }

  static Costume deserialize(ByteScanner input, Dance parent) {
    Costume result = Costume(parent: parent);
    result.name = SName.deserialize(input);
    result.description = SBigString.deserialize(input);
    result.dancerPart = DancerPart.values[SInt.deserialize(input, 1)];

    int pieceLength = SInt.deserialize(input, 1);
    result.pieces = List(pieceLength);
    for (int i = 0; i < pieceLength; i++) {
      result.pieces[i] = Piece.deserialize(input, result);
    }
    return result;
  }

  @override
  String toString() {
    return 'Costume{$name, "$description", ${dancerPart.toString().split('.')[1]}, $pieces}';
  }
}
