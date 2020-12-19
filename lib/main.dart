import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data_utils.dart';

void main() {
  runApp(MyApp());
}

const String SHEET_ID = "1SG6MIgfU4koBzIUCcKWOR1UuzkTMkQVVYxMh2p_pCpU";

const String SHEET_NAME = "og_questions";

String DATA = """"Grandma's favorite clothing store","Blair",,,,
"Grandma's 10pm tv show","Judge Judy",,,,
"What year was Grandma Born",1936,,,,
Sarah's Major,Hospitality & tourism,Event planning,business,,
On the bone or off the bone,"always, off the bone",,,,
what was lost in the tuzzolo fire,everything,,,,
how many mount vesuvius,3,,,,
appliance gpa breaks and steph fixes,fax machine ,,,,
little michael's favorite toy @ 5,legos,,,,
Who went to rehab first; Grandma or Grandpa?,grandma,,,,
"Who claims all of her medical problems root back to this one incident, and what happened?",Sally got hit by a car,,,,
Who got into a fist fight right in this backyard?,John ,Zeppi,,,
Which relatives met each other when they were 7 year's old?,Aunt Carol,Uncle Anthony,,,
Who is Grandma's favorite Fox News anchor?,Bill O'Reilly,,,,
What is Aunt Millie's political party for voting?,Independent,,,,
How many members of the family are NOT catholic?,Grandma,John,,,
What was the only year and election where Grandma DID NOT Vote republican,"1993, Bill Clinton",,,,
What is Aunt Millie's Favorite BBQ food?,Hotdogs,,,,
"Nail Picasso used to be a staple for the Tuzzolo's, name one of our favorite girls who did our nails.",Maria,Sophia,Jenny,Lordes,Nicole
 What is a typical order for Grandma and Grandpa at La Parma,Spaghetti Marinera (full tray),Chicken Scaperelli,,,
What CD plays on loop on Grandpa's outside radio?,"Dean Martin, That's Amore",,,,
Which family member most relates to a character in The Middle?,Katelyn and Sue,,,,
"When Steph and Uncle Mike go get Donuts, it can only mean one thing. What has happened?","Someone's in the hospital
",,,,
What are the 3 most common names in the Tuzzolo family?,Michael,Joe,Anthony,,
What does Grandma want on her Tomb Stone?,Glad that's over with,,,,""";

Future<List<List<dynamic>>> loadAnswers() {
  return getSheet(SHEET_ID, SHEET_NAME);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<List<String>>> answers;

  List<List<bool>> checkedBoxes;

  @override
  void initState() {
    super.initState();

    checkedBoxes = [
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false],
      [false, false, false, false, false]
    ];
    List<String> linearizedAnswers = [];
    answers = loadAnswers().then((allAnswers) {
      var answerResult = [
        ["", "", "", "", ""],
        ["", "", "", "", ""],
        ["", "", "", "", ""],
        ["", "", "", "", ""],
        ["", "", "", "", ""]
      ];

      for (List<dynamic> answerRow
          in allAnswers.getRange(1, allAnswers.length)) {
        List<dynamic> shuffledAnswers =
            answerRow.getRange(1, answerRow.length).toList();
        shuffledAnswers.shuffle();
        linearizedAnswers.add(
            shuffledAnswers.firstWhere((answer) => answer != "") as String);
      }

      linearizedAnswers.shuffle();
      int index = 0;
      for (String answer in linearizedAnswers.take(25)) {
        answerResult[(index / 5).floor()][index % 5] = answer;
        index++;
      }
      return answerResult;
    });
  }

  _getTitleLetter(String s, Color color) {
    return Expanded(
        child: s == "O"
            ? Container(
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.black),
                child: Image.asset("assets/margo.png"))
            : Container(
                color: color,
                child: Center(child: Text(s, style: TextStyle(fontSize: 48)))));
  }

  _getTitleRow() {
    return Row(children: [
      _getTitleLetter("M", Colors.white),
      _getTitleLetter("A", Colors.white),
      _getTitleLetter("R", Colors.white),
      _getTitleLetter("G", Colors.white),
      _getTitleLetter("O", Colors.white),
    ]);
  }

  _getItem(String answer, bool isGreen, int rowNum, int columnNum) {
    List<Widget> children2 = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            decoration: BoxDecoration(
                color: isGreen ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Center(
                child: Text(answer,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold)))),
      ),
    ];
    if (columnNum == 2 && rowNum == 2) {
      children2.add(Positioned.fill(
        child: Container(
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.red),
            child: Image.asset("assets/margo.png")),
      ));
    } else if (checkedBoxes[rowNum][columnNum]) {
      children2.add(Positioned.fill(
          child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.red.withAlpha(100)))));
    }
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            checkedBoxes[rowNum][columnNum] = !checkedBoxes[rowNum][columnNum];
          });
        },
        child: Stack(
          children: children2,
        ),
      ),
    );
  }

  _getRow(List<String> answers, bool isEven, int rowNum) {
    List<Widget> children = [];
    bool isGreen = isEven;
    int columnNum = 0;
    for (String answer in answers) {
      children.add(_getItem(answer, isGreen, rowNum, columnNum));
      isGreen = !isGreen;
      columnNum++;
    }
    return Expanded(child: Row(children: children));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: answers,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var children2 = [
              Expanded(child: _getTitleRow()),
            ];
            bool isEven = true;
            int rowNum = 0;
            for (List<String> answerRow in snapshot.data) {
              children2.add(_getRow(answerRow, isEven, rowNum));
              isEven = !isEven;
              rowNum++;
            }
            return Scaffold(
              body: Column(children: children2),
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
