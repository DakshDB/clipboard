import 'package:clipboard/constants/themes.dart';
import 'package:clipboard/screens/home.dart';
import 'package:clipboard/services/auth_checker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clipboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: teal,
        scaffoldBackgroundColor: oxfordBlue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: platinum),
        ),
      ),
      home: const AuthChecker(),
    );
  }
}
