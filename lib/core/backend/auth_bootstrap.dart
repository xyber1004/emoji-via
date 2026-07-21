import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guarantees the app has a Supabase session before gameplay starts.
///
/// If no session exists (fresh install), signs in anonymously so streak writes
/// have a stable `auth.uid()` to key against. When the user later links an
/// email, that same anonymous uid is upgraded in place, so their already-synced
/// history follows them. Idempotent — safe to call on every launch.
Future<void> ensureAnonymousSession(SupabaseClient client) async {
  if (client.auth.currentSession != null) return;
  try {
    await client.auth.signInAnonymously();
    debugPrint('Anonymous session created: ${client.auth.currentUser?.id}');
  } catch (e) {
    // Offline first launch: no session yet. Gameplay still works locally;
    // the read-through sync will reconcile once a session exists.
    debugPrint('ensureAnonymousSession failed: $e');
  }
}
