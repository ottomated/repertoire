import 'package:repertoire/io/song.dart';
import 'package:repertoire/main.dart';
import 'package:repertoire/io/timestamp.dart';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:color/color.dart' as hsl;
import 'package:file_picker/file_picker.dart';
import 'save_bar.dart';

class WSong extends StatefulWidget {
  WSong(this.song, {this.home});
  final Song song;
  final HomePageState home;

  @override
  _WSongState createState() => _WSongState();
}

class _WSongState extends State<WSong> {
  bool _editing = false;
  TextEditingController _nameController;
  TextEditingController _descriptionController;
  File _newFile;
  List<Timestamp> _newTimestamps;
  bool _timestampsChanged;
  bool prevChanges;

  List<Color> rainbow;
  SongPlayer player;

  @override
  void initState() {
    prevChanges = widget.home.openChanges;
    _nameController = TextEditingController(text: widget.song.name);
    _descriptionController =
        TextEditingController(text: widget.song.description);
    initPlayer();
    super.initState();
  }

  void initPlayer() {
    if (player != null) player.dispose();
    player = SongPlayer(widget.song);
    player.onPositionChanged = (Duration p) {
      setState(() {});
    };
    player.onStateChanged = (AudioPlayerState s) {
      setState(() {
        if (s == AudioPlayerState.COMPLETED) player.seek(0.0);
      });
    };
    rainbow = getRainbowColors(widget.song.timestamps.length);
  }

  @override
  void dispose() {
    player.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget songContent;
    if (_editing) {
      songContent = Column(
        children: [
          Center(
            child: RaisedButton.icon(
              icon: Icon(Icons.file_upload),
              label: Text('Choose Song File'),
              onPressed: () async {
                File f = await FilePicker.getFile(type: FileType.AUDIO);
                setState(() {
                  _newFile = f;
                });
              },
            ),
          ),
          Text(
            _newFile == null ? 'No file selected' : basename(_newFile.path),
          ),
        ],
      );
    } else if (player.valid) {
      songContent = Column(
        children: <Widget>[
          CustomPaint(
            foregroundPainter: _TimestampPainter(
              widget.song.timestamps,
              rainbow,
              context,
              player.duration,
            ),
            child: Slider(
              value: player.position.inMicroseconds.toDouble(),
              min: 0.0,
              max: player.duration.inMicroseconds.toDouble(),
              onChanged: (double value) async {
                await player.seek(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.skip_previous),
                onPressed: () {
                  player.seek(0.0);
                },
              ),
              IconButton(
                icon: Icon(Icons.fast_rewind),
                onPressed: () {
                  Timestamp target = Timestamp(name: 'Start', time: Duration());
                  for (int i = 0; i < widget.song.timestamps.length; i++) {
                    if (widget.song.timestamps[i].time >=
                        (player.position - Duration(seconds: 2))) {
                      player.seekTimestamp(target);
                      return;
                    }
                    target = widget.song.timestamps[i];
                  }
                  player.seekTimestamp(target);
                },
              ),
              IconButton(
                icon: Icon(player.state == AudioPlayerState.PLAYING
                    ? Icons.pause
                    : Icons.play_arrow),
                onPressed: () {
                  if (player.state == AudioPlayerState.PLAYING) {
                    player.pause();
                  } else {
                    player.play();
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.fast_forward),
                onPressed: () {
                  Timestamp target = Timestamp(
                      name: 'End',
                      time: player.duration - Duration(milliseconds: 250));
                  for (int i = widget.song.timestamps.length - 1; i >= 0; i--) {
                    if (widget.song.timestamps[i].time <=
                        player.position + Duration(seconds: 2)) {
                      player.seekTimestamp(target);
                      return;
                    }
                    target = widget.song.timestamps[i];
                  }
                  player.seekTimestamp(target);
                },
              ),
              Text(
                toMMSS(player.position),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      );
    } else {
      songContent = Center(child: Text('No song loaded'));
    }

    return Scaffold(
      bottomSheet: widget.home.openChanges && !_editing
          ? SaveBar(
              discard: () {
                setState(() {
                  widget.home.discardRepertoire();
                });
              },
              save: () {
                setState(() {
                  widget.home.saveRepertoire();
                });
              },
            )
          : null,
      appBar: AppBar(
        leading: _editing
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _editing = false;
                  });
                },
              )
            : null,
        title: Text('${widget.song.parent.name} > Song'),
        actions: app.settings.editor
            ? <Widget>[
                IconButton(
                  icon: Icon(_editing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (!_editing) {
                      _newTimestamps = widget.song.timestamps
                          .map((t) => Timestamp.clone(t))
                          .toList();
                      _timestampsChanged = false;
                      _newFile = null;
                      _nameController.value =
                          TextEditingValue(text: widget.song.name);
                      _descriptionController.value =
                          TextEditingValue(text: widget.song.description);
                    }
                    if (_editing) {
                      widget.home.editSong(
                        widget.song,
                        name: _nameController.value.text,
                        description: _descriptionController.value.text,
                        songFile: _newFile,
                        timestamps: _timestampsChanged ? _newTimestamps : null,
                      );
                      initPlayer();
                    }
                    setState(() {
                      _editing = !_editing;
                    });
                  },
                ),
              ]
            : null,
      ),
      floatingActionButton: _editing
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _timestampsChanged = true;
                  _newTimestamps.add(Timestamp(name: '', time: Duration()));
                });
              },
            )
          : null,
      body: ListView(
        children: <Widget>[
          Padding(
            child: Center(
              child: _editing
                  ? TextField(
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(labelText: 'Name'),
                      maxLength: 255,
                    )
                  : Text(
                      widget.song.name,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Padding(
            child: Center(
              child: _editing
                  ? TextField(
                      controller: _descriptionController,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18.0),
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLength: 256 * 256 - 1,
                    )
                  : Text(
                      widget.song.description,
                      style: TextStyle(fontSize: 18.0),
                    ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Divider(),
          songContent,
          Divider()
        ]..addAll(
            _editing
                ? _newTimestamps
                    .asMap()
                    .map((stampIndex, stamp) {
                      return MapEntry(
                        stampIndex,
                        ListTile(
                          title: Text(
                            stamp.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                _timestampsChanged = true;
                                _newTimestamps.removeAt(stampIndex);
                              });
                            },
                          ),
                          subtitle: Text(
                            toMMSS(stamp.time),
                          ),
                          trailing: Icon(Icons.edit, color: Colors.grey),
                          onTap: () {
                            Timestamp newStamp = Timestamp.clone(stamp);
                            var _nameController =
                                TextEditingController(text: newStamp.name);
                            var _mContr = TextEditingController(
                                text: (newStamp.time.inMinutes -
                                        newStamp.time.inHours * 60)
                                    .toString());
                            var _sContr = TextEditingController(
                                text: (newStamp.time.inSeconds -
                                        newStamp.time.inMinutes * 60)
                                    .toString());
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: Text('Editing ${stamp.name}'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      children: <Widget>[
                                        TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Name',
                                          ),
                                          controller: _nameController,
                                          onChanged: (String s) {
                                            newStamp.name = s;
                                          },
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text('Timestamp (MM:SS):'),
                                            Container(
                                              width: 30.0,
                                              child: TextField(
                                                textAlign: TextAlign.right,
                                                decoration: InputDecoration(
                                                  hintText: 'MM',
                                                ),
                                                controller: _mContr,
                                                onChanged: (String s) {
                                                  newStamp.time = Duration(
                                                      minutes: int.parse(s),
                                                      seconds: int.parse(
                                                          _sContr.value.text));
                                                },
                                                onTap: () {
                                                  _mContr.selection =
                                                      TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset: _mContr
                                                        .value.text.length,
                                                  );
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                            Text(':'),
                                            Container(
                                              width: 30.0,
                                              child: TextField(
                                                textAlign: TextAlign.left,
                                                decoration: InputDecoration(
                                                  hintText: 'SS',
                                                ),
                                                controller: _sContr,
                                                onChanged: (String s) {
                                                  newStamp.time = Duration(
                                                      minutes: int.parse(
                                                          _mContr.value.text),
                                                      seconds: int.parse(s));
                                                },
                                                onTap: () {
                                                  _sContr.selection =
                                                      TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset: _sContr
                                                        .value.text.length,
                                                  );
                                                },
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _nameController.dispose();
                                        _mContr.dispose();
                                        _sContr.dispose();
                                      },
                                    ),
                                    FlatButton(
                                      child: Text('Save'),
                                      onPressed: () {
                                        setState(() {
                                          _timestampsChanged = true;
                                          _newTimestamps[stampIndex] = newStamp;
                                          _newTimestamps.sort((a, b) =>
                                              a.time.inMicroseconds -
                                              b.time.inMicroseconds);
                                        });
                                        Navigator.pop(ctx);
                                        Future.delayed(Duration(seconds: 1),
                                            () {
                                          _nameController.dispose();
                                          _mContr.dispose();
                                          _sContr.dispose();
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      );
                    })
                    .values
                    .toList()
                : widget.song.timestamps
                    .asMap()
                    .map((index, stamp) {
                      return MapEntry(
                        index,
                        ListTile(
                          title: Text(
                            stamp.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            toMMSS(stamp.time),
                          ),
                          trailing: Icon(
                            (stamp.time > (player.position))
                                ? Icons.fast_forward
                                : Icons.fast_rewind,
                            color: rainbow[index],
                          ),
                          onTap: () {
                            player.seekTimestamp(stamp);
                          },
                        ),
                      );
                    })
                    .values
                    .toList(),
          ),
      ),
    );
  }
}

List<Color> getRainbowColors(int length) {
  var r = List<Color>(length);
  double hue = 360;
  for (int i = 0; i < length; i++) {
    var c = hsl.HslColor(hue, 75, 50).toRgbColor();
    r[i] = Color.fromRGBO(c.r, c.b, c.g, 1);
    hue -= 360 / length;
  }
  return r;
}

String toMMSS(Duration time) {
  return twoDigits(time.inMinutes.remainder(Duration.minutesPerHour)) +
      ':' +
      twoDigits(time.inSeconds.remainder(Duration.secondsPerMinute));
}

String twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

class _TimestampPainter extends CustomPainter {
  final List<Timestamp> timestamps;
  final BuildContext context;
  final List<Color> colors;
  final Duration duration;
  _TimestampPainter(this.timestamps, this.colors, this.context, this.duration);

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == null) return;
    double y = size.height / 2;
    double padding = RoundSliderOverlayShape().overlayRadius;
    double width = size.width - padding * 2;
    for (int i = 0; i < timestamps.length; i++) {
      double x =
          timestamps[i].time.inMilliseconds / duration.inMilliseconds * width +
              padding;
      Path tri = Path();
      tri.moveTo(x, y);
      tri.lineTo(x - 4, y - 8);
      tri.lineTo(x + 4, y - 8);
      canvas.drawPath(tri, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SongPlayer {
  Song song;

  StreamSubscription _positionSubscription;
  StreamSubscription _stateSubscription;
  AudioPlayer audioPlayer;
  Duration duration;
  Duration _position;
  Duration get position {
    if (_position > duration)
      return duration;
    else
      return _position;
  }

  AudioPlayerState state = AudioPlayerState.STOPPED;
  File audioFile;
  bool valid = true;

  Function onPositionChanged;
  Function onStateChanged;

  SongPlayer(this.song) {
    duration = Duration();
    _position = Duration();
    if (song.audio.length == 0)
      valid = false;
    else
      initAudioPlayer();
  }

  void initAudioPlayer() async {
    valid = true;
    var rng = Random();
    audioFile = File((await getTemporaryDirectory()).path +
        '/${song.name}_TEMP_${rng.nextInt(10000)}');
    await audioFile.writeAsBytes(song.audio);

    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen((p) {
      _position = p;
      if (onPositionChanged != null) onPositionChanged(p);
    });
    _stateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      duration = audioPlayer.duration;
      state = s;
      if (s == AudioPlayerState.PLAYING) {
        audioPlayer
            .seek(position.inMicroseconds / Duration.microsecondsPerSecond);
      }
      if (onStateChanged != null) onStateChanged(s);

      /*
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        setState(() {
          playerState = AudioPlayerState.STOPPED;
          position = duration;
        });
      }
    }, onError: (msg) {
      print(msg);
    });
    */
    });
  }

  Future<bool> play() async {
    if (state == AudioPlayerState.PLAYING) return false;
    await audioPlayer.play(audioFile.path, isLocal: true);
    return true;
  }

  Future<bool> pause() async {
    if (state != AudioPlayerState.PLAYING) return false;
    await audioPlayer.pause();
    return true;
  }

  Future<void> seek(double target) async {
    if (state == AudioPlayerState.PLAYING)
      await audioPlayer.seek(target / Duration.microsecondsPerSecond);
    _position = Duration(microseconds: target.round());
    if (onPositionChanged != null) onPositionChanged(position);
  }

  Future<void> seekTimestamp(Timestamp target) async {
    Duration d = target.time;
    if (d > duration) d = duration;
    if (d < Duration()) d = Duration();
    seek(d.inMicroseconds.toDouble());
  }

  void dispose() {
    if (valid) {
      _positionSubscription.cancel();
      _stateSubscription.cancel();
      audioPlayer.stop();
      audioFile.delete();
    }
  }
}
