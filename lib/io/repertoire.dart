import 'dance.dart';
import 'dart:convert';
import 'serialization.dart';

// Version 0: init
// Version 1: Add possibility for either partner in a Couple to be null
// Version 2: Add checksum

class Repertoire extends Serializable {
  static final List<int> signature = utf8.encode("RPRTR");
  static final int version = 2;
  String name;
  List<Dance> dances;

  Repertoire({this.name, this.dances});

  serialize(RepSink out) {
    out.add(signature);
    out.add([version]);
    SName(name).serialize(out);
    SInt(dances.length, 1).serialize(out);
    dances.forEach((d) => d.serialize(out));
    out.add(out.getChecksum());
  }

  static Repertoire deserialize(ByteScanner input) {
    if (input.length < 7)
      throw RepertoireException('The file isn\'t a repertoire file. (too small)');
    List<int> signature = input.popRange(5);
    for (int i = 0; i < 5; i++) {
      if (signature[i] != Repertoire.signature[i])
        throw RepertoireException('The file isn\'t a repertoire file. (bad signature)');
    }
    int version = input.pop();
    if (version != Repertoire.version)
      throw RepertoireException(
          'The file is a different version than the app can handle.');
    if (!input.checkChecksum())
      throw RepertoireException('The file is corrupted (bad checksum)');
    Repertoire repertoire = Repertoire();
    repertoire.name = SName.deserialize(input);

    int danceLength = SInt.deserialize(input, 1);
    repertoire.dances = List<Dance>()..length = danceLength;
    for (int i = 0; i < danceLength; i++) {
      repertoire.dances[i] = Dance.deserialize(input, repertoire);
    }
    return repertoire;
  }

  @override
  String toString() {
    return 'Repertoire{$name, $dances}';
  }
}
