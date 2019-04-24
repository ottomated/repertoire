import 'package:repertoire/main.dart';
import 'package:repertoire/io/costume.dart';
import 'package:repertoire/io/piece.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:repertoire/io/dancer.dart';
import 'package:image_picker/image_picker.dart';
import 'save_bar.dart';

class WCostume extends StatefulWidget {
  WCostume(this.costume, {this.home});
  final Costume costume;
  final HomePageState home;
  @override
  _WCostumeState createState() => _WCostumeState();
}

class _WCostumeState extends State<WCostume> {
  bool _editing = false;
  bool _piecesChanged = false;
  Costume _newCostume;
  TextEditingController _nameController;
  TextEditingController _descriptionController;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.costume.name);
    _descriptionController =
        TextEditingController(text: widget.costume.description);
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
            '${widget.costume.parent.name} > ${_editing ? 'Editing ' : ''}Costume'),
        actions: app.settings.editor
            ? <Widget>[
                IconButton(
                  icon: Icon(_editing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (!_editing) {
                      _nameController.value =
                          TextEditingValue(text: widget.costume.name);
                      _descriptionController.value =
                          TextEditingValue(text: widget.costume.description);
                      _newCostume = Costume.clone(widget.costume);
                    }
                    if (_editing) {
                      widget.home.editCostume(
                        widget.costume,
                        name: _nameController.value.text,
                        description: _descriptionController.value.text,
                        part: _newCostume.dancerPart,
                        pieces: _piecesChanged ? _newCostume.pieces : null,
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
      floatingActionButton: _editing
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _piecesChanged = true;
                  _newCostume.pieces.add(
                    Piece(
                      name: '',
                      description: '',
                      image: Uint8List.fromList([
                        0x89,
                        0x50,
                        0x4E,
                        0x47,
                        0x0D,
                        0x0A,
                        0x1A,
                        0x0A,
                        0x00,
                        0x00,
                        0x00,
                        0x0D,
                        0x49,
                        0x48,
                        0x44,
                        0x52,
                        0x00,
                        0x00,
                        0x00,
                        0x01,
                        0x00,
                        0x00,
                        0x00,
                        0x01,
                        0x08,
                        0x06,
                        0x00,
                        0x00,
                        0x00,
                        0x1F,
                        0x15,
                        0xC4,
                        0x89,
                        0x00,
                        0x00,
                        0x00,
                        0x0B,
                        0x49,
                        0x44,
                        0x41,
                        0x54,
                        0x08,
                        0xD7,
                        0x63,
                        0x60,
                        0x00,
                        0x02,
                        0x00,
                        0x00,
                        0x05,
                        0x00,
                        0x01,
                        0xE2,
                        0x26,
                        0x05,
                        0x9B,
                        0x00,
                        0x00,
                        0x00,
                        0x00,
                        0x49,
                        0x45,
                        0x4E,
                        0x44,
                        0xAE,
                        0x42,
                        0x60,
                        0x82
                      ]),
                    ),
                  );
                });
              },
            )
          : null,
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
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
                          widget.costume.name,
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                ),
                padding: EdgeInsets.all(16.0),
              ),
              _editing
                  ? Container()
                  : Padding(
                      child: dancerPartIcon(_editing
                          ? _newCostume.dancerPart
                          : widget.costume.dancerPart),
                      padding: EdgeInsets.all(12.0),
                    ),
            ],
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
                      widget.costume.description,
                      style: TextStyle(fontSize: 18.0),
                    ),
            ),
            padding: EdgeInsets.all(16.0),
          ),
          _editing
              ? Column(
                  children: <Widget>[
                    DropdownButton<DancerPart>(
                      items: DancerPart.values
                          .map(
                            (p) => DropdownMenuItem<DancerPart>(
                                  child: Text(p.toString().split('.')[1]),
                                  value: p,
                                ),
                          )
                          .toList(),
                      value: _newCostume.dancerPart,
                      onChanged: (nP) {
                        setState(() {
                          _newCostume.dancerPart = nP;
                        });
                      },
                    ),
                  ],
                )
              : Container(),
          Divider(),
        ]..addAll(
            _editing
                ? _newCostume.pieces
                    .asMap()
                    .map(
                      (i, piece) => MapEntry(
                            i,
                            ListTile(
                              title: Text(piece.name),
                              subtitle: Text(piece.description),
                              leading: IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    _piecesChanged = true;
                                    _newCostume.pieces.removeAt(i);
                                  });
                                },
                              ),
                              trailing: Icon(Icons.edit),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => PieceEditor(piece,
                                          update: (edited) async {
                                        setState(() {
                                          _piecesChanged = true;
                                          _newCostume.pieces[i] = edited;
                                        });
                                      }),
                                );
                              },
                            ),
                          ),
                    )
                    .values
                    .toList()
                : [
                    ExpansionPanelList(
                      children: widget.costume.pieces
                          .asMap()
                          .map(
                            (i, piece) => MapEntry(
                                  i,
                                  ExpansionPanel(
                                    headerBuilder: (context, isExpanded) =>
                                        ListTile(
                                          title: Text(
                                              widget.costume.pieces[i].name),
                                          subtitle: Text(widget
                                              .costume.pieces[i].description),
                                        ),
                                    body: Image.memory(
                                        widget.costume.pieces[i].image),
                                    isExpanded:
                                        widget.costume.pieces[i].expanded,
                                  ),
                                ),
                          )
                          .values
                          .toList(),
                      expansionCallback: (i, expanded) {
                        setState(() {
                          widget.costume.pieces[i].expanded =
                              !widget.costume.pieces[i].expanded;
                        });
                      },
                    ),
                  ],
          ),
      ),
    );
  }
}

class PieceEditor extends StatefulWidget {
  PieceEditor(this.newPiece, {this.update});
  final Piece newPiece;
  final Function update;
  @override
  _PieceEditorState createState() => _PieceEditorState();
}

class _PieceEditorState extends State<PieceEditor> {
  TextEditingController _nameController;
  TextEditingController _descController;

  File newImage;
  Piece edited;

  @override
  void initState() {
    edited = Piece.clone(widget.newPiece);
    _nameController = TextEditingController(text: widget.newPiece.name);
    _descController = TextEditingController(text: widget.newPiece.description);
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
          'Editing ${widget.newPiece.name == '' ? 'new piece' : widget.newPiece.name}'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
              maxLength: 255,
              onChanged: (str) => edited.name = str,
            ),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLength: 256 * 256 - 1,
              onChanged: (str) => edited.description = str,
            ),
            Row(
              children: <Widget>[
                Padding(
                    child: RaisedButton.icon(
                      icon: Icon(Icons.camera_alt),
                      label: Text('Take Picture'),
                      onPressed: () async {
                        File n = await ImagePicker.pickImage(
                          source: ImageSource.camera,
                        );
                        setState(() {
                          newImage = n;
                        });
                      },
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 8.0)),
                Padding(
                  child: RaisedButton.icon(
                    icon: Icon(Icons.file_upload),
                    label: Text('Choose File'),
                    onPressed: () async {
                      File n = await ImagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      setState(() {
                        newImage = n;
                      });
                    },
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                ),
              ],
            ),
            newImage == null ? Text('No image chosen') : Image.file(newImage),
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
          onPressed: () async {
            if (newImage != null)
              edited.image = Uint8List.fromList(await newImage.readAsBytes());
            widget.update(edited);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

Icon dancerPartIcon(DancerPart d) {
  switch (d) {
    case DancerPart.lead:
      return Icon(shoe);
    case DancerPart.follow:
      return Icon(shoe_heel);
    default:
      return Icon(Icons.person);
  }
}
