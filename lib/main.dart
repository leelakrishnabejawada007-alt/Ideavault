import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/api.dart';
import 'data/repository.dart';
import 'providers/idea_provider.dart';

/// Run against a real backend with:
///   flutter run -d chrome --dart-define=API_BASE_URL=https://your-api.example.com
const _baseUrl = String.fromEnvironment('API_BASE_URL');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final IdeaApi api = _baseUrl.isEmpty ? MockIdeaApi() : HttpIdeaApi(_baseUrl);
  final provider = IdeaProvider(IdeaRepository(api), prefs: prefs)..init();
  runApp(IdeaVaultApp(provider: provider));
}
