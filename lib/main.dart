import 'package:flutter/material.dart';
import 'package:notes/services/notesStorage.dart';

void main() => runApp(
      MaterialApp(home: appNotes()),
    );

class appNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ViewNotes(storage: NotesStorage());
}

class ViewNotes extends StatefulWidget {
  const ViewNotes({required this.storage});

  final NotesStorage storage;

  @override
  State<ViewNotes> createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _foundNotes = [];
  List<Map<String, dynamic>> _listContrl = [];

  @override
  void initState() {
    super.initState();
    widget.storage.readNotes().then((value) {
      _allNotes = value;
      _foundNotes = _allNotes;
      _initController();
      setState(() {});
    });
  }

  void _initController() {
    for (var note in _foundNotes) {
      _listContrl.add({
        "id": note["id"],
        "ControllerName": TextEditingController(text: note["name"]),
        "ControllerContent": TextEditingController(text: note["contentNote"])
      });
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allNotes;
    } else {
      results = _allNotes
          .where((note) => _checkNotNull(note["name"])
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    _stateNotes(results);
  }

  void _addNote() {
    setState(() {
      _allNotes.add(
          {"id": _allNotes.length.toString(), "name": "", "contentNote": ""});
      _stateNotes(_allNotes);
      widget.storage.writeNotes(_allNotes);
    });
  }

  void _stateNotes(var _newNotes) {
    setState(() {
      _foundNotes = _newNotes;
      _listContrl.clear();
      _initController();
      widget.storage.writeNotes(_allNotes);
    });
  }

  String _checkNotNull(String? value) {
    if (value != null)
      return value;
    else
      return "null";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20.0, 70.0, 30.0, 30),
                child: const Text(
                  'Все заметки',
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: TextField(
                onChanged: (value) => _runFilter(value),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                obscureText: false,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30)),
                  hintText: 'Поиск',
                  hintStyle: const TextStyle(color: Colors.white),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.amber[900],
                  ),
                  fillColor: Colors.grey[800],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
              ),
            ),
            Expanded(
                flex: 9,
                child: GridView.builder(
                    itemCount: _foundNotes.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10),
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[800]),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10.0,
                            ),
                            Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0, left: 8.0),
                                  child: TextFormField(
                                    controller: _listContrl[index]
                                        ["ControllerName"],
                                    decoration: const InputDecoration(
                                        hintText: 'Название',
                                        hintStyle:
                                            TextStyle(color: Colors.white)),
                                    keyboardType: TextInputType.multiline,
                                    maxLength: 15,
                                  ),
                                )),
                            Expanded(
                                flex: 3,
                                child: Container(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: TextFormField(
                                      controller: _listContrl[index]
                                          ["ControllerContent"],
                                      keyboardType: TextInputType.text,
                                      maxLines: 5,
                                      maxLength: 150,
                                    ),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Container(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              _allNotes[index]["name"] =
                                                  _listContrl[index]
                                                          ["ControllerName"]
                                                      .text;
                                              _allNotes[index]["contentNote"] =
                                                  _listContrl[index]
                                                          ["ControllerContent"]
                                                      .text;
                                              widget.storage
                                                  .writeNotes(_allNotes);
                                            },
                                            icon: Icon(
                                              Icons.check,
                                              color: Colors.amber[900],
                                            )),
                                        IconButton(
                                            onPressed: () {
                                              _allNotes.removeAt(index);
                                              _stateNotes(_allNotes);
                                            },
                                            icon: Icon(
                                              Icons.delete_forever_outlined,
                                              color: Colors.amber[900],
                                            ))
                                      ]),
                                ))
                          ],
                        ),
                      );
                    }))
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 70, 30, 30),
        child: FloatingActionButton(
          backgroundColor: Colors.grey[800],
          child: Icon(
            Icons.add_comment,
            size: 30.0,
            color: Colors.amber[900],
          ),
          onPressed: _addNote,
        ),
      ),
    );
  }
}
