import 'package:repertoire/io/repertoire.dart';
import 'package:repertoire/main.dart';
import 'package:flutter/material.dart';
import 'dance.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

class WRepertoire extends StatefulWidget {
  WRepertoire(this.repertoire, {this.home, this.editing});
  final bool editing;
  final Repertoire repertoire;
  final HomePageState home;
  @override
  _WRepertoireState createState() => _WRepertoireState();
}

class _WRepertoireState extends State<WRepertoire> {
  @override
  Widget build(BuildContext context) {
    return widget.editing
        ? ReorderableList(
            onReorder: (item, newPosition) {
              int i = widget.repertoire.dances.indexWhere(
                (d) => ValueKey(d.name) == item,
              );
              int newI = widget.repertoire.dances.indexWhere(
                (d) => ValueKey(d.name) == newPosition,
              );
              widget.home.moveDance(i, newI);
              return true;
            },
            child: CustomScrollView(
              slivers: <Widget>[
                SliverPadding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          var d = widget.repertoire.dances[index];
                          return ReorderableItem(
                            key: ValueKey(d.name),
                            childBuilder: (context, state) {
                              return SafeArea(
                                top: false,
                                bottom: false,
                                child: Opacity(
                                  opacity:
                                      state == ReorderableItemState.placeholder
                                          ? 0.0
                                          : 1.0,
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            widget.home.removeDance(index);
                                          },
                                        ),
                                        Expanded(
                                            child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 14.0, horizontal: 14.0),
                                          child: Text(d.name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subhead),
                                        )),
                                        // Triggers the reordering
                                        widget.editing
                                            ? ReorderableListener(
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 18.0, left: 18.0),
                                                  child: Center(
                                                    child: Icon(Icons.reorder,
                                                        color:
                                                            Color(0xFF888888)),
                                                  ),
                                                ),
                                              )
                                            : null,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                              /*
                            );
                            title: Text(d.name),
                            subtitle: Text(d.description),
                            leading: widget.editing
                                ? IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Colors.red,
                                    onPressed: () {
                                      widget.home.removeDance(index);
                                    },
                                  )
                                : null,
                            trailing: widget.editing
                                ? ReorderableListener(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          right: 18.0, left: 18.0),
                                      color: Color(0x08000000),
                                      child: Center(
                                        child: Icon(Icons.reorder,
                                            color: Color(0xFF888888)),
                                      ),
                                    ),
                                  )
                                : Icon(Icons.chevron_right),
                            onTap: widget.editing
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              WDance(d, home: widget.home)),
                                    );
                                  },
                          );*/
                            },
                          );
                        },
                        childCount: widget.repertoire.dances.length,
                      ),
                    )),
              ],
            ))
        : ListView(
            children: widget.repertoire.dances
                .asMap()
                .map(
                  (i, d) {
                    return MapEntry(
                      i,
                      ListTile(
                        title: Text(d.name),
                        subtitle: Text(d.description),
                        leading: widget.editing
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () {
                                  widget.home.removeDance(i);
                                },
                              )
                            : null,
                        trailing:
                            widget.editing ? null : Icon(Icons.chevron_right),
                        onTap: widget.editing
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WDance(d, home: widget.home)),
                                );
                              },
                      ),
                    );
                  },
                )
                .values
                .toList(),
          );
  }
}
