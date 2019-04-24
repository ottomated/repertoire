import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:io';
import 'dart:typed_data';

import 'io/repertoire.dart';
import 'io/dance.dart';
import 'io/song.dart';
import 'io/timestamp.dart';
import 'io/dancer_list.dart';
import 'io/costume.dart';
import 'io/dancer.dart';
import 'io/piece.dart';
import 'io/serialization.dart';
import 'io/single_dancer_list.dart';

import 'routes/settings.dart';
import 'widgets/save_bar.dart';
import 'widgets/repertoire.dart';

import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

RepertoireApp app;
const IconData shoe_heel = const IconData(0xe800, fontFamily: 'Repertoire');
const IconData shoe = const IconData(0xe801, fontFamily: 'Repertoire');
const IconData shirt = const IconData(0xe802, fontFamily: 'Repertoire');
const IconData dress = const IconData(0xe803, fontFamily: 'Repertoire');

void main() {
  app = RepertoireApp(
    settings: AppSettings(),
  );
  runApp(app);
}

class RepertoireApp extends StatelessWidget {
  RepertoireApp({this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'repertoire',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextEditingController _nameController;

  Repertoire _repertoire;
  Repertoire get repertoire => _repertoire;
  set repertoire(Repertoire rep) {
    setState(() => _repertoire = rep);
  }

  bool _editing = false;
  GlobalKey<ScaffoldState> _scaffold;

  @override
  initState() {
    app.settings.home = this;
    _scaffold = GlobalKey<ScaffoldState>();
    init();
    super.initState();
  }

  Future init() async {
    MethodChannel channel = const MethodChannel('receieve_share');
    Uint8List bytes = await channel.invokeMethod("get");
    if (bytes == null) return;
    Repertoire r;
    try {
      r = Repertoire.deserialize(ByteScanner.fromList(bytes));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Share'),
              content: SingleChildScrollView(
                child: Text(
                    'Do you want to load "${r.name}", shared from another app?'),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Load'),
                  onPressed: () async {
                    app.settings.newRepertoire(
                      (await getApplicationDocumentsDirectory()).path +
                          '/currrent.rprtr',
                      r,
                    );
                    repertoire = r;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    } catch (ex) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Error'),
              content: SingleChildScrollView(
                child: Text('Failed to load file shared from other app\n$ex'),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_repertoire == null) {
      if (!app.settings.initialized) {
        body = Center(child: Text('Initializing Repertoire'));
      } else {
        body = Center(
          child: Column(
            children: [
              RaisedButton.icon(
                icon: Icon(Icons.file_upload),
                label: Text('Open .rprtr file'),
                onPressed: () async {
                  File f = await FilePicker.getFile(type: FileType.ANY);
                  if (f != null) app.settings.openFilePath = f.path;
                },
              ),
              Padding(padding: EdgeInsets.all(4.0)),
              RaisedButton.icon(
                icon: Icon(Icons.add),
                label: Text('New repertoire'),
                onPressed: () async {
                  setState(() {
                    _repertoire =
                        Repertoire(dances: [], name: 'New Repertoire');
                  });
                  app.settings.newRepertoire(
                    (await getApplicationDocumentsDirectory()).path +
                        '/currrent.rprtr',
                    _repertoire,
                  );
                },
              ),
            ],
          ),
        );
      }
    } else {
      body = WRepertoire(_repertoire, home: this, editing: _editing);
    }

    return Scaffold(
      bottomSheet: openChanges && !_editing
          ? SaveBar(
              discard: () {
                setState(() {
                  discardRepertoire();
                });
              },
              save: () {
                setState(() {
                  saveRepertoire();
                });
              },
            )
          : null,
      key: _scaffold,
      appBar: AppBar(
        title: _editing
            ? TextField(
                controller: _nameController,
                style: TextStyle(color: Colors.white),
              )
            : Text(_repertoire == null ? 'Repertoire' : _repertoire.name),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ]..addAll(app.settings.editor
            ? [
                IconButton(
                  icon: Icon(_editing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (!_editing) {
                      _nameController =
                          TextEditingController(text: _repertoire.name);
                    } else if (_nameController.value.text != _repertoire.name) {
                      setState(() {
                        _repertoire.name = _nameController.value.text;
                        markChanged();
                      });
                    }
                    setState(() {
                      _editing = !_editing;
                    });
                  },
                ),
              ]
            : []),
      ),
      body: body,
      floatingActionButton:
          _repertoire == null || app.settings.editor == false || !_editing
              ? null
              : FloatingActionButton(
                  child: Icon(Icons.add),
                  onPressed: () {
                    var newName = 'Dance ${_repertoire.dances.length + 1}';
                    while (_repertoire.dances.any((d) => d.name == newName)) {
                      newName += '_';
                    }
                    var newD = Dance(
                      name: newName,
                      description: '',
                      parent: _repertoire,
                      costumes: [],
                    );
                    newD.song = Song(
                      name: '',
                      description: '',
                      timestamps: [],
                      parent: newD,
                      audio: Uint8List.fromList([]),
                    );
                    newD.dancers = SingleDancerList(dancers: [], parent: newD);
                    setState(() {
                      _repertoire.dances.add(newD);
                    });
                    markChanged();
                  },
                ),
    );
  }

  void editDance(Dance dance, {String name, String description}) {
    bool changed = false;
    if (name != dance.name) {
      while (_repertoire.dances.any((d) => d.name == name)) {
        name += '_';
      }
      dance.name = name;
      changed = true;
    }
    if (description != dance.description) {
      changed = true;
      dance.description = description;
    }
    if (changed) markChanged();
  }

  void editSong(Song song,
      {String name,
      String description,
      List<Timestamp> timestamps,
      File songFile}) {
    bool changed = false;
    if (song.name != name) {
      changed = true;
      song.name = name;
    }
    if (song.description != description) {
      changed = true;
      song.description = description;
    }
    if (timestamps != null) {
      changed = true;
      song.timestamps = timestamps;
    }
    if (songFile != null) {
      changed = true;
      song.audio = Uint8List.fromList(songFile.readAsBytesSync());
    }
    if (changed) markChanged();
  }

  void editDancerList(Dance dance, {DancerList newList}) {
    setState(() {
      dance.dancers = newList;
    });
    markChanged();
  }

  void editCostume(Costume costume,
      {String name, String description, DancerPart part, List<Piece> pieces}) {
    bool changed = false;
    if (name != costume.name) {
      costume.name = name;
      changed = true;
    }
    if (description != costume.description) {
      costume.description = description;
      changed = true;
    }
    if (part != costume.dancerPart) {
      costume.dancerPart = part;
      changed = true;
    }
    if (pieces != null) {
      costume.pieces = pieces;
      changed = true;
    }
    if (changed) markChanged();
  }

  void editCostumeList(Dance dance, {List<Costume> costumes}) {
    dance.costumes = costumes;
    markChanged();
  }

  void removeDance(i) {
    setState(() {
      _repertoire.dances.removeAt(i);
    });
    markChanged();
  }

  void moveDance(i, newI) {
    Dance target = _repertoire.dances[i];
    setState(() {
      _repertoire.dances.removeAt(i);
      _repertoire.dances.insert(newI, target);
    });
    markChanged();
  }

  bool openChanges = false;

  void markChanged() {
    setState(() {
      openChanges = true;
    });
  }

  void saveRepertoire() async {
    openChanges = false;
    app.settings.saveRepertoire(_repertoire);
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  void discardRepertoire() async {
    openChanges = false;
    await app.settings.loadRepertoire();
    Navigator.of(context).popUntil(ModalRoute.withName('/'));
  }

  void showError(RepertoireException ex) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text('Error'),
            content: SingleChildScrollView(
              child: Text('$ex'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CLOSE'),
                onPressed: () => Navigator.pop(ctx),
              )
            ],
          ),
    );
    setState(() {});
  }

  void markInit() {
    setState(() {});
  }
}
