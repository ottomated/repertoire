import 'package:repertoire/main.dart';
import 'package:flutter/material.dart';
import 'package:repertoire/io/single_dancer_list.dart';
import 'package:repertoire/io/partner_dancer_list.dart';
import 'package:repertoire/io/dancer_list.dart';
import 'package:repertoire/io/dancer.dart';
import 'package:repertoire/io/dance.dart';

import 'save_bar.dart';

class WDancerList extends StatefulWidget {
  WDancerList(this.dance, {this.home});
  final Dance dance;
  final HomePageState home;
  @override
  _WDancerListState createState() => _WDancerListState();
}

class _WDancerListState extends State<WDancerList> {
  bool _editing = false;
  bool _changes;
  DancerList _newDancers;

  ListTile dancerTile(Dancer d, TextAlign a, int i, {first}) {
    if (d == null)
      return ListTile(
        title: Text(
          '(none)',
          textAlign: _editing ? TextAlign.center : a,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: _editing ? Icon(Icons.add) : null,
        onTap: _editing
            ? () {
                _changes = true;
                var newDancer = Dancer(
                  name: '',
                  description: '',
                  part: DancerPart.any,
                );
                _editDancer(newDancer, (edited) {
                  Couple c = (_newDancers as PartnerDancerList).couples[i];
                  setState(() {
                    if (first)
                      c.first = edited;
                    else
                      c.second = edited;
                  });
                });
              }
            : null,
      );
    return ListTile(
      title: Text(
        d.name,
        textAlign: _editing ? TextAlign.center : a,
      ),
      subtitle: Text(
        d.description,
        textAlign: _editing ? TextAlign.center : a,
      ),
      onTap: _editing
          ? () {
              _editDancer(
                d,
                (edited) {
                  _changes = true;
                  setState(() {
                    if (_newDancers is SingleDancerList) {
                      (_newDancers as SingleDancerList).dancers[i] = edited;
                    } else {
                      var c = (_newDancers as PartnerDancerList).couples[i];
                      if (first)
                        c.first = edited;
                      else
                        c.second = edited;
                    }
                  });
                },
              );
            }
          : null,
      trailing: _editing ? Icon(Icons.edit) : dancerPartIcon(d),
      leading: _editing
          ? IconButton(
              icon: Icon(Icons.delete),
              color: Colors.red,
              onPressed: () {
                _changes = true;
                setState(() {
                  if (_newDancers is SingleDancerList) {
                    (_newDancers as SingleDancerList).dancers.removeAt(i);
                  } else {
                    var c = (_newDancers as PartnerDancerList).couples[i];
                    if (first)
                      c.first = null;
                    else
                      c.second = null;
                    if (c.empty)
                      (_newDancers as PartnerDancerList).couples.removeAt(i);
                  }
                });
              },
            )
          : null,
    );
  }

  _editDancer(Dancer newDancer, Function update) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        return DancerEditor(
          newDancer,
          update: update,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    DancerList currentList = _editing ? _newDancers : widget.dance.dancers;
    String dancerCount =
        '${currentList.length} dancer${currentList.length == 1 ? '' : 's'}';

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
        title:
            Text('${widget.dance.name} > ${_editing ? 'Editing' : ''} Dancers'),
        actions: (_editing
            ? [
                IconButton(
                  icon: Icon(_newDancers is SingleDancerList
                      ? Icons.person
                      : Icons.people),
                  onPressed: () {
                    _changes = true;
                    var newList;
                    if (_newDancers is SingleDancerList) {
                      newList = PartnerDancerList(
                        parent: _newDancers.parent,
                        couples: (_newDancers as SingleDancerList)
                            .dancers
                            .map((d) => Couple.empty(first: d))
                            .toList(),
                      );
                    } else {
                      newList = SingleDancerList(
                        parent: _newDancers.parent,
                        dancers: (_newDancers as PartnerDancerList)
                            .couples
                            .map((c) => [c.first, c.second])
                            .expand((i) => i)
                            .where((d) => d != null)
                            .toList(),
                      );
                    }
                    setState(() {
                      _newDancers = newList;
                    });
                  },
                ),
              ]
            : [])
          ..addAll(app.settings.editor
              ? <Widget>[
                  IconButton(
                    icon: Icon(_editing ? Icons.check : Icons.edit),
                    onPressed: () {
                      if (!_editing) {
                        if (widget.dance.dancers is SingleDancerList) {
                          _newDancers =
                              SingleDancerList.clone(widget.dance.dancers);
                        } else {
                          _newDancers =
                              PartnerDancerList.clone(widget.dance.dancers);
                        }
                        _changes = false;
                      } else if (_editing) {
                        if (_changes)
                          widget.home.editDancerList(
                            widget.dance,
                            newList: _newDancers,
                          );
                      }
                      setState(() {
                        _editing = !_editing;
                      });
                    },
                  ),
                ]
              : null),
      ),
      body: ListView(
        children: [
          Padding(
            child: Center(
              child: Text(
                dancerCount,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          Divider(),
        ]..addAll(
            currentList is SingleDancerList
                ? currentList.dancers
                    .asMap()
                    .map(
                      (i, d) => MapEntry(
                            i,
                            dancerTile(d, TextAlign.left, i),
                          ),
                    )
                    .values
                    .toList()
                : (currentList as PartnerDancerList)
                    .couples
                    .asMap()
                    .map(
                      (i, c) => MapEntry(
                            i,
                            Column(
                              children: [
                                Text('Partner:'),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: dancerTile(
                                          c.first, TextAlign.right, i,
                                          first: true),
                                    ),
                                    Expanded(
                                      child: dancerTile(
                                          c.second, TextAlign.left, i,
                                          first: false),
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          ),
                    )
                    .values
                    .toList(),
          ),
      ),
      floatingActionButton: _editing
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                _changes = true;
                if (_newDancers is SingleDancerList) {
                  var newDancer = Dancer(
                    name: '',
                    description: '',
                    part: DancerPart.any,
                  );
                  _editDancer(newDancer, (edited) {
                    setState(() {
                      (_newDancers as SingleDancerList).dancers.add(edited);
                    });
                  });
                } else {
                  var c = Couple.empty();
                  setState(() {
                    (_newDancers as PartnerDancerList).couples.add(c);
                  });
                }
              },
            )
          : null,
    );
  }
}

class DancerEditor extends StatefulWidget {
  DancerEditor(this.newDancer, {this.update});
  final Dancer newDancer;
  final Function update;
  @override
  _DancerEditorState createState() => _DancerEditorState();
}

class _DancerEditorState extends State<DancerEditor> {
  TextEditingController _nameController;
  TextEditingController _descController;
  Dancer edited;

  @override
  void initState() {
    edited = Dancer.clone(widget.newDancer);
    _nameController = TextEditingController(text: widget.newDancer.name);
    _descController = TextEditingController(text: widget.newDancer.description);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          'Editing ${widget.newDancer.name == '' ? 'new dancer' : widget.newDancer.name}'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              controller: _nameController,
              onChanged: (String s) {
                edited.name = s;
              },
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
              ),
              controller: _descController,
              onChanged: (String s) {
                edited.description = s;
              },
            ),
            DropdownButton<DancerPart>(
              items: DancerPart.values
                  .map(
                    (p) => DropdownMenuItem<DancerPart>(
                          child: Text(p.toString().split('.')[1]),
                          value: p,
                        ),
                  )
                  .toList(),
              value: edited.part,
              onChanged: (p) {
                setState(() {
                  edited.part = p;
                });
              },
            )
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
            widget.update(edited);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

Icon dancerPartIcon(Dancer d) {
  switch (d.part) {
    case DancerPart.lead:
      return Icon(shoe);
    case DancerPart.follow:
      return Icon(shoe_heel);
    default:
      return Icon(Icons.person);
  }
}
