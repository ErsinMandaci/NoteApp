import 'package:flutter/material.dart';
import 'package:flutter_note_app/models/notes.dart';
import 'package:flutter_note_app/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'models/category.dart';

class NoteDetail extends StatefulWidget {
  String title;
  Note? updateNote;

  NoteDetail({required this.title, this.updateNote});

  @override
  State<NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var formKey = GlobalKey<FormState>();

  late List<Category> allCategory;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  int? categoryID;
  int? selectedPrimacy;
  String? noteTitle, notContent;
  static var _primacy = ['Düşük', 'Orta', 'Yüksek'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    allCategory = <Category>[];
    _databaseHelper = DatabaseHelper();
    _databaseHelper.getCategory().then((value) {
      for (Map<String, dynamic> categoryMap in value) {
        allCategory.add(Category.fromMap(categoryMap));
      }

      if(widget.updateNote != null) {
            categoryID = widget.updateNote!.categoryID;
            selectedPrimacy = widget.updateNote!.notePrimacy;
      } else {
        categoryID = 1;
        selectedPrimacy = 0;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: allCategory.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
            key: formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Category: ',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 14),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.redAccent, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                            items: selectedCategoryItem(),
                            value:categoryID,
                            onChanged: (value) {
                              setState(() {
                                categoryID = value;
                              });
                            }),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: widget.updateNote != null
                        ? widget.updateNote!.noteName
                        : "",
                    validator: (text) {
                      if (text!.length < 3) {
                        return 'En az 3 karakter olmalı';
                      }
                      return null;
                    },
                    onSaved: (text) {
                      noteTitle = text;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Note Title',
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    initialValue: widget.updateNote != null
                        ? widget.updateNote!.noteContent
                        : "",
                    onSaved: (text) {
                      notContent = text;
                    },
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Note Content',
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Primacy: ',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 14),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.redAccent, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          items: _primacy
                              .map((e) => DropdownMenuItem(
                                    value: _primacy.indexOf(e),
                                    child: Text(e),
                                  ))
                              .toList(),
                          value:selectedPrimacy,
                          onChanged: (value) {
                            setState(() {
                              selectedPrimacy = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.grey),
                      ),
                      child: const Text('Give Up'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          formKey.currentState!.save();

                          var now = DateTime.now();
                          if (widget.updateNote == null) {
                            _databaseHelper
                                .addNote(Note(
                                    categoryID,
                                    noteTitle,
                                    notContent,
                                    now.toString(),
                                    selectedPrimacy))
                                .then((value) {
                              if (value != 0) {
                                setState(() {

                                });
                                Navigator.pop(context);

                              }
                            });
                          } else {
                            _databaseHelper
                                .updateNote(Note.withID(
                                    widget.updateNote!.noteID,
                                    categoryID,
                                    noteTitle,
                                    notContent,
                                    now.toString(),
                                    selectedPrimacy))
                                .then((value) {
                              if (value != 0) {

                                Navigator.pop(context);

                              }
                            });
                          }
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.redAccent.shade700)),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  List<DropdownMenuItem<int>> selectedCategoryItem() {
    return allCategory
        .map(
          (category) => DropdownMenuItem<int>(
            value: category.categoryID,
            child: Text(
              category.categoryName!,
              style: TextStyle(
                fontSize: 22,
              ),
            ),
          ),
        )
        .toList();
  }
}

/*
 Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: allCategory.isEmpty
                  ? const CircularProgressIndicator()
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 48),
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.redAccent, width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: DropdownButton<int>(
                          underline: const SizedBox(),
                          items: SelectedCategoryItem(),
                          value: categoryID,
                          onChanged: (value) {
                            setState(() {
                              categoryID = value;
                            });
                          }),
                    ),
            )
          ],
        ),
      ),


*/
