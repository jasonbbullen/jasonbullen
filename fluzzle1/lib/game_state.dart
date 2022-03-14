import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game_select_page.dart';

enum Difficulty { flipTiles, slideTiles }
enum NumTiles { nine, sixteen, twentyFive }
enum Numbers { show, hide }

@immutable
class GameState {
  const GameState({
    required this.id,
    required this.numTiles,
    required this.image,
    required this.difficulty,
    required this.numbers,
    required this.numMoves,
    required this.numSeconds,
    required this.correct,
  });

  final String id;
  final NumTiles numTiles;
  final String image;
  final Difficulty difficulty;
  final Numbers numbers;
  final int numMoves;
  final int numSeconds;
  final int correct;

  GameState copyWith(
      {String? id,
      NumTiles? numTiles,
      String? image,
      Difficulty? difficulty,
      double? imageSize,
      int? numMoves,
      int? numSeconds,
      Numbers? numbers,
      int? correct
      }) {
    return GameState(
      id: id ?? this.id,
      numTiles: numTiles ?? this.numTiles,
      image: image ?? this.image,
      difficulty: difficulty ?? this.difficulty,
      numbers: numbers ?? this.numbers,
      numMoves: numMoves ?? this.numMoves,
      numSeconds: numSeconds ?? this.numSeconds,
      correct: correct ?? this.correct,
    );
  }
}

// The StateNotifier class that will be passed to our StateNotifierProvider.
// This class should not expose state outside of its "state" property, which means
// no public getters/properties!
// The public methods on this class will be what allow the UI to modify the state.
class GameStateNotifier extends StateNotifier<GameState> {
  // We initialize the list of Tiles to an empty list
  GameStateNotifier()
      : super(const GameState(
            id: "1",
            numTiles: NumTiles.sixteen,
            image: "IMG",
            difficulty: Difficulty.flipTiles,
            numMoves: 0,
            numSeconds: 0,
            correct: 0,
            numbers: Numbers.show));

  void setDifficulty(Difficulty? diff) {
    state = state.copyWith(difficulty: diff);
  }

  void incNumMoves() {
    int oldNum = state.numMoves;
    oldNum++;
    GameState copy = state;
    copy = copy.copyWith(numMoves: oldNum);
    state = copy;
  }

  void resetNumMoves() {
    GameState copy = state;
    copy = copy.copyWith(numMoves: 0);
    state = copy;
  }


  Timer ti = Timer.periodic(Duration(seconds: 1), (Timer t) {});

  void startSecondsTimer() {
    const oneSec = Duration(seconds: 1);
    ti.cancel();
    ti = Timer.periodic(oneSec, (Timer t) {
      int oldSecs = state.numSeconds;
      oldSecs++;
      GameState copy = state;
      copy = copy.copyWith(numSeconds: oldSecs);
      state = copy;
    });
  }

  void cancelSecondsTimer(){
    ti.cancel();
  }

  void resetSecondsTimer(){
    GameState copy = state;
    copy = copy.copyWith(numSeconds: 0);
    state = copy;
    startSecondsTimer();
  }

  Difficulty getDifficulty() {
    return state.difficulty;
  }

  void setImage(String img) {
    state = state.copyWith(image: img);
  }

  String getImage() {
    return state.image;
  }

  void setNumTiles(NumTiles? num) {
    state = state.copyWith(numTiles: num);
  }

  NumTiles getNumTiles() {
    return state.numTiles;
  }

  void setNumbers(Numbers? nums) {
    state = state.copyWith(numbers: nums);
  }

  Numbers getNumbers() {
    return state.numbers;
  }

  void setCorrect(int? count) {

    GameState copy = state;
    copy = copy.copyWith(correct: count);
    state = copy;
//    state = state.copyWith(correct: count);
  }

  int getCorrect() {
    return state.correct;
  }

  GameState getGameState() {
    return state;
  }

  // Let's allow the UI to add Tiles.
  void setGameState(GameState newState) {
    state = newState;
  }

  void printState() {
    print("state: id=" +
        state.id.toString() +
        " numTiles=" +
        state.numTiles.toString() +
        " image=" +
        state.image.toString() +
        " flip=" +
        state.difficulty.toString() +
        " numbers=" +
        state.numbers.toString());
  }
}

final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});
