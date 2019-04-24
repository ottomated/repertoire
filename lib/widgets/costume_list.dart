import 'package:repertoire/main.dart';
import 'package:repertoire/io/dancer.dart';
import 'package:repertoire/io/costume.dart';
import 'package:repertoire/io/dance.dart';
import 'package:flutter/material.dart';
import 'costume.dart';
import 'save_bar.dart';

class WCostumeList extends StatefulWidget {
  WCostumeList(this.parent, {this.home});
  final Dance parent;
  final HomePageState home;
  @override
  _WCostumeListState createState() => _WCostumeListState();
}

class _WCostumeListState extends State<WCostumeList> {
  bool _editing = false;
  bool _changes;
  List<Costume> _newCostumes;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
            '${widget.parent.name} > ${_editing ? 'Editing ' : ''}Costumes'),
        actions: app.settings.editor
            ? <Widget>[
                IconButton(
                  icon: Icon(_editing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (!_editing) {
                      _newCostumes = widget.parent.costumes
                          .map((t) => Costume.clone(t))
                          .toList();
                      _changes = false;
                    }
                    if (_editing) {
                      if (_changes)
                        setState(() {
                          widget.home.editCostumeList(
                            widget.parent,
                            costumes: _newCostumes,
                          );
                        });
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
                _changes = true;
                setState(() {
                  _newCostumes.add(
                    Costume(
                      name: 'Costume ${_newCostumes.length + 1}',
                      description: '',
                      dancerPart: DancerPart.any,
                      pieces: [],
                      parent: widget.parent,
                    ),
                  );
                });
              },
            )
          : null,
      body: ListView(
        children: <Widget>[
          Padding(
            child: Center(
              child: Text(
                '${widget.parent.costumes.length} costume${widget.parent.costumes.length == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Divider(),
        ]..addAll(
            _editing
                ? _newCostumes
                    .asMap()
                    .map((index, costume) {
                      return MapEntry(
                        index,
                        ListTile(
                          title: Text(
                            costume.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () {
                              setState(() {
                                _changes = true;
                                _newCostumes.removeAt(index);
                              });
                            },
                          ),
                          subtitle: Text(costume.description),
                          trailing: Icon(Icons.edit, color: Colors.grey),
                          onTap: () {
                            var newCostume = Costume.clone(costume);
                            var nameController =
                                TextEditingController(text: costume.name);
                            var descController = TextEditingController(
                                text: costume.description);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('Editing '),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: <Widget>[
                                          TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                                labelText: 'Name'),
                                            maxLength: 255,
                                            onChanged: (str) =>
                                                newCostume.name = str,
                                          ),
                                          TextField(
                                            controller: descController,
                                            decoration: InputDecoration(
                                                labelText: 'Description'),
                                            maxLength: 256 * 256 - 1,
                                            onChanged: (str) =>
                                                newCostume.description = str,
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Save'),
                                        onPressed: () {
                                          _changes = true;
                                          setState(() {
                                            _newCostumes[index] = newCostume;
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                      );
                    })
                    .values
                    .toList()
                : widget.parent.costumes
                    .asMap()
                    .map((index, costume) {
                      return MapEntry(
                        index,
                        ListTile(
                          title: Text(
                            costume.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          leading: dancerPartIcon(costume.dancerPart),
                          subtitle: Text(costume.description),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WCostume(
                                      costume,
                                      home: widget.home,
                                    ),
                              ),
                            );
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
