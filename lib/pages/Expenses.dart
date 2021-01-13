import 'dart:convert';
import 'package:flutter/material.dart';
import '../setting/SecondaryLocalText.dart';
import '../setting/SecondaryText.dart';
import '../Utility/appLocalizations.dart';
import '../widgets/customSnackBar.dart';
import '../setting/MainLocalText.dart';
import '../setting/DateFormatText.dart';
import '../setting/ThirdText.dart';
import '../pages/EditPageForExpenseCategory.dart';
import '../Objects/ExpenseNote.dart';
import '../Objects/ListOfExpenses.dart';
import '../Utility/Storage.dart';
import '../setting/MyColors.dart';
import '../setting/MainRowText.dart';

class Expenses extends StatefulWidget {
  final Function updateMainPage;

  Expenses({this.updateMainPage});

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  DateTime date = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
  String selectedMode = 'День';
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  List<double> listForAvgFunc = [];

  @override
  void initState() {
    loadExpensesList();
    super.initState();
  }

  void loadExpensesList() async {
    String m = await Storage.getString('ExpenseNote');
    if (m != null) {
      setState(() {
        ListOfExpenses.fromJson(jsonDecode(m));
      });
    }
  }

  void updateExpensesPage() {
    setState(() {});
  }

  void updateDate(DateTime dateTime) {
    setState(() {
      date = dateTime;
    });
  }

  void undoDelete(ExpenseNote note, int index) async {
    if (index < ListOfExpenses.list.length)
      ListOfExpenses.list.insert(index, note);
    else
      ListOfExpenses.list.add(note);

    await Storage.saveString(
        jsonEncode(new ListOfExpenses().toJson()), 'ExpenseNote');
    updateExpensesPage();
  }

  double totalSum(List list) {
    double total = 0;
    for (int i = 0; i < list.length; i++) {
      total += list[i].sum;
    }
    return total;
  }

  String averageFunc(List list) {
    double average;
    double sum = 0;
    for (int i = 0; i < list.length; i++) {
      sum += list[i];
    }
    average = sum / list.length;
    return average.toStringAsFixed(2);
  }

  // function to only one view mode 'Неделя(Д)'
  String sumByDay(int day, List list) {
    double sum = 0;
    for (int i = 0; i < list.length; i++) {
      if (list[i].date.weekday == day) sum += list[i].sum;
    }
    if (sum > 0) listForAvgFunc.add(sum);
    return sum.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: MyColors.backGroundColor,
        //bottomNavigationBar: buildBottomAppBar(),
        appBar: buildAppBar(),
        body: buildBody(),
      ),
    );
  }

  Widget buildAppBar() {
    return AppBar(
      shadowColor: Colors.black,
      iconTheme: IconThemeData(color: MyColors.textColor),
      backgroundColor: MyColors.mainColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [MainLocalText(text: 'Расход'), buildDropdownButton()],
      ), // dropdown menu button
    );
  }

  Widget buildBody() {
    List categoriesList = filteredExpenses();
    categoriesList.sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        _getData(),
        Divider(),
        categoriesList.isEmpty
            ? Expanded(
                child: Center(child: MainLocalText(text: 'Расходов нет')))
            : Padding(
                padding: EdgeInsets.only(left: 15, right: 20),
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MainLocalText(text: 'Итого'),
                      MainRowText(text: totalSum(categoriesList).toStringAsFixed(2))
                    ],
                  ),
                ),
              ),
        //Divider(color: MyColors.textColor),
        selectedMode == 'Неделя(Д)' && categoriesList.isNotEmpty
            ? Expanded(
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Mon'),
                                  SecondaryText(
                                      text: sumByDay(1, categoriesList)),
                                ],
                            ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(1, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        1, categoriesList), 1),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Tue'),
                                  SecondaryText(
                                      text: sumByDay(2, categoriesList)),
                                ],
                            ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(2, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        2, categoriesList), 2),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Wed'),
                                  SecondaryText(
                                      text: sumByDay(3, categoriesList)),
                                ],
                            ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(3, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        3, categoriesList), 3),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Thu'),
                                  SecondaryText(
                                      text: sumByDay(4, categoriesList)),
                                ],
                            ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(4, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        4, categoriesList), 4),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Fri'),
                                  SecondaryText(
                                      text: sumByDay(5, categoriesList)),
                                ],
                            ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(5, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        5, categoriesList), 5),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Sat'),
                                  SecondaryText(
                                      text: sumByDay(6, categoriesList)),
                                ],
                              ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(6, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        6, categoriesList), 6),
                              )
                            ],
                          ),
                          ExpansionTile(
                            title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SecondaryLocalText(text: 'Sun'),
                                  SecondaryText(
                                      text: sumByDay(7, categoriesList)),
                                ],
                              ),
                            backgroundColor: MyColors.backGroundColor,
                            onExpansionChanged: (e) {},
                            children: [
                              Container(
                                height: _childrenListLength(
                                    getFilteredChildrenListByDay(7, categoriesList)),
                                child: getExpandedChildrenForDay(
                                    getFilteredChildrenListByDay(
                                        7, categoriesList), 7),
                              )
                            ],
                          ),
                        ],
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MainLocalText(text: 'Среднее за день'),
                            MainRowText(
                                text: averageFunc(listForAvgFunc).toString())
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Expanded(
                child: ListView.builder(
                    itemCount: categoriesList.length,
                    itemBuilder: (context, index) {
                      ExpenseNote singleCategory = categoriesList[index];
                      List<ExpenseNote> childrenList =
                          getFilteredChildrenOfCategory(singleCategory);
                      childrenList.sort((a, b) => b.date.compareTo(a.date));

                      return ExpansionTile(
                        title: Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SecondaryText(text: singleCategory.category),
                              SecondaryText(text: singleCategory.sum.toStringAsFixed(2)),
                            ],
                          ),
                        ),
                        backgroundColor: MyColors.backGroundColor,
                        onExpansionChanged: (e) {},
                        children: [
                          Container(
                            height: _childrenListLength(childrenList),
                            //height: 200, // how to optimize height to max needed
                            child: getExpandedChildrenForCategory(childrenList),
                          )
                        ],
                      );
                    }),
              )
      ],
    );
  }

  Widget buildBottomAppBar() {
    return BottomAppBar(
      child: Container(
        decoration: BoxDecoration(
            color: MyColors.mainColor,
            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5)]),
        height: 60,
        child: Padding(
          padding: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context)),
              MainLocalText(text: 'Расход'),
              buildDropdownButton(),
            ],
          ),
        ),
      ),
    );
  }

  double _childrenListLength(List list) {
    double height;
    if (list.length >= 5) {
      height = 250;
    } else {
      height = list.length.toDouble() * 50;
    }
    return height;
  }

  // creating main list according to date filter
  List filteredExpenses() {
    List middleList = List();
    for (int i = 0; i < ListOfExpenses.list.length; i++) {
      if (_isInFilter(ListOfExpenses.list[i].date))
        middleList.add(ListOfExpenses.list[i]);
    }
    List resultList = List();
    for (int i = 0; i < middleList.length; i++) {
      bool isFound = false;
      ExpenseNote currentExpenseNote = middleList[i];

      for (ExpenseNote E in resultList) {
        if (currentExpenseNote.category == E.category) {
          isFound = true;
          break;
        }
      }
      if (isFound) continue;

      double sum = middleList[i].sum;
      for (int j = i + 1; j < middleList.length; j++) {
        if (currentExpenseNote.category == middleList[j].category)
          sum += middleList[j].sum;
      }
      resultList.add(ExpenseNote(
          date: currentExpenseNote.date,
          category: currentExpenseNote.category,
          sum: sum,
          comment: currentExpenseNote.comment));
    }
    if (selectedMode == 'Неделя(Д)')
      return middleList;
    else
      return resultList;
  }

  List<ExpenseNote> getFilteredChildrenOfCategory(ExpenseNote expenseNote, {int day}) {
    List<ExpenseNote> childrenList = [];
    if(selectedMode != 'Неделя(Д)') {
      for (int i = 0; i < ListOfExpenses.list.length; i++) {
        if (_isInFilter(ListOfExpenses.list[i].date) &&
            ListOfExpenses.list[i].category == expenseNote.category)
          childrenList.add(ListOfExpenses.list[i]);
      }
    }
    else{
      for (int i = 0; i < ListOfExpenses.list.length; i++) {
        if (_isInFilter(ListOfExpenses.list[i].date) &&
            ListOfExpenses.list[i].date.weekday == day &&
            ListOfExpenses.list[i].category == expenseNote.category)
          childrenList.add(ListOfExpenses.list[i]);
      }
    }
    return childrenList;
  }

  List<ExpenseNote> getFilteredChildrenListByDay(int day, List list) {
    List<ExpenseNote> middleByDayList = [];
    for (int i = 0; i < list.length; i++) {
      if (list[i].date.weekday == day) middleByDayList.add(list[i]);
    }
    List<ExpenseNote> resultByDayList = List();
    for (int i = 0; i < middleByDayList.length; i++) {
      bool isFound = false;
      ExpenseNote currentExpenseNote = middleByDayList[i];

      for (ExpenseNote E in resultByDayList) {
        if (currentExpenseNote.category == E.category) {
          isFound = true;
          break;
        }
      }
      if (isFound) continue;

      double sum = middleByDayList[i].sum;
      for (int j = i + 1; j < middleByDayList.length; j++) {
        if (currentExpenseNote.category == middleByDayList[j].category)
          sum += middleByDayList[j].sum;
      }
      resultByDayList.add(ExpenseNote(
          date: currentExpenseNote.date,
          category: currentExpenseNote.category,
          sum: sum,
          comment: currentExpenseNote.comment));
    }
    return resultByDayList;
  }

  // list which extract single notes from category (nested list)
  ListView getExpandedChildrenForCategory(List<ExpenseNote> middleList) {
    // ListView.getChildren and expanded to children
    return ListView.builder(
        itemCount: middleList.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: boolComment(middleList[index]),
                    ),
                    Row(
                      children: [
                        SecondaryText(
                            text: middleList[index].sum.toStringAsFixed(2),
                            color: Colors.black54),
                        IconButton(
                          icon: Icon(Icons.edit),
                          color: Colors.black54,
                          onPressed: () => goToEditPage(
                            context,
                            middleList[index],
                          ),
                        ),
                        IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.black54,
                            onPressed: () async {
                              int indexInListOfExpenses = ListOfExpenses.list
                                  .indexOf(middleList[index]);
                              CustomSnackBar.show(
                                  key: scaffoldKey,
                                  context: context,
                                  text: AppLocalizations.of(context)
                                      .translate('Заметка удалена'),
                                  callBack: () {
                                    undoDelete(middleList[index],
                                        indexInListOfExpenses);
                                  });
                              ListOfExpenses.list.remove(middleList[index]);
                              await Storage.saveString(
                                  jsonEncode(new ListOfExpenses().toJson()),
                                  'ExpenseNote');
                              widget.updateMainPage();
                              updateExpensesPage();
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  // ListView getExpandedChildrenForDay(List list, int day) {
  //   return ListView.builder(
  //       itemCount: list.length,
  //       itemBuilder: (context, index) {
  //         ExpenseNote singleCategory = list[index];
  //         List<ExpenseNote> childrenList =
  //         getFilteredChildrenOfCategory(singleCategory, day: day);
  //         childrenList.sort((a, b) => b.date.compareTo(a.date));
  //
  //         return ExpansionTile(
  //           title: Padding(
  //             padding: EdgeInsets.only(left: 5),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 SecondaryText(text: list[index].category, color: MyColors.secondTextColor),
  //                 SecondaryText(text: '${list[index].sum}', color: MyColors.secondTextColor),
  //               ],
  //             ),
  //           ),
  //           backgroundColor: MyColors.backGroundColor,
  //           onExpansionChanged: (e) {},
  //           children: [
  //             Container(
  //               height: _childrenListLength(childrenList),
  //               //height: 200, // how to optimize height to max needed
  //               child: getExpandedChildrenForCategory(childrenList),
  //             )
  //           ],
  //         );
  //       });
  // }

  ListView getExpandedChildrenForDay(List list, int day) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        return Container(
          height: 50,
          child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25 ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SecondaryText(text: list[index].category, color: MyColors.secondTextColor),
                SecondaryText(
                    text: list[index].sum.toStringAsFixed(2),
                    color: MyColors.secondTextColor
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  boolComment(ExpenseNote note) {
    if (note.comment == '' || note.comment == null) {
      return DateFormatText(
          dateTime: note.date,
          mode: 'Дата в строке',
          color: MyColors.secondTextColor);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DateFormatText(
              dateTime: note.date,
              mode: 'Дата в строке',
              color: MyColors.secondTextColor),
          comment(note),
        ],
      );
    }
  }

  goToEditPage(BuildContext context, ExpenseNote expenseNote) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return EditPageForExpenseCategory(
          updateExpensePage: updateExpensesPage,
          updateMainPage: widget.updateMainPage,
          note: expenseNote);
    }));
  }

  comment(ExpenseNote note) {
    if (note.comment == null)
      return ThirdText('');
    else
      return SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: ThirdText(note.comment));
  }

  // dropdown menu button
  Widget buildDropdownButton() {
    return DropdownButton(
        hint: MainLocalText(text: selectedMode),
        items: [
          DropdownMenuItem(value: 'День', child: MainLocalText(text: 'День')),
          DropdownMenuItem(
              value: 'Неделя', child: MainLocalText(text: 'Неделя')),
          DropdownMenuItem(
              value: 'Неделя(Д)', child: MainLocalText(text: 'Неделя(Д)')),
          DropdownMenuItem(value: 'Месяц', child: MainLocalText(text: 'Месяц')),
          DropdownMenuItem(value: 'Год', child: MainLocalText(text: 'Год')),
        ],
        onChanged: (String newValue) {
          // if (selectedMode != 'Неделя' && newValue == 'Неделя') {
          //   int weekDay = Localizations.localeOf(context).languageCode == 'ru' ||
          //       Localizations.localeOf(context).languageCode == 'uk' ? date.weekday : date.weekday + 1;
          //   date = date.subtract(Duration(days: weekDay)).add(Duration(days: 7));
          // }
          //
          // if (selectedMode == 'Неделя' && newValue != 'Неделя') {
          //   date = DateTime.now();
          // }
          selectedMode = newValue;
          updateExpensesPage();
        });
  }

  // date filter function
  _isInFilter(DateTime d) {
    if (d == null) return false;

    switch (selectedMode) {
      case 'День':
        return d.year == date.year &&
            d.month == date.month &&
            d.day == date.day;
        break;
      case 'Неделя':
        int weekDay = Localizations.localeOf(context).languageCode == 'ru' ||
                Localizations.localeOf(context).languageCode == 'uk'
            ? date.weekday
            : date.weekday + 1;
        DateTime nextWeekFirstDay =
            date.subtract(Duration(days: weekDay)).add(Duration(days: 8));
        return d.isAfter(nextWeekFirstDay.subtract(Duration(days: 8))) &&
            d.isBefore(nextWeekFirstDay);
        break;
      case 'Неделя(Д)':
        int weekDay = Localizations.localeOf(context).languageCode == 'ru' ||
                Localizations.localeOf(context).languageCode == 'uk'
            ? date.weekday
            : date.weekday + 1;
        DateTime nextWeekFirstDay =
            date.subtract(Duration(days: weekDay)).add(Duration(days: 8));
        return d.isAfter(nextWeekFirstDay.subtract(Duration(days: 8))) &&
            d.isBefore(nextWeekFirstDay);
        break;
      case 'Месяц':
        return d.year == date.year && d.month == date.month;
        break;
      case 'Год':
        return d.year == date.year;
        break;
    }
  }

  // function return date with buttons
  _getData() {
    switch (selectedMode) {
      case 'День':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  date = date.subtract(Duration(days: 1));
                });
              },
            ),
            DateFormatText(dateTime: date, mode: selectedMode),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  date = date.add(Duration(days: 1));
                });
              },
            ),
          ],
        );
      case 'Неделя':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  date = date.subtract(Duration(days: 7));
                });
              },
            ),
            DateFormatText(dateTime: date, mode: selectedMode),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  date = date.add(Duration(days: 7));
                });
              },
            ),
          ],
        );
      case 'Неделя(Д)':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  date = date.subtract(Duration(days: 7));
                });
              },
            ),
            DateFormatText(dateTime: date, mode: selectedMode),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  date = date.add(Duration(days: 7));
                });
              },
            ),
          ],
        );
      case 'Месяц':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  date = new DateTime(date.year, date.month - 1, date.day);
                });
              },
            ),
            DateFormatText(dateTime: date, mode: selectedMode),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  date = DateTime(date.year, date.month + 1, date.day);
                });
              },
            ),
          ],
        );
      case 'Год':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                setState(() {
                  date = new DateTime(date.year - 1, date.month, date.day);
                });
              },
            ),
            DateFormatText(dateTime: date, mode: selectedMode),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                setState(() {
                  date = DateTime(date.year + 1, date.month, date.day);
                });
              },
            ),
          ],
        );
    }
  }
}
