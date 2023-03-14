class Category {
  int? categoryID;
  String? categoryName;


  Category.withID(this.categoryID,this.categoryName); // category use for read db

  Category(this.categoryName);     // ıd to generate db



  Map<String,dynamic> toMap() {
    var map = Map<String,dynamic>();

    map['categoryID'] = this.categoryID;
    map['categoryName'] = this.categoryName;

    return map;
  }

  Category.fromMap(Map<String,dynamic> map) {
    this.categoryID = map['categoryID'];
    this.categoryName = map['categoryName'];
  }

  @override
  String toString() {
    return 'Category{categoryID: $categoryID, categoryName: $categoryName}';
  }
}