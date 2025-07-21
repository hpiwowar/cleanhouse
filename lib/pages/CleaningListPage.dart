import 'package:cleanhouse/components/RoomTask.dart';
import 'package:cleanhouse/pages/CleaningDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:libsql_dart/libsql_dart.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:uuid/uuid.dart';

List _myRoomData = [];

class CleaningListPage extends StatefulWidget {
  const CleaningListPage({super.key, required this.title});

  final String title;

  @override
  State<CleaningListPage> createState() => _CleaningListPageState();
}

class _CleaningListPageState extends State<CleaningListPage> {
  @override
  void initState() {
    super.initState();
    _reloadData();
  }

  void _reloadData() async {
    // make the connection near the point it is used so it doesn't time out
    await dotenv.load(fileName: ".env");
    String dbUrl = dotenv.env['TURSO_DATABASE_URL'] ?? '';
    String dbToken = dotenv.env['TURSO_AUTH_TOKEN'] ?? '';
    late LibsqlClient client = LibsqlClient(dbUrl, authToken: dbToken);
    await client.connect();
    List newRoomData = await client.query(
        "with cleanings_duration (room_tasks_id, duration_ms, is_real) as "
        "   (select room_tasks_id, duration_ms, is_real from cleanings "
        "     where duration_ms > 0 "
        "     and ((is_real=1) or (is_real is null))) "
        "select room_tasks.*, "
        " avg(COALESCE(cleanings_duration.duration_ms, cleanings_duration.duration_ms))/1000/60 as avg_duration_mins, "
        " room_name, "
        " task_name, "
        " COALESCE(max(end_datetime), DateTime('now', 'localtime', '-21 days')) as most_recent_cleaning, "
        " string_agg(equipment_name, "
        " ';')"
        " from room_tasks, rooms, tasks, task_equipment, equipment"
        " left join cleanings on room_tasks.id = cleanings.room_tasks_id"
        " left join cleanings_duration on room_tasks.id = cleanings_duration.room_tasks_id"
        " where room_tasks.room_id=rooms.id "
        " and room_tasks.task_id=tasks.id "
        " and task_equipment.task_id=tasks.id "
        " and task_equipment.equipment_id=equipment.id"
        " and (cleanings.is_real=1 or cleanings.is_real is null)"
        " group by room_tasks.id"
        " order by room_name, task_name;");
    // log("Here is the data we got from the database:");
    // log(jsonEncode(newRoomData));
    setState(() {
      _myRoomData = newRoomData;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: simpleSearchWithSort(_myRoomData, _reloadData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget simpleSearchWithSort(
    List roomListofMapsData, VoidCallback setStateFunction) {
  // log("roomListofMapsData");
  // log(jsonEncode(roomListofMapsData));
  List<RoomTask> roomDataAsRooms = [
    for (Map RoomMap in roomListofMapsData) RoomTask.fromMap(RoomMap)
  ];

  roomDataAsRooms.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);

    // if a tie on score
    if (scoreCompare == 0) {
      // order based on amount of equipment it needs that I wouldn't have out yet
      // to do this:

      // find the equipment for ones with lower scores
      // remove that equipment from the a and b lists
      // if number of remaining equipment is the same
      // return taskname sort
      // else return compare the number of remaining equipments in a and b lists

      // backup, sort on task name
      return 1 * b.task_name.compareTo(a.task_name);
    }
    return scoreCompare;
  });

  double accumulated_duration_mins = 0.0;
  // first accumulate any time already done today
  var now = new DateTime.now().toUtc();
  var earlierToday = now.subtract(const Duration(hours: 12));

  for (RoomTask room in roomDataAsRooms) {
    var most_recent_cleaning = DateTime.parse(room.most_recent_cleaning);

    if (most_recent_cleaning.isAfter(earlierToday)) {
      accumulated_duration_mins += room.avg_duration_mins;
    }
  }
  // then add on future things we could do
  for (RoomTask room in roomDataAsRooms) {
    if (room.avg_duration_mins > 0) {
      accumulated_duration_mins += room.avg_duration_mins;
    }
    room.accumulated_duration_mins = accumulated_duration_mins;
  }

  return SearchableList<RoomTask>(
    lazyLoadingEnabled: false,
    // sortWidget: Icon(Icons.sort),
    // sortPredicate: (a, b) => a.full_name.compareTo(b.full_name),
    filter: (p0) {
      return roomDataAsRooms
          .where((element) => element.full_name.contains(p0))
          .toList();
    },
    itemBuilder: (item) {
      return RoomTaskItem(room_task: item, setStateFunction: setStateFunction);
    },
    initialList: roomDataAsRooms,
    inputDecoration: InputDecoration(
      labelText: "Filter tasks",
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
  );
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('no room is found with this room_name'),
      ],
    );
  }
}

class RoomTaskItem extends StatefulWidget {
  final RoomTask room_task;
  VoidCallback setStateFunction;

  RoomTaskItem(
      {super.key, required this.room_task, required this.setStateFunction});

  @override
  State<RoomTaskItem> createState() => _RoomTaskItemState();
}

class _RoomTaskItemState extends State<RoomTaskItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 70,
        child: GestureDetector(
          onTap: () async {
            await _navigateAndDisplaySelection(
                widget.room_task, widget.setStateFunction, context);
          },
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            widget.room_task.isDeep
                                ? Icons.workspace_premium_outlined
                                : widget.room_task.isQuick
                                    ? Icons.bolt
                                    : Icons.check,
                            color: (widget.room_task.calculateScore()) >= 0
                                ? widget.room_task.doToday() ? Colors.black: Colors.black38
                                : Colors.black12),
                        const SizedBox(width: 50),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.room_task.display_task_name,
                            style: TextStyle(
                                fontSize: 20,
                                color: (widget.room_task.calculateScore()) >= 0
                                    ? widget.room_task.doToday() ? Colors.black: Colors.black38
                                    : Colors.black12),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.room_task.display_room_name,
                            style: TextStyle(
                                fontSize: 15,
                                color: (widget.room_task.calculateScore()) >= 0
                                    ? widget.room_task.doToday() ? Colors.black: Colors.black38
                                    : Colors.black12),
                          ),
                        ),
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 80),
                        Text(
                          '${widget.room_task.calculateScore().toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 80),
                        Text(
                          '${widget.room_task.accumulated_duration_mins.toStringAsFixed(1)} (${widget.room_task.avg_duration_mins.toStringAsFixed(1)} minutes)',
                          style: const TextStyle(
                            color: Colors.pink,
                          ),
                        )
                      ])
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A method that launches the SelectionScreen and awaits the result from
// Navigator.pop.
Future<void> _navigateAndDisplaySelection(RoomTask roomTask,
    VoidCallback setStateFunction, BuildContext context) async {
  // Navigator.push returns a Future that completes after calling
  // Navigator.pop on the Selection Screen.
  var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleaningDetailPage(room_task: roomTask),
      ));
  if (result != null) {
    final bool? is_real = result['is_real'];
    final bool? is_clean = result['is_clean'];
    final bool? is_needs_clean = result['is_needs_clean'];
    final int? duration_ms = result['duration_ms'];

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    var uuid = Uuid();
    var cleaningId = uuid.v1().substring(1, 8);

    if (result != 0) {
      await dotenv.load(fileName: ".env");
      String dbUrl = dotenv.env['TURSO_DATABASE_URL'] ?? '';
      String dbToken = dotenv.env['TURSO_AUTH_TOKEN'] ?? '';
      late LibsqlClient client = LibsqlClient(dbUrl, authToken: dbToken);
      await client.connect();

      if (is_needs_clean == true)
        await client.execute(
            "INSERT INTO cleanings (id, room_tasks_id, end_datetime, duration_ms, is_real)"
            " VALUES (?,?,?,?,?)",
            positional: [
              cleaningId,
              roomTask.id,
              DateTime.now()
                  .subtract(Duration(days: roomTask.period_days))
                  .toString(), // say it needs to be cleaned again now
              -1,
              1
            ]);
      else if (is_clean == true)
        await client.execute(
            "INSERT INTO cleanings (id, room_tasks_id, end_datetime, duration_ms, is_real)"
            " VALUES (?,?,?,?,?)",
            positional: [
              cleaningId,
              roomTask.id,
              DateTime.now()
                  .subtract(Duration(days: roomTask.period_days ~/ 2))
                  .toString(), // say it was cleaned half the duration ago
              -2,
              1
            ]);
      else
        await client.execute(
            "INSERT INTO cleanings (id, room_tasks_id, end_datetime, duration_ms, is_real)"
            " VALUES (?,?,?,?,?)",
            positional: [
              cleaningId,
              roomTask.id,
              DateTime.now().toString(),
              duration_ms,
              is_real == true ? 1 : 0
            ]);
    }

    setStateFunction();
  }
}
