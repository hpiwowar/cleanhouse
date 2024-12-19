import 'dart:convert';
import 'dart:developer';

import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:libsql_dart/libsql_dart.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:cleanhouse/components/RoomTask.dart';
import 'package:cleanhouse/pages/cleaning_details.dart';

List _myRoomData = [];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
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
        "select room_tasks.*, room_name, task_name, COALESCE(max(end_datetime), DateTime('now', 'localtime', '-6 month')) as most_recent_cleaning, string_agg(equipment_name, ';')"
            " from room_tasks, rooms, tasks, task_equipment, equipment"
            " left join cleanings on room_tasks.id = cleanings.room_tasks_id"
            " where room_tasks.room_id=rooms.id and room_tasks.task_id=tasks.id and task_equipment.task_id=tasks.id and task_equipment.equipment_id=equipment.id"
            " group by room_tasks.id"
            " order by room_name, task_name;");
    log(jsonEncode(newRoomData));
    setState(() {
      _myRoomData = newRoomData;
    });
    return;
  }

  @override
  Widget build(BuildContext context) {
    // log(jsonEncode(_myRoomData));
    String stringResult = 'Hi Heather';

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
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
  log("roomListofMapsData");
  log(jsonEncode(roomListofMapsData));
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
  // log("roomDataAsRooms");
  // log(jsonEncode(roomDataAsRooms));

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
      // return RoomTaskItem(room_task: item, controller: controller);
      return RoomTaskItem(room_task: item, setStateFunction: setStateFunction);
    },
    initialList: roomDataAsRooms,
    inputDecoration: InputDecoration(
      labelText: "Search Task",
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.blue,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
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



class RoomTaskItem extends StatelessWidget {
  final RoomTask room_task;
  VoidCallback setStateFunction;

  RoomTaskItem(
      {super.key, required this.room_task, required this.setStateFunction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: GestureDetector(
          onTap: () async {
            await _navigateAndDisplaySelection(room_task, setStateFunction, context);
          },
          child: Card( child:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded( child:
              Text(
                room_task.full_name,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),
              Text(
                '${room_task.calculateScore().toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
        builder: (context) => DetailScreen(room_task: roomTask),
      ));

  // When a BuildContext is used from a StatefulWidget, the mounted property
  // must be checked after an asynchronous gap.
  if (!context.mounted) return;

  var uuid = Uuid();
  var cleaningId = uuid.v1().substring(1, 8);
  var displayText = '';

  if (result != 0) {
    displayText = 'Inserting';
    await dotenv.load(fileName: ".env");
    String dbUrl = dotenv.env['TURSO_DATABASE_URL'] ?? '';
    String dbToken = dotenv.env['TURSO_AUTH_TOKEN'] ?? '';
    late LibsqlClient client = LibsqlClient(dbUrl, authToken: dbToken);
    await client.connect();
    await client.execute(
        "INSERT INTO cleanings (id, room_tasks_id, end_datetime, duration_ms)"
            " VALUES (?,?,?,?)",
        positional: [
          cleaningId,
          roomTask.id,
          DateTime.now().toString(),
          result
        ]);
  }

  setStateFunction();

}