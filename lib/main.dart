import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_ticker/widgets/notification_service.dart';

import 'splash_screen.dart';

Future<void> main() async {
  // Initialize NotificationService
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = (prefs.getBool('isDarkMode') ?? false)
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
      prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tick Ticker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[50],
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.grey[800],
            displayColor: Colors.grey[900],
          ),
        ),
        colorScheme: ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.teal[600]!,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Colors.grey[800]!,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.withOpacity(0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal, width: 2),
          ),
          filled: true,
          fillColor: Colors.teal.withOpacity(0.08),
          labelStyle: TextStyle(color: Colors.teal[600]),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
          surface: Color(0xFF1A1A2E),
          onPrimary: Colors.black,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.teal),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          labelStyle: TextStyle(color: Colors.teal),
        ),
      ),
      themeMode: _themeMode,
      home: SplashScreen(onThemeToggle: _toggleTheme),
    );
  }
}
