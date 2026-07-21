# Emojivia — Email OTP Auth Implementation Spec

**For:** Claude Code
**Feature:** Email-based streak backup via Supabase OTP, prompted after 7-day streak
**Prerequisites:** Read `docs/architecture.md` first. This spec assumes you understand the feature-first clean architecture, the four-layer rule, and Riverpod conventions used throughout the codebase.

---

## 1. What we're building (in one paragraph)

A user hits a 7-day streak. On the results screen after that game, a bottom sheet appears offering to save their streak. They enter an email, receive a 6-digit code, type it back in, and their anonymous Supabase account is linked to that email. Their streak now syncs across devices. No passwords, no magic links, no deep linking — the entire flow happens in-app. If they dismiss the prompt, don't ask again for 7 days.

---

## 2. Scope boundaries — read this before starting

**In scope:**
- New `features/auth/` vertical slice
- New `core/backend/` scaffolding for Supabase client + anonymous session bootstrap
- New remote data source in `features/streak/` that mirrors local state to Supabase
- Two new fields on `StreakState`: `emailLinked` and `lastSavePromptShown`
- One new call site in `ResultsScreen` to trigger the save prompt
- Two new persisted keys in `StorageKeys` / `StorageService`

**Out of scope — do NOT build:**
- Magic links / deep linking / universal links
- Passwords or password reset flows
- Recovery codes of any kind
- Social login (Google/Apple)
- Passkeys / WebAuthn
- Realtime subscriptions
- Leaderboards or any use of `game_completions` beyond writing to it
- Remote puzzle loading (puzzles stay in `assets/puzzles/`)
- Any changes to `features/game/`, `features/home/`, `features/onboarding/`, `features/packs/`
- Any changes to `core/theme/` or `core/widgets/` — reuse what exists

If you find yourself about to touch a file outside the scope list, stop and ask.

---

## 3. Architecture — where everything goes

### 3.1 New folders

```
lib/core/backend/                                  ← NEW
├── supabase_client.dart                           ← init + supabaseClientProvider
└── auth_bootstrap.dart                            ← ensureAnonymousSession()

lib/features/auth/                                 ← NEW feature
├── auth.dart                                      ← barrel — exports only public providers + types
├── domain/
│   ├── entities/
│   │   ├── auth_status.dart                       ← enum
│   │   ├── send_otp_result.dart                   ← sealed class or enum
│   │   └── verify_otp_result.dart                 ← sealed class or enum
│   ├── repositories/
│   │   └── auth_repository.dart                   ← abstract
│   └── usecases/
│       ├── send_otp.dart
│       ├── verify_otp.dart
│       └── resend_otp.dart
├── data/
│   ├── sources/
│   │   └── auth_remote_source.dart                ← thin wrapper over supabase.auth
│   └── repositories/
│       └── auth_repository_impl.dart
├── application/
│   ├── state/
│   │   └── auth_state.dart                        ← AuthStatus + email + errors + cooldown
│   ├── controllers/
│   │   └── auth_controller.dart                   ← Notifier<AuthState>
│   └── providers/
│       └── auth_providers.dart                    ← authControllerProvider + repo factories
└── presentation/
    ├── screens/
    │   ├── save_streak_screen.dart                ← the "save your streak?" bottom sheet
    │   ├── email_entry_screen.dart
    │   └── otp_verify_screen.dart
    └── widgets/
        ├── email_field.dart
        └── otp_input.dart                         ← the 6-box code input
```

### 3.2 Modifications to existing files

**`lib/main.dart`** — before `runApp`, call `Supabase.initialize(...)` and `ensureAnonymousSession()`.

**`lib/core/storage/storage_keys.dart`** — add two constants:
```dart
static const lastSavePromptShown = 'last_save_prompt_shown';
static const emailLinkedAt = 'email_linked_at';
```

**`lib/core/storage/storage_service.dart`** — add getters + setters for both.

**`lib/features/streak/application/state/streak_state.dart`** — add two fields:
- `final bool emailLinked;` (derived from `emailLinkedAt != null` or read from auth)
- `final DateTime? lastSavePromptShown;`
- Add a computed `bool get shouldPromptSave` — see §7.1 for the exact rule.

**`lib/features/streak/application/controllers/streak_controller.dart`** — add `markSavePromptShown()` method that writes `DateTime.now()` to prefs and updates state.

**`lib/features/streak/data/`** — add a new `StreakRemoteSource` and update `StreakRepositoryImpl` to mirror writes to Supabase. Reads still come from prefs first. See §6.

**`lib/features/results/presentation/screens/results_screen.dart`** — after the existing completion celebration, check `streak.shouldPromptSave` and if true, show `SaveStreakScreen` as a bottom sheet + call `markSavePromptShown()`.

**`pubspec.yaml`** — add `supabase_flutter: ^2.5.0` (or latest 2.x). No other new packages.

---

## 4. The four-layer rule — how it applies here

Same as the rest of the codebase. Recap for this feature:

| Layer | Files | Must NOT |
|---|---|---|
| `domain/` | Entities, `AuthRepository` interface, usecases | Import supabase_flutter, Flutter, or Riverpod |
| `data/` | `AuthRemoteSource`, `AuthRepositoryImpl` | Contain business logic; import from `presentation/` |
| `application/` | `AuthController`, providers, `AuthState` | Do IO directly (call through repository) |
| `presentation/` | Screens, widgets | Import from `data/`; call Supabase directly |

`SupabaseClient` lives in `core/backend/` and is exposed as a `Provider`. `AuthRemoteSource` reads it via `ref.read(supabaseClientProvider)`.

---

## 5. Supabase — assumed setup

The developer will handle Supabase dashboard config separately (this is not your job). You can assume:

- Project URL and anon key will be provided via `--dart-define` at build time: `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Anonymous sign-in is enabled
- Email OTP provider is enabled with "Confirm email" set to OTP (not magic link)
- OTP length is 6 digits, expiry is 1 hour
- Email template is customized (not your concern)

**Do NOT hardcode Supabase URL or keys.** Read them via `String.fromEnvironment('SUPABASE_URL')`. If they're empty at runtime, `SupabaseClient.init` should throw a clear error message telling the developer to pass `--dart-define`.

**Do NOT write SQL migrations.** The developer owns the schema. Your code only reads/writes via the Supabase Dart client.

---

## 6. Streak sync — the tricky bit

This is the only place where existing code changes non-trivially. Read carefully.

### 6.1 The rule

- **Reads:** `StreakRepositoryImpl.load()` returns from prefs immediately (synchronous-feeling UX). In the background, fire off a fetch from Supabase. If the remote row's `updated_at` is newer than local, update prefs and emit a new state via the controller.
- **Writes:** `StreakRepositoryImpl.save(streak)` writes to prefs first (instant), then fires an async write to Supabase. If the remote write fails, log it — don't block the UI, don't retry inline. On next app open, the read-through will reconcile.
- **Anonymous users write too.** As soon as the app has a session (anonymous or linked), streak writes go to Supabase against that UID. This means when a user eventually links email, their history is already there.

### 6.2 Conflict resolution

Compare `updated_at` timestamps. Later wins. If they're equal, prefer server (avoids infinite ping-pong).

### 6.3 Do NOT

- Do not build an offline queue with retries in this pass. Fire-and-forget is fine for v1.
- Do not subscribe to Realtime. This is a background sync, not a live sync.
- Do not change `StreakState`'s shape beyond the two fields listed in §3.2.
- Do not change the `StreakRepository` interface. Only its impl.

---

## 7. The 7-day prompt trigger

### 7.1 The exact rule

Add this computed getter to `StreakState`:

```dart
bool get shouldPromptSave {
  if (emailLinked) return false;
  if (count < 7) return false;
  final last = lastSavePromptShown;
  if (last == null) return true;
  return DateTime.now().difference(last).inDays >= 7;
}
```

### 7.2 Where the trigger fires

In `results_screen.dart`, inside the existing post-game flow. After confetti and mascot celebration have played:

```dart
final streak = ref.watch(streakControllerProvider);
if (streak.shouldPromptSave) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SaveStreakScreen(),
    );
    ref.read(streakControllerProvider.notifier).markSavePromptShown();
  });
}
```

Show the bottom sheet exactly once per results screen visit. Do not show it on the home screen, in gameplay, or on the empty/done screen.

---

## 8. Screens — design system compliance

**Read `docs/architecture.md` §8 before building any screen.** All three new screens must use the existing design system. No new colors, no new typography, no new shadow patterns.

### 8.1 SaveStreakScreen (bottom sheet)

Layout:
- Top: drag handle (small ink-colored pill, 3px tall, centered)
- Big `PixelFlame` (size 8+) in `ec.flame` color, centered
- "7 days!" using `AppTypography.pixelNumeral` (or displayL if it looks better at this size — designer's judgment)
- Headline "Save your streak?" using `AppTypography.displayS`
- Sub-copy using `AppTypography.body`: "Add your email so you can pick up where you left off on any device."
- Primary `ChunkyButton` (variant: `primary`): "Save my streak" — pushes `EmailEntryScreen`
- Ghost `ChunkyButton` (variant: `ghost`): "Maybe later" — pops the sheet
- Meta text using `AppTypography.meta`: "No password. We'll email you a 6-digit code."

Sheet uses `AppShape.heroCard` for its top corners. Background is `ec.paper`. Standard ink border on top.

### 8.2 EmailEntryScreen

Full screen (pushed, not modal).
- Standard back button in top bar (ink color, no border — matches existing screens)
- Headline "What's your email?" using `AppTypography.displayS`
- Sub-copy: "We'll send you a code to save your streak."
- Single `EmailField` — this is a new widget you build. It's a `TextFormField` styled to match the app: ink border (2px), `AppShape.card` radius, paper fill, `AppTypography.answer` for input text. Validation: standard email regex, show inline error in `ec.bad` on submit-with-invalid.
- Primary `ChunkyButton`: "Send code" — calls `authController.sendOtp(email)`. Disabled while `AuthStatus == sending`. On success, push `OtpVerifyScreen` with the email as an arg. On error, show inline error message under the field.
- Ghost `ChunkyButton`: "Cancel" — pops.

### 8.3 OtpVerifyScreen

Full screen.
- Standard back button (returns to EmailEntryScreen so user can fix a typo)
- Mascot in `idle` mood, size medium
- Headline "Check your email" using `AppTypography.displayS`
- Sub-copy: "Enter the 6-digit code we sent to `{email}`." Email in `ec.inkSoft`.
- **OtpInput widget** — see §8.4
- "Resend code" — text button in `ec.inkSoft`. Disabled for 60 seconds after send; show countdown ("Resend in 42s") using `AppTypography.pixelNumeralS`. Reset countdown on successful resend.
- "Wrong email?" text button — pops back to EmailEntryScreen.
- Show inline error above the input in `ec.bad` for wrong code / expired / rate-limited.

On successful verify:
- Pop all the way back to ResultsScreen (or wherever the user came from)
- Trigger the existing `ConfettiOverlay` with a new burst
- Show a `SnackBar` or brief overlay: "Streak saved! 🔥"
- Update `emailLinked` state so the prompt never fires again

### 8.4 OtpInput widget

This is the one non-trivial widget. Requirements:

- Six boxes in a row, each `AppShape.card` radius, ink border 2px, paper fill, `AppTypography.displayM` for the digit
- Each box is ~48×56 (adjust for viewport)
- Focus auto-advances on digit entry, auto-retreats on backspace when empty
- Numeric keyboard only (`TextInputType.number`)
- iOS autofill: set `autofillHints: [AutofillHints.oneTimeCode]` on the FIRST field
- Paste detection: if the user pastes a 6-digit string into any box, distribute the digits across all six boxes
- On sixth digit entered, auto-submit — call the parent's `onComplete(code)` callback
- Show the currently-focused box with a `ec.yellow` fill instead of paper (design-system consistent with selected state)
- Disable all boxes while verifying (dim to 50% opacity)

Do NOT pull in a package like `pin_code_fields`. Build it with six `TextEditingController`s and six `FocusNode`s. It's ~150 lines and gives us full control over styling.

---

## 9. State machine — AuthController

```
AuthStatus:
  anonymous       ← default, no email attached
  sending         ← waiting for sendOtp API response
  otpSent         ← code has been sent, awaiting user input
  verifying       ← waiting for verifyOtp API response
  linked          ← email successfully linked
```

`AuthState` fields:
```dart
final AuthStatus status;
final String? pendingEmail;         // email the OTP was sent to
final String? errorMessage;         // user-facing error, null when no error
final DateTime? lastOtpSentAt;      // for resend cooldown
```

Methods on `AuthController`:
- `Future<void> sendOtp(String email)` — sets status to `sending`, calls repo, transitions to `otpSent` or back to `anonymous` with `errorMessage`
- `Future<void> verifyOtp(String code)` — requires `pendingEmail` to be set. Sets status to `verifying`, calls repo, transitions to `linked` or back to `otpSent` with `errorMessage`
- `Future<void> resendOtp()` — reuses `pendingEmail`. Enforces 60s cooldown client-side (returns early with an error if too soon).
- `void clearError()` — called by UI after showing an error, before user retries
- `void reset()` — resets to `anonymous`, clears pendingEmail. Called if user backs out entirely.

On successful verify, the controller must also:
1. Write `emailLinkedAt = DateTime.now()` via `StorageService`
2. Trigger a streak state refresh so `emailLinked` becomes true
3. Emit the `linked` status

Watch `supabase.auth.onAuthStateChange` on init so external session changes (e.g., token refresh) don't desync state.

---

## 10. Error handling

Map Supabase exceptions to user-facing messages. Do this in `AuthRepositoryImpl`, not in the UI.

| Supabase error | User-facing message |
|---|---|
| Invalid email format (client-side check) | "That doesn't look like a valid email." |
| Rate limit exceeded | "You've requested a lot of codes recently — try again in a few minutes." |
| Invalid OTP | "That code didn't match. Check your email and try again." |
| Expired OTP | "That code has expired. Tap 'Resend code' to get a new one." |
| Network error | "Couldn't reach the server. Check your connection." |
| Anything else | "Something went wrong. Please try again." |

Never surface raw exception messages to users. Log them via `debugPrint` for developer visibility.

---

## 11. Persistence recap

Only two new keys in `StorageKeys`:
- `lastSavePromptShown` → ISO 8601 string, or null
- `emailLinkedAt` → ISO 8601 string, or null

`StorageService` gets four new members (two getters, two async setters), following the exact pattern of existing fields. See `storage_service.dart` for reference style.

---

## 12. Testing checklist

Do not write automated tests unless explicitly asked. But before declaring done, manually verify:

- [ ] Fresh install → anonymous session created on first launch
- [ ] Play a game → streak saves locally AND appears in Supabase `streaks` table
- [ ] Hit 7-day streak → save prompt appears on results screen
- [ ] Dismiss prompt → doesn't appear again for 7 days
- [ ] Complete OTP flow with valid email → email visible on `auth.users` row, `emailLinkedAt` set in prefs, prompt never fires again
- [ ] Enter wrong code 3 times → sees friendly error each time, can still retry
- [ ] Tap "Resend code" immediately → sees cooldown countdown, no API call fires
- [ ] Tap "Resend code" after 60s → new code arrives, cooldown resets
- [ ] Back out of OtpVerifyScreen → returns to EmailEntryScreen with email preserved
- [ ] Kill app mid-OTP → reopens cleanly, AuthState is `anonymous` (no half-state persistence needed)
- [ ] Airplane mode → sendOtp shows network error, doesn't crash
- [ ] Fresh install on second device + enter same email + verify → new device inherits the streak from server

---

## 13. Order of implementation

Build in this order. Ship each step to a runnable state before moving on:

1. **`pubspec.yaml` + `core/backend/supabase_client.dart` + `main.dart` init.** App should still boot; no visible change. Verify Supabase client is initialized with debug print.
2. **`core/backend/auth_bootstrap.dart` — ensureAnonymousSession().** After launch, `supabase.auth.currentUser` should be non-null. Verify with debug print.
3. **`features/streak/data/sources/streak_remote_source.dart` + updated `StreakRepositoryImpl`.** Play a game, verify a row appears in Supabase `streaks`.
4. **`features/auth/` domain + data layers.** No UI yet.
5. **`features/auth/application/` — controller + providers.** Add a debug button on HomeScreen that calls `sendOtp("your@email.com")` and prints the result. Verify OTP arrives in email.
6. **`OtpInput` widget in isolation.** Drop it into a debug screen. Verify auto-advance, backspace, paste, autofill.
7. **`EmailEntryScreen` + `OtpVerifyScreen`.** Wire them behind the debug button.
8. **`SaveStreakScreen` bottom sheet.** Wire it to the debug button too.
9. **`StreakState` changes + `shouldPromptSave` getter + trigger in `ResultsScreen`.** Remove the debug button.
10. **Manual QA against §12.**

---

## 14. Common mistakes to avoid (feature-specific)

- **Do not** call `supabase.auth.signInWithOtp` directly from a widget. Go through the controller → repository → remote source chain.
- **Do not** put email validation regex in a widget. It lives in the usecase or the field widget's validator prop.
- **Do not** show the raw Supabase error message in the UI. Map it in `AuthRepositoryImpl`.
- **Do not** trigger the save prompt from any screen other than `ResultsScreen`.
- **Do not** persist `AuthState` across app launches. Supabase's own session persistence handles the auth side; `emailLinkedAt` in prefs handles our UI-side derived state.
- **Do not** use `Navigator.pushNamed` for the auth screens — they don't need named routes. Push them directly with `MaterialPageRoute` (or `CupertinoPageRoute` if you want the iOS slide feel; check what the rest of the codebase does).
- **Do not** subscribe to auth state changes in individual widgets. The controller does that once and exposes it via `authControllerProvider`.
- **Do not** add a "Sign in" button on HomeScreen in this pass. That's a follow-up for returning users on new devices; ship the save flow first.

---

## 15. What "done" looks like

- All files in §3.1 exist and follow the patterns in `docs/architecture.md`
- All modifications in §3.2 are made and don't break existing gameplay
- Manual QA in §12 passes
- No new dependencies beyond `supabase_flutter`
- No changes to `core/theme/*` or `core/widgets/*`
- No changes to `features/game/`, `features/home/`, `features/onboarding/`, `features/packs/` (except the one line in `ResultsScreen` which counts as `features/results/`)
- The barrel file `features/auth/auth.dart` exports **only** `authControllerProvider` and the public types (`AuthStatus`, `AuthState`). Nothing else.
