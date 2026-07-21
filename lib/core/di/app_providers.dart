import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/features/auth/application/controllers/auth_controller.dart';
import 'package:emojivia/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:emojivia/features/auth/data/sources/auth_remote_source.dart';
import 'package:emojivia/features/auth/domain/repositories/auth_repository.dart';
import 'package:emojivia/features/auth/domain/usecases/resend_otp.dart';
import 'package:emojivia/features/auth/domain/usecases/send_otp.dart';
import 'package:emojivia/features/auth/domain/usecases/verify_otp.dart';
import 'package:emojivia/features/awards/application/controllers/awards_controller.dart';
import 'package:emojivia/features/game/application/controllers/game_controller.dart';
import 'package:emojivia/features/game/application/services/feedback_copy_service.dart';
import 'package:emojivia/features/game/data/repositories/puzzle_repository_impl.dart';
import 'package:emojivia/features/game/data/sources/puzzle_asset_source.dart';
import 'package:emojivia/features/game/domain/repositories/puzzle_repository.dart';
import 'package:emojivia/features/game/domain/usecases/get_today_puzzles.dart';
import 'package:emojivia/features/settings/application/controllers/settings_controller.dart';
import 'package:emojivia/features/streak/application/controllers/stats_controller.dart';
import 'package:emojivia/features/streak/application/controllers/streak_controller.dart';
import 'package:emojivia/features/streak/application/services/streak_sync_service.dart';
import 'package:emojivia/features/streak/data/repositories/streak_repository_impl.dart';
import 'package:emojivia/features/streak/data/sources/streak_prefs_source.dart';
import 'package:emojivia/features/streak/data/sources/streak_remote_source.dart';
import 'package:emojivia/features/streak/domain/repositories/streak_repository.dart';

/// Root provider tree. Wires dependency-injection for the whole app.
///
/// Ordering matters: each provider may `context.read` the ones declared before
/// it. Stateless services use [Provider]; controllers use [ChangeNotifierProvider].
List<SingleChildWidget> buildAppProviders(
  SharedPreferences prefs,
  SupabaseClient supabase,
) {
  return [
    Provider<SharedPreferences>.value(value: prefs),
    Provider<SupabaseClient>.value(value: supabase),
    Provider<StorageService>(
      create: (ctx) => StorageService(ctx.read<SharedPreferences>()),
    ),
    Provider<PuzzleAssetSource>(create: (_) => const PuzzleAssetSource()),
    Provider<PuzzleRepository>(
      create: (ctx) => PuzzleRepositoryImpl(ctx.read<PuzzleAssetSource>()),
    ),
    Provider<GetTodayPuzzles>(
      create: (ctx) => GetTodayPuzzles(ctx.read<PuzzleRepository>()),
    ),
    Provider<FeedbackCopyService>(create: (_) => const FeedbackCopyService()),

    // --- streak (local + remote sync) ---------------------------------------
    Provider<StreakRemoteSource>(
      create: (ctx) => StreakRemoteSource(ctx.read<SupabaseClient>()),
    ),
    Provider<StreakSyncService>(
      create: (ctx) => StreakSyncService(
        ctx.read<StreakRemoteSource>(),
        ctx.read<StorageService>(),
      ),
    ),
    Provider<StreakRepository>(
      create: (ctx) => StreakRepositoryImpl(
        StreakPrefsSource(ctx.read<StorageService>()),
        ctx.read<StreakRemoteSource>(),
        ctx.read<StorageService>(),
      ),
    ),

    // --- auth (email-OTP linking) -------------------------------------------
    Provider<AuthRemoteSource>(
      create: (ctx) => AuthRemoteSource(ctx.read<SupabaseClient>()),
    ),
    Provider<AuthRepository>(
      create: (ctx) => AuthRepositoryImpl(ctx.read<AuthRemoteSource>()),
    ),
    Provider<SendOtp>(create: (ctx) => SendOtp(ctx.read<AuthRepository>())),
    Provider<VerifyOtp>(
      create: (ctx) => VerifyOtp(ctx.read<AuthRepository>()),
    ),
    Provider<ResendOtp>(
      create: (ctx) => ResendOtp(ctx.read<AuthRepository>()),
    ),

    // --- controllers ---------------------------------------------------------
    ChangeNotifierProvider<StreakController>(
      create: (ctx) => StreakController(
        ctx.read<StreakRepository>(),
        ctx.read<StorageService>(),
        ctx.read<StreakSyncService>(),
      ),
    ),
    ChangeNotifierProvider<StatsController>(
      create: (ctx) => StatsController(ctx.read<StorageService>()),
    ),
    ChangeNotifierProvider<AwardsController>(
      create: (ctx) => AwardsController(ctx.read<StorageService>()),
    ),
    ChangeNotifierProvider<SettingsController>(
      create: (ctx) => SettingsController(ctx.read<StorageService>()),
    ),
    ChangeNotifierProvider<GameController>(create: (_) => GameController()),
    ChangeNotifierProvider<AuthController>(
      create: (ctx) => AuthController(
        sendOtp: ctx.read<SendOtp>(),
        verifyOtp: ctx.read<VerifyOtp>(),
        resendOtp: ctx.read<ResendOtp>(),
        storage: ctx.read<StorageService>(),
        client: ctx.read<SupabaseClient>(),
      ),
    ),
  ];
}
