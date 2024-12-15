import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:travel_buddy_app/providers/app_provider.dart';
import 'package:travel_buddy_app/services/auth_service.dart';
import 'package:travel_buddy_app/providers/chat_provider.dart' as chat_provider; 
import 'package:travel_buddy_app/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<AppProvider>(
          create: (_) => AppProvider()..initialize(),
        ),
        ChangeNotifierProvider<chat_provider.ChatProvider>(
          create: (_) => chat_provider.ChatProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Travel Buddy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green,
            secondary: Colors.greenAccent,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        home: const WelcomeScreen(),
      ),
    );
  }
}
