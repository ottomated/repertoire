import 'package:repertoire/io/dance.dart';
import 'package:repertoire/main.dart';
import 'package:flutter/material.dart';
import 'dancer_list.dart';
import 'song.dart';
import 'costume_list.dart';
import 'save_bar.dart';

class WDance extends StatefulWidget {
  WDance(this.dance, {this.home});
  final Dance dance;
  final HomePageState home;
  @override
  _WDanceState createState() => _WDanceState();
}

class _WDanceState extends State<WDance> {
  bool _editing = false;
  TextEditingController _nameController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.dance.name);
    _descriptionController =
        TextEditingController(text: widget.dance.description);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
            '${widget.dance.parent.name} > ${_editing ? 'Editing' : ''} Dance'),
        actions: app.settings.editor
            ? <Widget>[
                IconButton(
                  icon: Icon(_editing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (!_editing) {
                      _nameController.value =
                          TextEditingValue(text: widget.dance.name);
                      _descriptionController.value =
                          TextEditingValue(text: widget.dance.description);
                    } else if (_editing) {
                      widget.home.editDance(
                        widget.dance,
                        name: _nameController.value.text,
                        description: _descriptionController.value.text,
                      );
                    }
                    setState(() {
                      _editing = !_editing;
                    });
                  },
                ),
              ]
            : null,
      ),
      body: ListView(
        children: [
          Padding(
            child: Center(
              child: _editing
                  ? TextField(
                      controller: _nameController,
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(labelText: 'Name'),
                      maxLength: 255,
                    )
                  : Text(
                      widget.dance.name,
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
                      widget.dance.description,
                      style: TextStyle(fontSize: 18.0),
                    ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          ListTile(
            title: Text(
                '${widget.dance.dancers.length} Dancer${widget.dance.dancers.length == 1 ? '' : 's'}'),
            trailing: _editing ? null : Icon(Icons.chevron_right),
            leading: Icon(Icons.person),
            onTap: _editing
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WDancerList(
                              widget.dance,
                              home: widget.home,
                            ),
                      ),
                    );
                  },
          ),
          Divider(),
          ListTile(
            title: Text(
                '${widget.dance.costumes.length} Costume${widget.dance.costumes.length == 1 ? '' : 's'}'),
            trailing: _editing ? null : Icon(Icons.chevron_right),
            leading: Icon(dress),
            onTap: _editing
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WCostumeList(
                              widget.dance,
                              home: widget.home,
                            ),
                      ),
                    );
                  },
          ),
          Divider(),
          ListTile(
            title: Text('Play song'),
            trailing: _editing ? null : Icon(Icons.chevron_right),
            leading: Icon(Icons.audiotrack),
            onTap: _editing
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WSong(
                              widget.dance.song,
                              home: widget.home,
                            ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
