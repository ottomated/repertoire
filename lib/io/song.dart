import 'timestamp.dart';
import 'dart:typed_data';
import 'serialization.dart';
import 'dance.dart';

class Song extends Serializable {
  String name;
  String description;
  List<Timestamp> timestamps;
  Uint8List audio;
  Dance parent;

  Song({this.name, this.description, this.timestamps, this.audio, this.parent});

  @override
  void serialize(RepSink out) {
    SName(name).serialize(out);
    SBigString(description).serialize(out);

    SInt(timestamps.length, 1).serialize(out);
    timestamps.forEach((t) => t.serialize(out));

    SInt(audio.length, 4).serialize(out);
    out.add(audio);
  }

  static Song deserialize(ByteScanner input, Dance parent) {
    Song result = Song(parent: parent);
    result.name = SName.deserialize(input);
    result.description = SBigString.deserialize(input);

    int timestampLength = SInt.deserialize(input, 1);
    result.timestamps = List(timestampLength);
    for (int i = 0; i < timestampLength; i++) {
      result.timestamps[i] = Timestamp.deserialize(input);
    }
    int audioLength = SInt.deserialize(input, 4);
    result.audio = Uint8List.fromList(input.popRange(audioLength));
    return result;
  }

  @override
  String toString() {
    return 'Song{$name, "$description", $timestamps, ${audio.length}B Audio}';
  }
}
