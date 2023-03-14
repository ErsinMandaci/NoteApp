import 'package:flutter/material.dart';
import 'package:flutter_note_app/category_process.dart';
import 'package:flutter_note_app/models/category.dart';
import 'package:flutter_note_app/note_detail.dart';
import 'package:flutter_note_app/utils/database_helper.dart';
import 'models/notes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: NoteList(),
    );
  }
}

class NoteList extends StatelessWidget {
  DatabaseHelper databaseHelper = DatabaseHelper();

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Center(
          child: Text('Note Box'),
        ),
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                  child: ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categories'),
                onTap: () {
                  Navigator.pop(context);
                  _pushCategoriesPage(context);
                },
              )),
            ];
          }),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addCategory',
            onPressed: () {
              addCategory(context);
            },
            mini: true,
            tooltip: 'Add Category',
            child: const Icon(Icons.add_circle),
          ),
          FloatingActionButton(
            heroTag: 'addNote',
            onPressed: () => pushDetailPage(context),
            tooltip: 'Add Note',
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: const Notes(),
    );
  }

  Future<dynamic> addCategory(BuildContext context) {
    var formKey = GlobalKey<FormState>();
    String? newCategoryName;
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Add Category'),
            titleTextStyle: TextStyle(color: Theme.of(context).primaryColor),
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onSaved: (newValue) {
                      newCategoryName = newValue!;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Category Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (inputCategoryName) {
                      if (inputCategoryName!.length < 3) {
                        return 'Please enter a minimum of 3 characters';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              ButtonBar(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.orangeAccent),
                    ),
                    child: const Text(
                      'Give Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        databaseHelper
                            .addCategory(Category(newCategoryName))
                            .then((value) {
                          if (value > 0) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Add Category $value'),
                              duration: const Duration(seconds: 2),
                            ));
                          }
                          Navigator.pop(context);
                        });
                      }
                    },
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.redAccent),
                    ),
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          );
        });
  }

  pushDetailPage(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteDetail(
            title: 'New Note',
          ),
        ));
  }

  void _pushCategoriesPage(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Categories(),
    ));
  }
}

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  State<Notes> createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  DatabaseHelper _databaseHelper = DatabaseHelper();
  late List<Note> allNotes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allNotes = <Note>[];
    _databaseHelper = DatabaseHelper();

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _databaseHelper.getNoteList(),
      builder: (context, AsyncSnapshot<List<Note>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          allNotes = snapshot.data!;

          return ListView.builder(
            itemBuilder: (context, index) {
              return ExpansionTile(
                leading: _primacyIcon(allNotes[index].notePrimacy),
                title: Text(allNotes[index].noteName!),
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Category',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                allNotes[index].noteName!,
                                style: const TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Creation Date',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _databaseHelper.dateFormat(
                                    DateTime.parse(allNotes[index].noteDate!)),
                                style: const TextStyle(color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Content: ${allNotes[index].noteContent!}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                onPressed: () =>
                                    _notDelete(allNotes[index].noteID),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.redAccent, fontSize: 20),
                                )),
                            TextButton(
                                onPressed: () {
                                  pushDetailPage(context, allNotes[index]);
                                },
                                child: const Text(
                                  'Update',
                                  style: TextStyle(
                                      color: Colors.orangeAccent, fontSize: 20),
                                )),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              );
            },
            itemCount: allNotes.length,
          );
        } else {
          return const Center(
            child: Text('Update'),
          );
        }
      },
    );
  }

  pushDetailPage(BuildContext context, Note note) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              NoteDetail(title: 'Update Note', updateNote: note),
        ));
  }

  _primacyIcon(int? notePrimacy) {
    switch (notePrimacy) {
      case 0:
        return const CircleAvatar(
          backgroundColor: Colors.transparent,
          child:
              Icon(Icons.notification_important, color: Colors.red, size: 40),
        );
        break;

      case 1:
        return const CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(Icons.notification_important,
              color: Colors.orangeAccent, size: 40),
        );
        break;

      case 2:
        return const CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Icon(
            Icons.notification_important,
            color: Colors.green,
            size: 40,
          ),
        );
        break;
    }
  }

  _notDelete(int? noteID) {
    _databaseHelper.noteDelete(noteID!).then((deleteValue) => noteID != 0
        ? ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Note Deleted')))
        : Container());
    setState(() {});
  }
}
