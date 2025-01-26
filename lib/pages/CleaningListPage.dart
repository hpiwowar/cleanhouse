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
    List newRoomData = await client.query("select room_tasks.*, "
        " room_name, "
        " task_name, "
        " COALESCE(max(end_datetime), DateTime('now', 'localtime', '-10 days')) as most_recent_cleaning, "
        " string_agg(equipment_name, "
        " ';')"
        " from room_tasks, rooms, tasks, task_equipment, equipment"
        " left join cleanings on room_tasks.id = cleanings.room_tasks_id"
        " where room_tasks.room_id=rooms.id "
          " and room_tasks.task_id=tasks.id "
          " and task_equipment.task_id=tasks.id "
          " and task_equipment.equipment_id=equipment.id"
          " and cleanings.is_real=1"
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
    final scoreCompare = a.score.compareTo(b.score);

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
      return 1 * a.task_name.compareTo(b.task_name);
    }
    return scoreCompare;
  });

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
                        Icon(widget.room_task.isDeep
                            ? Icons.workspace_premium_outlined
                            : widget.room_task.isQuick
                                ? Icons.bolt
                                : Icons.check),
                        const SizedBox(width: 50),
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.room_task.display_task_name,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.room_task.display_room_name,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 15),
                          ),
                        ),
                      ]),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 80),
                        Text(
                          '${widget.room_task.calculateScore().toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.deepOrangeAccent,
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
    final bool is_real = result['is_real'];
    final int duration_ms = result['duration_ms'];

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
      await client.execute(
          "INSERT INTO cleanings (id, room_tasks_id, end_datetime, duration_ms, is_real)"
          " VALUES (?,?,?,?,?)",
          positional: [
            cleaningId,
            roomTask.id,
            DateTime.now().toString(),
            duration_ms,
            is_real ? 1 : 0
          ]);
    }

    setStateFunction();
  }
}
