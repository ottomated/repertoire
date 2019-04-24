import 'dancer_list.dart';
import 'single_dancer_list.dart';
import 'costume.dart';
import 'song.dart';
import 'serialization.dart';
import 'repertoire.dart';

class Dance {
  String name;
  String description;
  DancerList dancers;
  List<Costume> costumes;
  Song song;
  Repertoire parent;

  Dance(
      {this.name,
      this.description,
      this.dancers,
      this.costumes,
      this.song,
      this.parent}) {
    if (this.dancers == null) this.dancers = SingleDancerList(dancers: []);
    if (this.costumes == null) this.costumes = [];
  }

  serialize(RepSink out) {
    SName(name).serialize(out);
    SBigString(description).serialize(out);
    dancers.serialize(out);
    SInt(costumes.length, 1).serialize(out);
    costumes.forEach((c) => c.serialize(out));
    song.serialize(out);
  }

  static Dance deserialize(ByteScanner input, Repertoire parent) {
    Dance d = Dance(parent: parent);
    d.name = SName.deserialize(input);
    d.description = SBigString.deserialize(input);
    d.dancers = DancerList.deserialize(input, d);
    int costumeLength = SInt.deserialize(input, 1);
    d.costumes = List(costumeLength);
    for (int i = 0; i < costumeLength; i++) {
      d.costumes[i] = Costume.deserialize(input, d);
    }
    d.song = Song.deserialize(input, d);
    return d;
  }

  @override
  String toString() {
    return 'Dance{$name, "$description", $dancers, $costumes, $song}';
  }
}
