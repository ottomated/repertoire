import 'package:flutter/material.dart';

class SaveBar extends StatefulWidget {
  SaveBar({this.discard, this.save});
  final Function discard;
  final Function save;

  @override
  _SaveBarState createState() => _SaveBarState();
}

class _SaveBarState extends State<SaveBar> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      accentColor: theme.accentColor,
      accentColorBrightness: theme.accentColorBrightness,
    );
    return Material(
      elevation: 6.0,
      color: Color(0xFF323232),
      child: Theme(
        data: darkTheme,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 24.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: DefaultTextStyle(
                  style: darkTheme.textTheme.subhead,
                  child: Text('Unsaved changes.\nSave before closing the app.'),
                ),
              ),
            ),
            ButtonTheme.bar(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              textTheme: ButtonTextTheme.accent,
              child: FlatButton(
                child: Text('DISCARD'),
                textColor: Colors.orange,
                onPressed: widget.discard,
              ),
            ),
            ButtonTheme.bar(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              textTheme: ButtonTextTheme.accent,
              child: FlatButton(
                child: Text('SAVE'),
                textColor: Colors.lightGreen,
                onPressed: widget.save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
