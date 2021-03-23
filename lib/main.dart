import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_messaging_demo/screens/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.data}");
  print("Handling a background message: ${message.category}");
  print("Handling a background message: ${message.notification!.title}");
  print("Handling a background message: ${message.notification!.body}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FCM Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  dynamic data;
  bool isPlay = false;

  void firebase() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // String token = await messaging.getToken(
    //   vapidKey: "BGpdLRs......",
    // );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      setState(() {
        data = message;
      });

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        print(message.notification!.title);
        print(message.notification!.body);
      }
    });
  }

  Future<void> musicNotification() async {
    await MediaNotification.showNotification(
        title: 'Catholic Radio',
        // author: 'Catholic Radio',
        isPlaying: isPlay);
  }

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance
        .getToken()
        .then((token) => print('token: ' + token.toString()));
    firebase();
    musicNotification();
    MediaNotification.setListener('play', () {
      print('play from outside');
      if (mounted) {
        setState(() => isPlay = true);
      } else {
        isPlay = true;
      }
    });

    MediaNotification.setListener('pause', () {
      print('pause from outside');
      if (mounted) {
        setState(() => isPlay = false);
      } else {
        isPlay = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FCM demo'),
      ),
      body: ListView(
        children: [
          if (data != null) Text(data.notification.title.toString()),
          if (data != null) Text(data.notification.body.toString()),
          Text(
            isPlay.toString(),
            style: TextStyle(fontSize: 30),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Next()));
              },
              child: Text('Next'))
        ],
      ),
    );
  }
}

class Next extends StatefulWidget {
  Next({Key? key}) : super(key: key);

  @override
  _NextState createState() => _NextState();
}

class _NextState extends State<Next> {
  final items = List<String>.generate(20, (i) => "Item ${i + 1}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Dismissible widget Example'),
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Dismissible(
              // Each Dismissible must contain a Key. Keys allow Flutter to
              // uniquely identify widgets.
              key: Key(item),
              // Provide a function that tells the app
              // what to do after an item has been swiped away.
              onDismissed: (direction) {
                // Remove the item from the data source.
                setState(() {
                  items.removeAt(index);
                });

                // Show a snackbar. This snackbar could also contain "Undo" actions.
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("$item dismissed")));
              },
              background:
                  Container(color: Colors.red[900], child: Icon(Icons.delete)),
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  child: ListTile(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>HomePage1()));
                    },
                      hoverColor: Colors.yellow,
                      tileColor: Colors.cyan[800],
                      title: Text('$item'))),
            );
          },
        ));
  }
}
