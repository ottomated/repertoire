import 'dancer_list.dart';
import 'dancer.dart';
import 'serialization.dart';
import 'dance.dart';

class SingleDancerList extends DancerList {
  List<Dancer> dancers = [];
  static final int id = 0;
  Dance parent;

  SingleDancerList({this.dancers, this.parent});

  SingleDancerList.clone(SingleDancerList old) {
    parent = old.parent;
    dancers = List<Dancer>()..length = old.dancers.length;
    for (int i = 0; i < old.dancers.length; i++) {
      dancers[i] = Dancer.clone(old.dancers[i]);
    }
  }

  int get length => dancers.length;

  @override
  bool contains(Dancer dancer) {
    return dancers.contains(dancer);
  }

  @override
  serialize(RepSink out) {
    out.add([id]);
    SInt(dancers.length, 1).serialize(out);
    dancers.forEach((d) => d.serialize(out));
  }

  static SingleDancerList deserialize(ByteScanner input, Dance parent) {
    int length = input.pop();
    var result = SingleDancerList(
      dancers: List()..length = length,
      parent: parent,
    );
    for (int i = 0; i < length; i++) {
      result.dancers[i] = Dancer.deserialize(input);
    }
    return result;
  }

  @override
  String toString() {
    return dancers.toString();
  }
}
