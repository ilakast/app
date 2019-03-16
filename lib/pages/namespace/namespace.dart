import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vikunja_app/components/AddDialog.dart';
import 'package:vikunja_app/global.dart';
import 'package:vikunja_app/models/list.dart';
import 'package:vikunja_app/models/namespace.dart';
import 'package:vikunja_app/pages/list/list.dart';

class NamespacePage extends StatefulWidget {
  final Namespace namespace;

  NamespacePage({this.namespace}) : super(key: Key(namespace.id.toString()));

  @override
  _NamespacePageState createState() => new _NamespacePageState();
}

class _NamespacePageState extends State<NamespacePage> {
  List<TaskList> _lists = [];
  bool _loading = true;

  /////
  // This essentially shows the lists.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !this._loading
          ? RefreshIndicator(
              child: new ListView(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                children: ListTile.divideTiles(
                    context: context,
                    tiles: _lists.map((ls) => Dismissible(
                          key: Key(ls.id.toString()),
                          direction: DismissDirection.startToEnd,
                          child: ListTile(
                            title: new Text(ls.title),
                            onTap: () => _openList(context, ls),
                            trailing: Icon(Icons.arrow_right),
                          ),
                          background: Container(
                            color: Colors.red,
                            child: const ListTile(
                                leading: Icon(Icons.delete,
                                    color: Colors.white, size: 36.0)),
                          ),
                          onDismissed: (direction) {
                            _removeList(ls).then((_) => Scaffold.of(context)
                                .showSnackBar(SnackBar(
                                    content: Text("${ls.title} removed"))));
                          },
                        ))).toList(),
              ),
              onRefresh: _updateLists,
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
              onPressed: () => _addListDialog(context),
              child: const Icon(Icons.add))),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateLists();
  }

  Future _removeList(TaskList list) {
    return VikunjaGlobal.of(context)
        .listService
        .delete(list.id)
        .then((_) => _updateLists());
  }

  Future<void> _updateLists() {
    return VikunjaGlobal.of(context)
        .listService
        .getByNamespace(widget.namespace.id)
        .then((lists) => setState(() {
              this._lists = lists;
              this._loading = false;
            }));
  }

  _openList(BuildContext context, TaskList list) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ListPage(taskList: list)));
  }

  _addListDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddDialog(
          onAdd: (name) => _addList(name, context),
          decoration: new InputDecoration(
              labelText: 'List Name', hintText: 'eg. Shopping List')),
    );
  }

  _addList(String name, BuildContext context) {
    VikunjaGlobal.of(context)
        .listService
        .create(widget.namespace.id, TaskList(id: null, title: name, tasks: []))
        .then((_) {
      setState(() {});
      _updateLists();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('The list was successfully created!'),
        ),
      );
    });
  }
}