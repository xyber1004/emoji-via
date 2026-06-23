import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/widgets/confetti_overlay.dart';
import 'package:emojivia/features/game/application/providers/game_providers.dart';
import 'package:emojivia/features/game/application/state/game_state.dart';
import 'package:emojivia/features/game/domain/usecases/shuffle_options.dart';
import 'package:emojivia/features/game/presentation/components/game_top_bar.dart';
import 'package:emojivia/features/game/presentation/widgets/answer_option.dart';
import 'package:emojivia/features/game/presentation/widgets/clue_card.dart';
import 'package:emojivia/features/game/presentation/widgets/feedback_sheet.dart';
import 'package:emojivia/features/streak/streak.dart';
import 'package:emojivia/core/storage/storage_provider.dart';
import 'package:emojivia/app/router.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  bool _confettiTrigger = false;

  static const _shuffle = ShuffleOptions();

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _initGame());
  }

  void _initGame() {
    final puzzleAsync = ref.read(todayPuzzleSetProvider);
    puzzleAsync.whenData((puzzleSet) {
      final storage = ref.read(storageServiceProvider);
      ref.read(gameControllerProvider.notifier).startGame(
            puzzleSet,
            storage.hintBalance,
          );
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave game?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Stay')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Leave')),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleAnswer(String option, GameState game) {
    ref.read(gameControllerProvider.notifier).pickAnswer(option);
    final puzzle = game.puzzleSet.puzzles[game.index];
    if (option == puzzle.answer) {
      setState(() => _confettiTrigger = !_confettiTrigger);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _handleNext(GameState game) async {
    final controller = ref.read(gameControllerProvider.notifier);
    final run = game.toTodayRun();
    final storage = ref.read(storageServiceProvider);
    await storage.saveTodayRunJson(run.toJsonString());

    if (game.isOver) {
      await ref.read(streakControllerProvider.notifier).recordCompletion(
            game.puzzleSet.date,
          );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.results);
    } else {
      controller.advance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final ec = context.ec;

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isOver = gameState.isOver;
    if (isOver && gameState.phase == GamePhase.feedback) {
      // let user tap Next on feedback sheet to navigate — handled in _handleNext
    }

    final puzzle = gameState.index < gameState.puzzleSet.puzzles.length
        ? gameState.puzzleSet.puzzles[gameState.index]
        : null;

    final shuffledOptions = puzzle != null
        ? _shuffle(puzzle.options, gameState.puzzleSet.id, gameState.index)
        : <String>[];

    final copyService = ref.read(feedbackCopyServiceProvider);
    final isCorrect = puzzle != null
        ? gameState.results[gameState.index] == true
        : false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final nav = Navigator.of(context);
          final leave = await _onWillPop();
          if (!leave) return;
          nav.pop();
        }
      },
      child: Scaffold(
        backgroundColor: ec.bg,
        body: SafeArea(
          child: ConfettiOverlay(
            trigger: _confettiTrigger,
            child: Column(
              children: [
                GameTopBar(
                  hearts: gameState.hearts,
                  hints: gameState.hints,
                  total: gameState.puzzleSet.puzzles.length,
                  current: gameState.index,
                  results: gameState.results,
                  onHint: () =>
                      ref.read(gameControllerProvider.notifier).useHint(),
                  onClose: () async {
                    final nav = Navigator.of(context);
                    final leave = await _onWillPop();
                    if (!leave) return;
                    nav.pop();
                  },
                ),
                Expanded(
                  child: puzzle == null
                      ? const Center(child: CircularProgressIndicator())
                      : _buildPuzzleBody(
                          context, ec, gameState, puzzle.emoji,
                          puzzle.category, puzzle.hint, puzzle.answer,
                          shuffledOptions, isCorrect, copyService),
                ),
                if (gameState.phase == GamePhase.feedback)
                  FeedbackSheet(
                    visible: true,
                    isCorrect: isCorrect,
                    copy: isCorrect
                        ? copyService.randomCorrect()
                        : copyService.randomWrong(),
                    correctAnswer: puzzle?.answer ?? '',
                    isLast: isOver,
                    onNext: () => _handleNext(gameState),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzleBody(
    BuildContext context,
    EmojiviaColors ec,
    GameState game,
    String emoji,
    String category,
    String hint,
    String answer,
    List<String> options,
    bool isCorrect,
    dynamic copyService,
  ) {
    final letters = ['A', 'B', 'C', 'D'];

    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) {
        final shake = _shakeAnim.value;
        final offset = shake > 0
            ? 7 * (1 - shake) * (shake % 0.25 < 0.125 ? 1 : -1)
            : 0.0;
        return Transform.translate(offset: Offset(offset, 0), child: child);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClueCard(
              emoji: emoji,
              category: category,
              hint: hint,
              hintVisible: game.hintShown,
            ),
            const SizedBox(height: 20),
            Text(
              'What does this represent?',
              style: AppTypography.body.copyWith(color: ec.inkSoft),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ...List.generate(options.length, (i) {
              final opt = options[i];
              final isPhase = game.phase == GamePhase.feedback;
              AnswerOptionState optState;
              if (!isPhase) {
                optState = AnswerOptionState.idle;
              } else if (opt == answer) {
                optState = AnswerOptionState.correct;
              } else if (opt == game.picked && opt != answer) {
                optState = AnswerOptionState.wrong;
              } else {
                optState = AnswerOptionState.dimmed;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AnswerOption(
                  letter: letters[i],
                  label: opt,
                  state: optState,
                  onTap: isPhase ? null : () => _handleAnswer(opt, game),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
