import 'package:flutter/material.dart';
import 'package:flutter_tutorial/Objects/ExpenseNote.dart';
import 'package:flutter_tutorial/Objects/ListOfExpenses.dart';
import 'package:flutter_tutorial/Utility/Storage.dart';
import 'package:flutter_tutorial/pages/ListOfExpensesCategories.dart';
import 'package:flutter_tutorial/setting/MyColors.dart';
import 'package:flutter_tutorial/setting/MyText.dart';

class AddExpenses extends StatefulWidget{
  final Function callBack;
  AddExpenses({this.callBack});

  @override
  _AddExpensesState createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {

  DateTime date = DateTime.now();
  String category = '';
  double sum;
  List<String> _list = [];

  initList() async{
    _list = await Storage.getList('Expenses');
    _list == null || _list.isEmpty ? category = 'category' : category = _list[0];
    setState(() {});
  }

  @override
  void initState() {
    initList();
    super.initState();
  }

  void s(String cat){
    setState(() {
      category = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backGroudColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: MyColors.textColor
        ),
        backgroundColor: MyColors.appBarColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText('Add Expenses'),
            IconButton(
              iconSize: 35,
              icon: Icon(
                Icons.done,
                color: MyColors.textColor,
              ),
              onPressed: (){
                if (category == "category") return;
                _createExpenseNote(date, category, sum);
                widget.callBack();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
      body: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            GestureDetector(
              child: MyText(
                date.toString().substring(0, 10),
                TextAlign.left,
              ),
              onTap: _onDateTap
            ),
            Divider(),
            GestureDetector(
              child: MyText(category),
              onTap: () => _onCategoryTap(context),
            ),
            Divider(),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Enter sum',
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter sum';
                }
                return null;
              },
              onChanged: (v) => sum = double.parse(v),
            ),
          ],
        ),
      ),
    );
  }

  _onDateTap() async{
      final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 184)),
        firstDate: DateTime.now().subtract(Duration(days: 184)),
      );
      setState(() {
        date = picked;
      });
  }

  _onCategoryTap(BuildContext context){
    Navigator.push(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context){
              return ListOfExpensesCategories(callback: s, cat: category);
            }
        )
    );
  }

  _createExpenseNote(DateTime date, String category, double sum){
    ExpenseNote expenseNote = ExpenseNote(date, category, sum);
    ListOfExpenses.add(expenseNote);
  }
}

