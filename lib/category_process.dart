import 'package:flutter/material.dart';
import 'package:flutter_note_app/utils/database_helper.dart';

import 'models/category.dart';

class Categories extends StatefulWidget {
  const Categories({Key? key}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {

   List<Category>? allCategories;
  late DatabaseHelper databaseHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    databaseHelper = DatabaseHelper();
  }
  @override
  Widget build(BuildContext context) {

    if(allCategories == null) {
      allCategories = <Category>[];
      categoryListUpdate();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body:ListView.builder(itemCount: allCategories?.length,itemBuilder: (context, index) {

        return ListTile(
          onTap: () =>_updateCategory(allCategories?[index]),
          trailing: GestureDetector(
              onTap:()=> _deleteCategory(allCategories?[index].categoryID),
              child: const Icon(Icons.delete)),
          leading: const Icon(Icons.category),
          title: Text(allCategories![index].categoryName!),


        );
      },)
    );
  }

  void categoryListUpdate() {
    databaseHelper?.getCategoryList().then((categoryList) {
          setState(() {
            allCategories = categoryList;
          });
    });
  }

  _deleteCategory(int? categoryID) {

    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: const Text('Are you sure ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Delete all notes when category is deleted'),
            ButtonBar(
              children: [
                TextButton(onPressed: (){
                  Navigator.of(context).pop();
                }, child: const Text('Give Up')),
                TextButton(onPressed: (){

                  databaseHelper.deleteCategory(categoryID!).then((deletedCategory) {
                    if(deletedCategory !=0) {
                      setState(() {
                            categoryListUpdate();
                            Navigator.pop(context);
                      });
                    }
                  });
                }, child: const Text('Delete Category',style: TextStyle(color: Colors.red),)),
              ],
            )
          ],
        ),
      );
    },);

  }

  _updateCategory(Category? allCategori) {

  }
}
