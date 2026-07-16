import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emojivia/core/theme/app_colors.dart';
import 'package:emojivia/core/theme/app_typography.dart';
import 'package:emojivia/core/storage/storage_service.dart';
import 'package:emojivia/core/widgets/confetti_overlay.dart';
import 'package:emojivia/features/game/application/controllers/game_controller.dart';
import 'package:emojivia/features/game/application/services/feedback_copy_service.dart';
import 'package:emojivia/features/game/application/state/game_types.dart';
import 'package:emojivia/features/game/domain/usecases/get_today_puzzles.dart';
import 'package:emojivia/features/game/domain/usecases/shuffle_options.dart';
import 'package:emojivia/features/game/presentation/components/game_top_bar.dart';
import 'package:emojivia/features/game/presentation/widgets/answer_option.dart';
import 'package:emojivia/features/game/presentation/widgets/clue_card.dart';
import 'package:emojivia/features/game/presentation/widgets/feedback_sheet.dart';
import 'package:emojivia/features/streak/streak.dart';
import 'package:emojivia/app/router.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
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

  Future<void> _initGame() async {
    final puzzleSet = await context.read<GetTodayPuzzles>()();
    if (!mounted) return;
    final storage = context.read<StorageService>();
    context.read<GameController>().startGame(puzzleSet, storage.hintBalance);
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

  void _handleAnswer(String option, GameController game) {
    final puzzle = game.puzzleSet!.puzzles[game.index];
    game.pickAnswer(option);
    if (option == puzzle.answer) {
      setState(() => _confettiTrigger = !_confettiTrigger);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _handleNext(GameController game) async {
    final run = game.toTodayRun();
    final storage = context.read<StorageService>();
    final streak = context.read<StreakController>();
    final nav = Navigator.of(context);
    await storage.saveTodayRunJson(run.toJsonString());

    if (game.isFinished) {
      await streak.recordCompletion(game.puzzleSet!.date);
      if (!mounted) return;
      nav.pushReplacementNamed(AppRoutes.results);
    } else {
      game.advance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameController>();
    final ec = context.ec;

    if (!game.isStarted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final puzzleSet = game.puzzleSet!;

    // Self-heal: if the run has advanced past the last puzzle (e.g. a restored
    // or stale state), route straight to results instead of a blank body.
    if (game.isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.results);
        }
      });
      return Scaffold(
        backgroundColor: ec.yellow,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isOver = game.isFinished;

    final puzzle = game.index < puzzleSet.puzzles.length
        ? puzzleSet.puzzles[game.index]
        : null;

    final shuffledOptions = puzzle != null
        ? _shuffle(puzzle.options, puzzleSet.id, game.index)
        : <String>[];

    final copyService = context.read<FeedbackCopyService>();
    final isCorrect =
        puzzle != null ? game.results[game.index] == true : false;

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
        backgroundColor: ec.yellow,
        body: SafeArea(
          child: ConfettiOverlay(
            trigger: _confettiTrigger,
            child: Column(
              children: [
                GameTopBar(
                  hearts: game.hearts,
                  hints: game.hints,
                  total: puzzleSet.puzzles.length,
                  current: game.index,
                  results: game.results,
                  onHint: () => game.useHint(),
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
                          context, ec, game, puzzle.emoji,
                          puzzle.category, puzzle.hint, puzzle.answer,
                          shuffledOptions, isCorrect, copyService),
                ),
                if (game.phase == GamePhase.feedback)
                  FeedbackSheet(
                    visible: true,
                    isCorrect: isCorrect,
                    copy: isCorrect
                        ? copyService.randomCorrect()
                        : copyService.randomWrong(),
                    correctAnswer: puzzle?.answer ?? '',
                    isLast: isOver,
                    onNext: () => _handleNext(game),
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
    GameController game,
    String emoji,
    String category,
    String hint,
    String answer,
    List<String> options,
    bool isCorrect,
    FeedbackCopyService copyService,
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
