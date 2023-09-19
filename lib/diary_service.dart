import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'diary_class.dart';

class DiaryService extends ChangeNotifier {
  List<DayDiaries> diaryDB = [];

  DiaryService() {
    loadData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(diaryDB.map((e) => e.toJson()).toList());
    await prefs.setString('diaryDB', jsonString);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('diaryDB');
    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      diaryDB = jsonList.map((e) => DayDiaries.fromJson(e)).toList();
    }
    notifyListeners();
  }

  void addDiary(String content, DateTime date) {
    DateTime now = DateTime.now();
    Diary newDiary = Diary(content, now);
    DayDiaries? targetDayDiaries;

    for (var dayDiaries in diaryDB) {
      if (isSameDay(dayDiaries.date, date)) {
        targetDayDiaries = dayDiaries;
        break;
      }
    }

    if (targetDayDiaries != null) {
      targetDayDiaries.dayDiaryList.add(newDiary);
      targetDayDiaries.count++;
    } else {
      diaryDB.add(DayDiaries([newDiary], date, 1));
    }

    notifyListeners();

    saveData();
  }

  void editDiary(Diary diary, String newContent) {
    DateTime now = DateTime.now();

    diary.content = newContent;
    diary.writingTime = now;

    notifyListeners();

    saveData();
  }

  void removeDiary(Diary diary, DateTime date) {
    DayDiaries? targetDayDiaries;

    for (var dayDiaries in diaryDB) {
      if (isSameDay(dayDiaries.date, date)) {
        targetDayDiaries = dayDiaries;
        break;
      }
    }

    if (targetDayDiaries != null) {
      targetDayDiaries.dayDiaryList.remove(diary);
      targetDayDiaries.count--;
    } else {
      diaryDB.remove(DayDiaries([diary], date, 1));
    }

    notifyListeners();

    saveData();
  }
}
