import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Fungsi untuk menangani pesan ketika aplikasi berjalan di background
  await Firebase.initializeApp();
  print("Pesan diterima di background: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Konfigurasi handler pesan di background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Minta izin untuk notifikasi
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Pengguna memberikan izin: ${settings.authorizationStatus}');
    } else {
      print('Izin ditolak: ${settings.authorizationStatus}');
    }

    // Dapatkan token FCM
    _token = await FirebaseMessaging.instance.getToken();
    print("Token FCM: $_token");

    // Listener untuk pesan foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan diterima di foreground: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Pesan Baru: ${message.notification?.title ?? "Tidak ada judul"}",
          ),
        ),
      );
    });

    // Listener untuk pesan ketika aplikasi di background dan user menekan notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notifikasi ditekan: ${message.notification?.title}');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message.notification?.title ?? 'Notifikasi'),
          content: Text(message.notification?.body ?? 'Tidak ada konten'),
        ),
      );
    });

    setState(() {}); // Update UI dengan token (opsional)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Messaging Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Firebase Messaging Token:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              _token ?? 'Sedang mendapatkan token...',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cobalah kirim pesan dari Firebase Console untuk melihat hasilnya.',
            ),
          ],
        ),
      ),
    );
  }
}
