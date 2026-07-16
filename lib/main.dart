import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emojivia/app/app.dart';
import 'package:emojivia/core/di/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: buildAppProviders(prefs),
      child: const EmojiviaApp(),
    ),
  );
}
