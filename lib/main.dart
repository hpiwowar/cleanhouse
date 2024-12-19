import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:libsql_dart/libsql_dart.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:uuid/uuid.dart';

class ExampleCandidateModel {
  final String name;
  final String job;
  final String city;
  final List<Color> color;

  ExampleCandidateModel({
    required this.name,
    required this.job,
    required this.city,
    required this.color,
  });
}

final List<ExampleCandidateModel> candidates = [
  ExampleCandidateModel(
    name: 'One, 1',
    job: 'Developer',
    city: 'Areado',
    color: const [Color(0xFFFF3868), Color(0xFFFFB49A)],
  ),
  ExampleCandidateModel(
    name: 'Two, 2',
    job: 'Manager',
    city: 'New York',
    color: const [Color(0xFF736EFE), Color(0xFF62E4EC)],
  ),
  ExampleCandidateModel(
    name: 'Three, 3',
    job: 'Engineer',
    city: 'London',
    color: const [Color(0xFF2F80ED), Color(0xFF56CCF2)],
  ),
  ExampleCandidateModel(
    name: 'Four, 4',
    job: 'Designer',
    city: 'Tokyo',
    color: const [Color(0xFF0BA4E0), Color(0xFFA9E4BD)],
  ),
];

List _myRoomData = [
  {
    "id": '123',
    'room_id': 'uty',
    'room_name': 'fake room',
    'task_id': 'jhg',
    'task_name': 'fake task',
    'most_recent_cleaning': DateTime.now().toString(),
    'period_days': 1
  }
];

class ExampleCard extends StatelessWidget {
  final ExampleCandidateModel candidate;

  const ExampleCard(
    this.candidate, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: candidate.color,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate.name,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  candidate.job,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  candidate.city,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// try Turso for free persistant sql storage: https://docs.turso.tech/sdk/flutter/quickstart
// put this in GitHub
// try it on my Android phone

late LibsqlClient client;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clean clean clean',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          secondary: Colors.deepOrangeAccent,
        ),
        fontFamily: 'Varela',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyMedium: TextStyle(fontSize: 18.0, fontFamily: 'Varela'),
        ),
      ),
      home: const MyHomePage(title: 'Cleaning tasks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    client = LibsqlClient(dbUrl, authToken: dbToken);
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
    client = LibsqlClient(dbUrl, authToken: dbToken);
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

class DetailScreen extends StatelessWidget {
  // In the constructor, require a roomRask.
  const DetailScreen({super.key, required this.room_task});

  // Declare a field that holds the Todo.
  final RoomTask room_task;

  @override
  Widget build(BuildContext context) {
    // Use the task to create the UI.
    return Scaffold(
      appBar: AppBar(
        title: Text(room_task.full_name),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(room_task.full_name),
          SizedBox(
            width: 200.0,
            height: 300.0,
            child: MyStopwatch(),
          )
        ],
      )),
    );
  }
}

class MyStopwatch extends StatefulWidget {
  const MyStopwatch({super.key});

  @override
  State<MyStopwatch> createState() => _MyStopwatchState();
}

class _MyStopwatchState extends State<MyStopwatch> {
  final Stopwatch _stopwatch = Stopwatch();
  late Duration _elapsedTime;
  late String _elapsedTimeString;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    _elapsedTime = Duration.zero;
    _elapsedTimeString = _formatElapsedTime(_elapsedTime);

    // Create a timer that runs a callback every 100 milliseconds to update UI
    timer = Timer.periodic(const Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        // Update elapsed time only if the stopwatch is running
        if (_stopwatch.isRunning) {
          _updateElapsedTime();
        }
      });
    });
  }

  // Start/Stop button callback
  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      // Start the stopwatch and update elapsed time
      _stopwatch.start();
      _updateElapsedTime();
    } else {
      // Stop the stopwatch
      _stopwatch.stop();
      Navigator.pop(context, _elapsedTime.inMilliseconds);
    }
  }

  // Reset button callback
  void _resetStopwatch() {
    // Reset the stopwatch to zero and update elapsed time
    _stopwatch.reset();
    _updateElapsedTime();
  }

  void _cancelStopwatch() {
    Navigator.pop(context, 0);
  }

  // Update elapsed time and formatted time string
  void _updateElapsedTime() {
    setState(() {
      _elapsedTime = _stopwatch.elapsed;
      _elapsedTimeString = _formatElapsedTime(_elapsedTime);
    });
  }

  // Format a Duration into a string (MM:SS.SS)
  String _formatElapsedTime(Duration time) {
    return '${time.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(time.inSeconds.remainder(60)).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000 ~/ 100).toString()}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display elapsed time
            Text(
              _elapsedTimeString,
              style: const TextStyle(fontSize: 40.0),
            ),
            const SizedBox(height: 20.0),
            // Start/Stop and Reset buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startStopwatch,
                  child: Text(_stopwatch.isRunning ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 20.0),
                ElevatedButton(
                  onPressed: _cancelStopwatch,
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
