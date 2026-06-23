// Deterministic shuffle seed — mirrors the algorithm in data.js
int puzzleSeed(int puzzleId, int puzzleIndex) => puzzleId * 31 + puzzleIndex;
