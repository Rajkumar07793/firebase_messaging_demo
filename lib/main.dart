import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.data}");
  print("Handling a background message: ${message.category}");
  print("Handling a background message: ${message.notification.title}");
  print("Handling a background message: ${message.notification.body}");


}

void main() async{
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

  void firebase() async{
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
        print(message.notification.title);
        print(message.notification.body);


      }
    });
  }

  @override
  void initState(){
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) => print('token: '+token));
    firebase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FCM demo'),),
      body: ListView(children: [
        Text(data.notification.title.toString()),
        Text(data.notification.body.toString())
      ],),
    );
  }
}
