import 'dancer.dart';
import 'serialization.dart';
import 'single_dancer_list.dart';
import 'partner_dancer_list.dart';
import 'dance.dart';

abstract class DancerList implements Serializable {
  bool contains(Dancer dancer);
  Dance parent;
  int get length;
  static final List<Function> ids = [SingleDancerList.deserialize, PartnerDancerList.deserialize];

  DancerList.clone(DancerList old);
  DancerList();

  static DancerList deserialize(ByteScanner input, Dance parent) {
    int id = input.pop();
    return ids[id](input, parent);
  }
}
