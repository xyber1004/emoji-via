import 'dart:math';

class ShuffleOptions {
  const ShuffleOptions();

  // seed = puzzleId * 31 + puzzleIndex (deterministic — same on all devices)
  List<String> call(List<String> options, int puzzleId, int puzzleIndex) {
    final seed = puzzleId * 31 + puzzleIndex;
    final rng = Random(seed);
    final copy = List<String>.from(options);
    for (var i = copy.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = copy[i];
      copy[i] = copy[j];
      copy[j] = tmp;
    }
    return copy;
  }
}
