class Note {
  int? noteID;
  int? categoryID;
  String? categoryTitle;
  String? noteName;
  String? noteContent;
  String? noteDate;
  int? notePrimacy;

  Note.withID(this.noteID, this.categoryID, this.noteName, this.noteContent,
      this.noteDate, this.notePrimacy);

  Note(this.categoryID, this.noteName, this.noteContent,this.noteDate,
      this.notePrimacy);

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['noteID'] = this.noteID;
    map['categoryID'] = this.categoryID;
    map['noteName'] = this.noteName;
    map['noteContent'] = this.noteContent;
    map['noteDate'] = this.noteDate;
    map['notePrimacy'] = this.notePrimacy;

    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    noteID = map['noteID'];
    categoryID = map['categoryID'];
    categoryTitle = map['categoryName'];
    noteName = map['noteName'];
    noteContent = map['noteContent'];
    noteDate = map['noteDate'];
    notePrimacy = map['notePrimacy'];
  }

  @override
  String toString() {
    return 'Note{noteID: $noteID, categoryID: $categoryID, noteName: $noteName, noteContent: $noteContent, noteDate: $noteDate, notePrimacy: $notePrimacy}';
  }
}
