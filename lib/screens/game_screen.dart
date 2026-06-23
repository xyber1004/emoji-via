import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/puzzle_provider.dart';
import '../providers/streak_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/answer_option.dart';
import '../widgets/chunky_button.dart';
import '../widgets/clue_card.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/feedback_sheet.dart';
import '../widgets/hearts_row.dart';
import '../widgets/mascot.dart';
import '../widgets/progress_dots.dart';
import '../widgets/streak_chip.dart';
import '../l10n/app_strings.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  );
  bool _showConfetti = false;

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _pickAnswer(String option, GameState game) {
    final puzzle = game.puzzleSet.puzzles[game.index];
    final isCorrect = option == puzzle.answer;
    ref.read(gameProvider.notifier).pickAnswer(option);
    if (isCorrect) {
      setState(() => _showConfetti = true);
    } else {
      _shakeController.forward(from: 0);
    }
  }

  void _useHint() {
    ref.read(gameProvider.notifier).useHint();
    ref.read(streakProvider.notifier).consumeHint();
  }

  void _advance(GameState game) {
    setState(() => _showConfetti = false);
    if (game.index + 1 >= game.puzzleSet.puzzles.length || game.hearts <= 0) {
      ref.read(streakProvider.notifier).recordPlay(game.toTodayRun());
      context.go('/results');
      return;
    }
    ref.read(gameProvider.notifier).advance();
  }

  @override
  Widget build(BuildContext context) {
    final ec = context.ec;
    final gameState = ref.watch(gameProvider);
    final puzzleAsync = ref.watch(todayPuzzleSetProvider);

    return puzzleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Failed to load puzzles: $e')),
      ),
      data: (puzzleSet) {
        if (gameState == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(gameProvider.notifier)
                .startGame(puzzleSet, ref.read(streakProvider).hintBalance);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final game = gameState;
        final puzzleIndex = game.index.clamp(0, puzzleSet.puzzles.length - 1);
        final puzzle = puzzleSet.puzzles[puzzleIndex];
        final shuffled = puzzle.shuffledOptions(puzzleSet.id, puzzleIndex);
        final inFeedback = game.phase == GamePhase.feedback;
        final wasCorrect =
            game.picked != null && game.picked == puzzle.answer;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final leave = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Leave game?'),
                content: const Text('Your progress will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Stay'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Leave'),
                  ),
                ],
              ),
            );
            if (leave == true && context.mounted) {
              ref.read(gameProvider.notifier).reset();
              context.go('/home');
            }
          },
          child: Scaffold(
            backgroundColor: ec.bg,
            body: ConfettiOverlay(
              trigger: _showConfetti,
              child: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        // Top bar
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Row(
                            children: [
                              HeartsRow(remaining: game.hearts),
                              const Spacer(),
                              ProgressDots(
                                total: puzzleSet.puzzles.length,
                                current: puzzleIndex,
                                results: game.results,
                              ),
                              const Spacer(),
                              HintChip(
                                remaining: game.hints,
                                onTap: !inFeedback && !game.hintShown
                                    ? _useHint
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        // Mascot
                        AnimatedBuilder(
                          animation: _shakeController,
                          builder: (ctx, child) {
                            final dx = sin(_shakeController.value * pi * 6) * 7;
                            return Transform.translate(
                              offset: Offset(dx, 0),
                              child: child,
                            );
                          },
                          child: Mascot(
                            mood: inFeedback
                                ? (wasCorrect
                                    ? MascotMood.celebrate
                                    : MascotMood.sad)
                                : MascotMood.idle,
                            size: 72,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Clue card
                        ClueCard(
                          puzzle: puzzle,
                          hintShown: game.hintShown,
                        ),
                        const Spacer(),
                        // Answer options
                        ...List.generate(shuffled.length, (i) {
                          final option = shuffled[i];
                          final letter = ['A', 'B', 'C', 'D'][i];
                          AnswerOptionState optState;
                          if (!inFeedback) {
                            optState = AnswerOptionState.idle;
                          } else if (option == puzzle.answer) {
                            optState = AnswerOptionState.correct;
                          } else if (option == game.picked) {
                            optState = AnswerOptionState.wrong;
                          } else {
                            optState = AnswerOptionState.dimmed;
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: AnswerOption(
                              letter: letter,
                              label: option,
                              optionState: optState,
                              onTap: !inFeedback
                                  ? () => _pickAnswer(option, game)
                                  : null,
                            ),
                          );
                        }),
                        // Hint button (only shown during ask phase)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: !inFeedback
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12, bottom: 24),
                                  child: ChunkyButton(
                                    label: '💡 Use hint',
                                    variant: ChunkyButtonVariant.ghost,
                                    disabled:
                                        game.hints <= 0 || game.hintShown,
                                    onTap: _useHint,
                                  ),
                                )
                              : const SizedBox(height: 180),
                        ),
                      ],
                    ),
                    // Feedback sheet overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FeedbackSheet(
                        visible: inFeedback,
                        correct: wasCorrect,
                        headline: wasCorrect
                            ? AppStrings.randomCorrect()
                            : AppStrings.randomWrong(),
                        subtext: wasCorrect
                            ? puzzle.answer
                            : 'Answer: ${puzzle.answer}',
                        onNext: () => _advance(game),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
