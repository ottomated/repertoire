import 'dancer_list.dart';
import 'dancer.dart';
import 'dance.dart';
import 'serialization.dart';

class PartnerDancerList extends DancerList {
  List<Couple> couples;
  static final int id = 1;
  int get length => couples.length == 0 ? 0 : couples.map((c) => c.length).reduce((a, b) => a + b);
  Dance parent;

  PartnerDancerList({this.couples, this.parent});
  PartnerDancerList.clone(PartnerDancerList old) {
    parent = old.parent;
    couples = List<Couple>()..length = old.couples.length;
    for (int i = 0; i < old.couples.length; i++) {
      couples[i] = Couple(Dancer.clone(old.couples[i].first),
          Dancer.clone(old.couples[i].second));
    }
  }

  @override
  bool contains(Dancer dancer) {
    return couples.any((t) => t.contains(dancer));
  }

  serialize(RepSink out) {
    out.add([id]);
    SInt(couples.length, 1).serialize(out);
    couples.forEach((c) {
      if (c.first == null)
        out.add([0]);
      else
        c.first.serialize(out);
      if (c.second == null)
        out.add([0]);
      else
        c.second.serialize(out);
    });
  }

  static PartnerDancerList deserialize(ByteScanner input, Dance parent) {
    int length = input.pop();
    var result = PartnerDancerList(
      couples: List()..length = length,
      parent: parent,
    );
    for (int i = 0; i < length; i++) {
      var c = Couple.empty();
      int first = input.peek();
      if (first == 0)
        input.pop();
      else
        c.first = Dancer.deserialize(input);
      int second = input.peek();
      if (second == 0)
        input.pop();
      else
        c.second = Dancer.deserialize(input);
      result.couples[i] = c;
    }
    return result;
  }

  @override
  String toString() {
    return couples.toString();
  }
}

class Couple {
  Dancer first;
  Dancer second;
  Couple.empty({this.first, this.second});
  Couple(this.first, this.second);

  bool contains(Dancer other) {
    return first == other || second == other;
  }

  bool get empty => first == null && second == null;

  int get length => (first == null ? 0 : 1) + (second == null ? 0 : 1);

  @override
  String toString() {
    return '($first $second)';
  }
}
