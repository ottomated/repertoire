import 'serialization.dart';

class Dancer extends Serializable {
  String name;
  String description;
  DancerPart part;
  Dancer({this.name, this.description, this.part});
  static Dancer clone(Dancer old) {
    if (old == null) return null;
    Dancer n = Dancer();
    n.name = old.name;
    n.description = old.description;
    n.part = old.part;
    return n;
  }
  @override
  serialize(RepSink out) {
    SName(name).serialize(out);
    SBigString(description).serialize(out);
    SInt(part.index, 1).serialize(out);
  }

  static Dancer deserialize(ByteScanner input) {
    var result = Dancer();
    result.name = SName.deserialize(input);
    result.description = SBigString.deserialize(input);
    result.part = DancerPart.values[SInt.deserialize(input, 1)];
    return result;
  }

  bool operator ==(Object other) {
    return other is Dancer && this.name == other.name;
  }

  @override
  int get hashCode => this.name.hashCode;
  @override
  String toString() {
    return 'Dancer{$name, "$description", ${part.toString().split('.')[1]}}';
  }
}

enum DancerPart { lead, follow, any }
