import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const LloydsAgentApp());
}

class LloydsAgentApp extends StatelessWidget {
  const LloydsAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lloyds Banking Group theme tokens
    const brandGreen = Color(0xFF006A4E);
    const deepGreen = Color(0xFF002C1B);
    const brandGold = Color(0xFFB59049);
    const backgroundGrey = Color(0xFFF9FBFB);

    return MaterialApp(
      title: 'Lloyds Banking Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandGreen,
          primary: brandGreen,
          secondary: brandGold,
          tertiary: deepGreen,
          surface: backgroundGrey,
        ),
        // Use Google Fonts "Outfit" for a modern, sleek premium fintech look
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: deepGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}
