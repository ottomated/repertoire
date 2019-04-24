import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class RepSink implements IOSink {
  final IOSink _sink;
  List<int> _bytes;

  RepSink(this._sink) {
    this._bytes = [];
  }

  Encoding get encoding => _sink.encoding;
  set encoding(Encoding encoding) {
    _sink.encoding = encoding;
  }

  void write(object) {
    _sink.write(object);
  }

  void writeln([object = ""]) {
    _sink.writeln(object);
  }

  void writeAll(objects, [sep = ""]) {
    _sink.writeAll(objects, sep);
  }

  void add(List<int> data) {
    _sink.add(data);
    this._bytes.addAll(data);
  }

  Uint8List getChecksum() {
    var digest = sha256.convert(_bytes);
    return digest.bytes;
  }

  void addError(error, [StackTrace stackTrace]) {
    _sink.addError(error, stackTrace);
  }

  void writeCharCode(int charCode) {
    _sink.writeCharCode(charCode);
  }

  Future addStream(Stream<List<int>> stream) => _sink.addStream(stream);
  Future flush() => _sink.flush();
  Future close() => _sink.close();
  Future get done => _sink.done;
}

abstract class Serializable {
  void serialize(RepSink out);
}

class SName extends Serializable {
  SName(this._string);
  final String _string;

  @override
  void serialize(RepSink out) {
    var bytes = utf8.encode(_string);
    if (bytes.length > 255)
      throw FormatException('Name is too many bytes (${bytes.length} > 255)');
    SInt(bytes.length, 1).serialize(out);
    out.add(bytes);
  }

  static String deserialize(ByteScanner input) {
    int length = SInt.deserialize(input, 1);
    return utf8.decode(input.popRange(length));
  }
}

class SBigString extends Serializable {
  SBigString(this._string);
  final String _string;

  @override
  void serialize(RepSink out) {
    var bytes = utf8.encode(_string);
    if (bytes.length > 255 * 255)
      throw FormatException(
          'BigString is too many bytes (${bytes.length} > 65535)');
    SInt(bytes.length, 2).serialize(out);
    out.add(bytes);
  }

  static String deserialize(ByteScanner input) {
    int length = SInt.deserialize(input, 2);
    return utf8.decode(input.popRange(length));
  }
}

class SInt extends Serializable {
  SInt(this._int, this._length);
  final int _int;
  final int _length;

  @override
  void serialize(RepSink out) {
    var bytes = Uint8List(_length);
    int shift = 0;
    for (int i = _length - 1; i >= 0; i--) {
      bytes[i] = _int >> shift;
      shift += 8;
    }
    out.add(bytes);
  }

  static int deserialize(ByteScanner input, int length) {
    var bytes = Uint8List.fromList(input.popRange(length));
    int result = 0;
    int shift = 0;
    for (int i = length - 1; i >= 0; i--) {
      result |= bytes[i] << shift;
      shift += 8;
    }
    return result;
  }
}

class ByteScanner {
  int _index;
  Uint8List _bytes;
  ByteScanner.fromList(List<int> l) {
    _bytes = Uint8List.fromList(l);
    _index = 0;
  }

  int get length => _bytes.length;

  List<int> popRange(int length) {
    var r = _bytes.getRange(_index, _index + length).toList();
    _index += length;
    return r;
  }

  int pop() {
    int b = _bytes[_index];
    _index++;
    return b;
  }

  int peek() {
    return _bytes[_index];
  }

  @override
  String toString() {
    return '[$_index]$_bytes';
  }

  bool checkChecksum() {
    if (_bytes.length < 32) return false;
    var toCheck = _bytes.getRange(0, _bytes.length - 32).toList();
    var sum = _bytes.getRange(_bytes.length - 32, _bytes.length).toList();
    var digest = sha256.convert(toCheck);
    for (int i = 0; i < 32; i++) {
      if (digest.bytes[i] != sum[i]) return false;
    }

    return true;
  }
}

class RepertoireException implements Exception {
  final String msg;

  RepertoireException(this.msg);

  @override
  String toString() => 'Problem while reading file:\n$msg';
}
