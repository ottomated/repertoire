import 'package:repertoire/main.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:repertoire/io/repertoire.dart';
import 'package:repertoire/io/serialization.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Open .rprtr file'),
            subtitle: Text('Current: ${app.settings.openFilePath}'),
            trailing: Icon(Icons.file_upload),
            onTap: () async {
              File f = await FilePicker.getFile(type: FileType.ANY);
              if (f != null) app.settings.openFilePath = f.path;
            },
          ),
          SwitchListTile(
            title: Text('Editing'),
            subtitle:
                Text('Turn this on if you want to make changes to repertoires'),
            value: app.settings.editor,
            onChanged: (b) {
              setState(() {
                app.settings.editor = b;
              });
            },
          ),
          ListTile(
            title: Text('Share repertoire file'),
            trailing: Icon(Icons.share),
            onTap: () async {
              var rep = app.settings.currentRepertoire;

              Share.file(
                'Sharing ${rep.name}',
                rep.name.toLowerCase().replaceAll(' ', '_') + '.rprtr',
                await File(app.settings.openFilePath).readAsBytes(),
                'application/repertoire',
              );
            },
          )
        ],
      ),
    );
  }
}

class AppSettings {
  Repertoire currentRepertoire;
  bool initialized = false;
  HomePageState home;

  bool _editor = false;
  bool get editor => _editor;
  set editor(bool b) {
    _editor = b;
    SharedPreferences.getInstance().then((prefs) => prefs.setBool('editor', b));
  }

  String _openFilePath;
  String get openFilePath => _openFilePath;
  set openFilePath(String p) {
    _openFilePath = p;
    loadRepertoire();
  }

  AppSettings() {
    init();
  }
  Future init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var keys = prefs.getKeys();
    if (!keys.contains('openFilePath'))
      await prefs.setString('openFilePath', '');
    if (!keys.contains('editor')) await prefs.setBool('editor', false);
    _openFilePath = prefs.getString('openFilePath');
    _editor = prefs.getBool('editor');
    if (openFilePath != '') await loadRepertoire();
    initialized = true;
    home.markInit();
  }

  Future loadRepertoire() async {
    try {
      File f = File(openFilePath);
      var input = ByteScanner.fromList(await f.readAsBytes());
      try {
        currentRepertoire = Repertoire.deserialize(input);
        home.repertoire = currentRepertoire;
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString('openFilePath', openFilePath);
      } catch (e) {
        if (home != null) {
          if (e.runtimeType == RepertoireException)
            home.showError(e);
          else
            home.showError(
                RepertoireException('The file is invalid or corrupt'));
        }
      }
    } catch (e) {
      if (home != null) {
        home.showError(RepertoireException(e.toString()));
      }
    }
  }

  Future saveRepertoire(Repertoire repertoire) async {
    File f = File(openFilePath + '.0');
    try {
      repertoire.serialize(RepSink(f.openWrite()));
      await f.rename(openFilePath);
    } catch (e) {
      if (home != null) {
        home.showError(RepertoireException(e.toString()));
      }
      await f.delete();
    }
  }

  Future newRepertoire(String path, Repertoire rep) async {
    _openFilePath = path;
    await saveRepertoire(rep);
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('openFilePath', openFilePath);
    app.settings.editor = true;
    app.settings.currentRepertoire = rep;
    home.markInit();
  }
}
