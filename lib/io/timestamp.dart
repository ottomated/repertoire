import 'serialization.dart';

class Timestamp extends Serializable {
  String name;
  Duration time;

  Timestamp({this.name, this.time});
  Timestamp.clone(Timestamp old) {
    name = old.name;
    time = Duration(microseconds: old.time.inMicroseconds);
  }

  @override
  void serialize(RepSink out) {
    SName(name).serialize(out);
    SInt(time.inMicroseconds, 5).serialize(out);
  }

  static Timestamp deserialize(ByteScanner input) {
    Timestamp result = Timestamp();
    result.name = SName.deserialize(input);
    result.time = Duration(microseconds: SInt.deserialize(input, 5));
    return result;
  }


  @override
  String toString() {
    return 'Timestamp{$name $time}';
  }
}
