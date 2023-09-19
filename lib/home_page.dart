import 'package:diary/diary_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import 'diary_class.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat userCalendarFormat = CalendarFormat.month;
  DateTime userSelectedDay = DateTime.now();
  DateTime userFocusedDay = DateTime.now();
  DateTime userFirstDay = DateTime.utc(2023, 01, 01);
  DateTime userLastDay = DateTime.utc(2030, 12, 31);

  TextEditingController textEditingController = TextEditingController();
  String? textFieldError;

  Color mainColor = Colors.indigo;
  Color whiteColor = Colors.white;

  List<Diary> getuserSelectedDayDiaries(List<DayDiaries> diaryDB) {
    for (var dayDiaries in diaryDB) {
      if (isSameDay(dayDiaries.date, userSelectedDay)) {
        return dayDiaries.dayDiaryList;
      }
    }
    return [];
  }

  void showAddDiaryDialog(BuildContext context, DateTime date) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: ((context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("일기 작성"),
              content: TextField(
                controller: textEditingController,
                decoration: InputDecoration(
                  hintText: "일기를 작성해주세요",
                  hintStyle: TextStyle(fontSize: 15),
                  errorText: textFieldError,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: mainColor),
                  ),
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      textFieldError = null;
                    });
                    Navigator.of(context).pop();
                    textEditingController.clear();
                  },
                  child: Text(
                    "취소",
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteColor,
                    elevation: 0,
                  ),
                  onPressed: () {
                    String newContent = textEditingController.text;

                    if (newContent.isEmpty) {
                      setState(() {
                        textFieldError = "내용을 입력해주세요";
                      });
                    } else {
                      setState(() {
                        textFieldError = null;
                      });
                      context.read<DiaryService>().addDiary(newContent, date);
                      textEditingController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "작성",
                    style: TextStyle(
                      color: mainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  void showEditDiaryDialog(BuildContext context, Diary diary) {
    TextEditingController textEditingController =
        TextEditingController(text: diary.content);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("일기 수정"),
          content: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              hintText: "일기를 수정해주세요",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: mainColor),
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: whiteColor,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "취소",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: whiteColor,
                elevation: 0,
              ),
              onPressed: () {
                String updatedContent = textEditingController.text;
                if (updatedContent.isNotEmpty) {
                  context.read<DiaryService>().editDiary(diary, updatedContent);
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                "수정",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showRemoveDiaryDialog(BuildContext context, Diary diary) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("일기 삭제"),
          content: Text("'${diary.content}'를 삭제하시겠습니까?"),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: whiteColor,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "취소",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: whiteColor,
                elevation: 0,
              ),
              onPressed: () {
                context
                    .read<DiaryService>()
                    .removeDiary(diary, userSelectedDay);
                Navigator.of(context).pop();
              },
              child: Text(
                "삭제",
                style: TextStyle(
                  color: mainColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryService>(
      builder: (context, diaryService, child) {
        List<DayDiaries> diaryDB = diaryService.diaryDB;

        var userSelectedDayDiaries = getuserSelectedDayDiaries(diaryDB);

        return Scaffold(
          body: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.width * 0.05),
              TableCalendar(
                locale: 'ko_KR',
                calendarFormat: userCalendarFormat,
                focusedDay: userFocusedDay,
                firstDay: userFirstDay,
                lastDay: userLastDay,
                selectedDayPredicate: (day) => isSameDay(day, userSelectedDay),
                headerStyle: HeaderStyle(
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMMd(locale).format(date),
                  formatButtonVisible: false,
                  titleTextStyle: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: isSameDay(userSelectedDay, DateTime.now())
                        ? mainColor
                        : Color.fromARGB(126, 63, 81, 181),
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  for (var dayDiaries in diaryDB) {
                    if (isSameDay(dayDiaries.date, day)) {
                      return List.generate(
                        dayDiaries.count,
                        (index) => index,
                      );
                    }
                  }
                  return [];
                },
                onFormatChanged: (format) {
                  setState(() {
                    userCalendarFormat = format;
                  });
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    userFocusedDay = focusedDay;
                    userSelectedDay = selectedDay;
                  });
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: userSelectedDayDiaries.length,
                  itemBuilder: (context, index) {
                    var diary = userSelectedDayDiaries[index];
                    return ListTile(
                      title: Text(
                        diary.content,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Text(
                        "${diary.writingTime.hour}:${diary.writingTime.minute}",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        showEditDiaryDialog(context, diary);
                      },
                      onLongPress: () {
                        showRemoveDiaryDialog(context, diary);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: mainColor,
            child: Icon(
              CupertinoIcons.pencil_outline,
            ),
            onPressed: () {
              showAddDiaryDialog(context, userSelectedDay);
            },
          ),
        );
      },
    );
  }
}
