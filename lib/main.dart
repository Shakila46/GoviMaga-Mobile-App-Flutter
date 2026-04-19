import 'package:flutter/material.dart';
// Firebase පාවිච්චි කරන විට පහත line එක uncomment කරන්න
// import 'package:firebase_core/firebase_core.dart';
import 'farmer_home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env ෆයිල් එක Load කිරීම
  await dotenv.load(fileName: ".env");
  // Firebase configuration එක අවසන් වූ පසු මෙය uncomment කරන්න
  // await Firebase.initializeApp();
  runApp(const GoviMagaApp());
}

class GoviMagaApp extends StatelessWidget {
  const GoviMagaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoviMaga',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      home: const FarmerHomePage(),
    );
  }
}
