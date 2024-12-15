import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:libsql_dart/libsql_dart.dart';
import 'package:searchable_listview/searchable_listview.dart';

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
      title: 'My Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.yellow),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Flutter Demo Home Page'),
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
  int _counter = 0;
  List _myRoomData = [
    {
      "id": '123',
      'room_id': 'uty',
      'room_name': 'fake room',
      'task_id': 'jhg',
      'task_name': 'fake task'
    }
  ];

  final CardSwiperController controller = CardSwiperController();
  final cards = candidates.map(ExampleCard.new).toList();

  @override
  void dispose() {
    controller.dispose();
  }

  Future<void> _incrementCounter() async {
    // make the connection near the point it is used so it doesn't time out
    await dotenv.load(fileName: ".env");
    String dbUrl = dotenv.env['TURSO_DATABASE_URL'] ?? '';
    String dbToken = dotenv.env['TURSO_AUTH_TOKEN'] ?? '';
    log(dbUrl);
    log(dbToken);
    client = LibsqlClient(dbUrl, authToken: dbToken);
    await client.connect();
    List _newRoomData = await client.query(
        "select room_tasks.*, room_name, task_name from room_tasks, rooms, tasks "
            "where room_tasks.room_id=rooms.id and room_tasks.task_id=tasks.id "
            "order by room_name, task_name;");
    log(jsonEncode(_newRoomData));

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      _myRoomData = _newRoomData;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    // log(jsonEncode(_myRoomData));
    String _stringResult = 'Hi Heather';

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
            Text(
                '$_stringResult\n\n You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
                child: CardSwiper(
                  controller: controller,
                  cardsCount: cards.length,
                  onSwipe: _onSwipe,
                  onUndo: _onUndo,
                  numberOfCardsDisplayed: 4,
                  backCardOffset: const Offset(40, 40),
                  padding: const EdgeInsets.all(24.0),
                  cardBuilder: (context,
                      index,
                      horizontalThresholdPercentage,
                      verticalThresholdPercentage,) =>
                  cards[index],
                )
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                // child: simpleSearchWithSort(_myRoomData, controller),
                child: simpleSearchWithSort(_myRoomData),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

// Widget simpleSearchWithSort(List roomListofMapsData, CardSwiperController controller) {
Widget simpleSearchWithSort(List roomListofMapsData) {
  log("roomListofMapsData");
  log(jsonEncode(roomListofMapsData));
  List<RoomTask> roomDataAsRooms = [
    for (Map RoomMap in roomListofMapsData) RoomTask.fromMap(RoomMap)
  ];
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
      return RoomTaskItem(room_task: item);
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
  const EmptyView({Key? key}) : super(key: key);

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
  late String full_name = "$room_name $task_name";

  RoomTask(
      {required this.id,
      required this.room_id,
      required this.task_id,
      required this.room_name,
      required this.task_name});

  RoomTask.fromMap(Map myMap) {
    this.id = myMap["id"];
    this.room_id = myMap["room_name"];
    this.task_id = myMap["task_id"];
    this.room_name = myMap["room_name"];
    this.task_name = myMap["task_name"];
  }
}

class RoomTaskItem extends StatelessWidget {
  final RoomTask room_task;

  // final CardSwiperController controller;
  //
  const RoomTaskItem({Key? key, required this.room_task
      // ,required CardSwiperController this.controller
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      // child: GestureDetector(
      //   onTap: () {
      //     ScaffoldMessenger.of(context)
      //         .showSnackBar(SnackBar(content: Text('Gesture Detected!')));
      //   },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Card(
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Icon(
                Icons.star,
                color: Colors.yellow[700],
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FloatingActionButton(
                  //   onPressed: this.controller.undo,
                  //   child: const Icon(Icons.rotate_left),
                  // ),
                  // FloatingActionButton(
                  //   onPressed: () => this.controller.swipe(CardSwiperDirection.left),
                  //   child: const Icon(Icons.keyboard_arrow_left),
                  // ),
                  // FloatingActionButton(
                  //   onPressed: () =>
                  //       this.controller.swipe(CardSwiperDirection.right),
                  //   child: const Icon(Icons.keyboard_arrow_right),
                  // ),
                  // FloatingActionButton(
                  //   onPressed: () => this.controller.swipe(CardSwiperDirection.top),
                  //   child: const Icon(Icons.keyboard_arrow_up),
                  // ),
                  // FloatingActionButton(
                  //   onPressed: () =>
                  //       this.controller.swipe(CardSwiperDirection.bottom),
                  //   child: const Icon(Icons.keyboard_arrow_down),
                  // ),
                  Text(
                    'id: ${room_task.id}',
                    style: const TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${room_task.full_name}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // ),
    );
  }
}

bool _onSwipe(
  int previousIndex,
  int? currentIndex,
  CardSwiperDirection direction,
) {
  debugPrint(
    'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
  );
  return true;
}

bool _onUndo(
  int? previousIndex,
  int currentIndex,
  CardSwiperDirection direction,
) {
  debugPrint(
    'The card $currentIndex was undod from the ${direction.name}',
  );
  return true;
}
