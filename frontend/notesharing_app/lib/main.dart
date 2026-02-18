import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/providers.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const NoteShareApp());
}

class NoteShareApp extends StatelessWidget {
  const NoteShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => RequestsProvider()),
      ],
      child: MaterialApp(
        title: 'NoteShare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
