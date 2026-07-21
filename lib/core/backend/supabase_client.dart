import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Convenience accessor for the initialized Supabase client.
///
/// Only valid after [initSupabase] has completed in `main()`.
SupabaseClient get supabase => Supabase.instance.client;

/// Loads credentials from `.env.local` and initializes the global Supabase
/// client. Must be awaited before `runApp` and before any Supabase call.
///
/// Throws a clear [StateError] if the env vars are missing so the developer
/// knows to populate `.env.local` (see the SUPABASE_URL / SUPABASE_ANON_KEY
/// keys) rather than hitting an opaque Supabase failure at runtime.
Future<void> initSupabase() async {
  await dotenv.load(fileName: '.env.local');

  final url = dotenv.env['SUPABASE_URL'];
  final key = dotenv.env['SUPABASE_ANON_KEY'];

  if (url == null || url.isEmpty || key == null || key.isEmpty) {
    throw StateError(
      'Missing Supabase credentials. Add SUPABASE_URL and SUPABASE_ANON_KEY '
      'to .env.local (bundled as an asset in pubspec.yaml).',
    );
  }

  await Supabase.initialize(url: url, publishableKey: key);
}
