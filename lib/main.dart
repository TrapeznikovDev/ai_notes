import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);
  const apiKey = String.fromEnvironment('OPENROUTER_API_KEY');

  final prefs = await SharedPreferences.getInstance();

  runApp(AiNotesApp(
    prefs: prefs,
    useMock: useMock,
    apiKey: apiKey.isEmpty ? null : apiKey,
  ));
}
