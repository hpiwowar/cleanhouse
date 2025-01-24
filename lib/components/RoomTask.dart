import 'package:cleanhouse/pages/CleaningDetailPage.dart';

class RoomTask {
  String id = 'abc';
  String room_id = '234';
  String room_name = 'Temp Room';
  String task_id = 'sdf';
  String task_name = 'Temp Task';
  String most_recent_cleaning = DateTime.now().toString();
  int period_days = 1;
  late String full_name = "$room_name $task_name";
  late double score = calculateScore();
  late bool isQuick = this.task_name.contains('quick');
  late bool isDeep = this.task_name.contains('deep');
  late String display_task_name = this.task_name.toTitleCase.replaceAll('Deep ','').replaceAll('Quick ', '');
  late String display_room_name = this.room_name.toTitleCase;

  RoomTask(
      {required this.id,
      required this.room_id,
      required this.task_id,
      required this.room_name,
      required this.task_name,
      required this.most_recent_cleaning,
      required period_days});

  RoomTask.fromMap(Map myMap) {
    id = myMap["id"];
    room_id = myMap["room_name"];
    task_id = myMap["task_id"];
    room_name = myMap["room_name"];
    task_name = myMap["task_name"];
    most_recent_cleaning = myMap["most_recent_cleaning"];
    period_days = myMap["period_days"];
  }

  double calculateScore() {
    final mostRecentCleaningDatetime = DateTime.parse(most_recent_cleaning);
    final now = DateTime.now();
    final daysSinceLastCleaning =
        now.difference(mostRecentCleaningDatetime).inDays;

    final daysTillNextDue = period_days - daysSinceLastCleaning;
    double percentOverdue = 0.0;
    if (daysTillNextDue < 0) {
      percentOverdue = daysTillNextDue / period_days;
    }
    return (percentOverdue);
  }
}
