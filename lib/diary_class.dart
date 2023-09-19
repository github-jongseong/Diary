class Diary {
  String content; // 내용
  DateTime writingTime; // 일기를 작성한 시간

  Diary(this.content, this.writingTime);

  Map<String, dynamic> toJson() => {
        'content': content,
        'writingTime': writingTime.toIso8601String(),
      };

  factory Diary.fromJson(Map<String, dynamic> json) {
    return Diary(
      json['content'] as String,
      DateTime.parse(json['writingTime'] as String),
    );
  }
}

class DayDiaries {
  List<Diary> dayDiaryList; // 날짜에 작성한 일기 리스트
  DateTime date; // 날짜
  int count; // 날짜에 배정된 일기 수

  DayDiaries(this.dayDiaryList, this.date, this.count);

  Map<String, dynamic> toJson() => {
        'dayDiaryList': dayDiaryList.map((e) => e.toJson()).toList(),
        'date': date.toIso8601String(),
        'count': count,
      };

  factory DayDiaries.fromJson(Map<String, dynamic> json) {
    var list = json['dayDiaryList'] as List;
    List<Diary> diaryList = list.map((e) => Diary.fromJson(e)).toList();

    return DayDiaries(
      diaryList,
      DateTime.parse(json['date'] as String),
      json['count'] as int,
    );
  }
}
