import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NotesStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/notes.json');
  }

  Future<List<Map<String, dynamic>>> readNotes() async {
    try {
      final file = await _localFile;
      //print(_localFile);
      final contents = await file.readAsString();
      print(contents);
      var notes = (jsonDecode(contents) as List<dynamic>).map((element) => {
            "id": element["id"],
            "name": element["name"],
            "contentNote": element["contentNote"]
          });
      var result = notes.toList();
      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<File> writeNotes(List<Map<String, dynamic>> notes) async {
    final file = await _localFile;
    String json = jsonEncode(notes);
    return file.writeAsString('$json');
  }
}
