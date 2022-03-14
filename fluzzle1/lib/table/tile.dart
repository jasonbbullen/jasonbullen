import 'dart:math';
import '/game_state.dart';

import 'package:flutter/material.dart';
import 'clipper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Direction { none, up, down, left, right }

// The state of our StateNotifier should be immutable.
// We could also use packages like Freezed to help with the implementation.
@immutable
class Tile {
  const Tile({
    required this.id,
    required this.imgPos,
    required this.empty,
    required this.possibleMove,
    required this.animFrom,
    required this.flipVert,
    required this.flipHoriz,
  });

  // All properties should be `final` on our class.
  final String id;
  final int imgPos;
  final bool empty;
  final Direction possibleMove;
  final bool animFrom;
  final bool flipVert;
  final bool flipHoriz;

  // Since Tile is immutable, we implement a method that allows cloning the
  // Tile with slightly different content.
  Tile copyWith(
      {String? id, int? imgPos, Direction? possibleMove, bool? empty, bool? animFrom, bool? flipVert, bool? flipHoriz}) {
    return Tile(
      id: id ?? this.id,
      imgPos: imgPos ?? this.imgPos,
      empty: empty ?? this.empty,
      animFrom: animFrom ?? this.animFrom,
      possibleMove: possibleMove ?? this.possibleMove,
      flipVert: flipVert ?? this.flipVert,
      flipHoriz: flipHoriz ?? this.flipHoriz,
    );
  }
}

// The StateNotifier class that will be passed to our StateNotifierProvider.
// This class should not expose state outside of its "state" property, which means
// no public getters/properties!
// The public methods on this class will be what allow the UI to modify the state.
class TilesNotifier extends StateNotifier<List<Tile>> {
  // We initialize the list of Tiles to an empty list
  TilesNotifier() : super([]);

  late Tile storedTile;
  late bool floaterAnimating = false;

  bool getFlipVert(int index){
    return state[index].flipVert;
  }

  bool getFlipHoriz(int index){
    return state[index].flipHoriz;
  }

  bool getFloaterAnim(){
    return floaterAnimating;
  }

  void setFloaterAnim(bool anim){
    floaterAnimating = anim;
  }

  void copyTile(int index){
    storedTile = state[index];
  }

  Tile getTile(){
    return storedTile;
  }

  void swapTiles(int t1, int t2) {
    Tile temp;
    List<Tile> copy = state.toList();
    temp = copy[t1];
    copy[t1] = copy[t2];
    copy[t2] = temp;
    state = copy.toList();
  }

  void empty() {
    state = [];
  }

  void addTile(Tile tile) {
    state = [...state, tile];
  }

  void removeTile(String tileId) {
    state = [
      for (final tile in state)
        if (tile.id != tileId) tile,
    ];
  }

  void buildLinearTable(double numTiles) {
    Random _random = Random();
    String rndS;
    bool isEmpty;
    for (int i = 0; i < numTiles; i++) {
      rndS = _random.nextInt(1000000).toString();
      isEmpty = i == (numTiles - 1) ? true : false;
      addTile(Tile(
        id: "Uniq" + rndS,
        imgPos: i,
        empty: isEmpty,
        animFrom: false,
        possibleMove: Direction.none,
        flipVert: false,
        flipHoriz: false,
      ));
    }
  }

  void calculateDirections(NumTiles eNumTiles) {
    Direction direction;
    int emptyI;
    Tile tile;

    double numRows = calcNumRows(eNumTiles);
    double numTiles = numRows * numRows;

    emptyI = getEmptyI(numTiles);

    for (int i = 0; i < numTiles; i++) {
      tile = state[i];
      direction =
          calcPossibleMove(index: i, emptyI: emptyI, eNumTiles: eNumTiles);
      debugPrint("buildTable eNumTiles=" + direction.toString());

      state[i] = state[i].copyWith(possibleMove: direction);
    }
  }


  void slideComplete(int index, NumTiles eNumTiles){
    setFloaterAnim(false);

    List<Tile> copy;
    copy = state.toList();
    copy[index] = copy[index].copyWith(animFrom: false);
    state = copy.toList();


    double numRows = calcNumRows( eNumTiles);
    double numTiles = numRows * numRows;


    int emptyI;
    emptyI = getEmptyI(numTiles);

    swapTiles(index, emptyI);
    calculateDirections(eNumTiles);

    calculateFlips(eNumTiles);

    calculateCorrectTiles(eNumTiles);
  }


  int calculateCorrectTiles(NumTiles eNumTiles) {
    double numRows = calcNumRows(eNumTiles);
    double numTiles = numRows * numRows;
    int count=0;
    Tile tile;

    for (int i = 0; i < numTiles; i++) {
      tile = state[i];
      if( tile.imgPos == i){
        count++;
      }
    }
    return count;
  }


  void slideTile(int index, NumTiles eNumTiles, WidgetRef ref) {
    if (state[index].possibleMove == Direction.none) {
      return;
    }

    ref.read(gameStateProvider.notifier).incNumMoves();

    setFloaterAnim(true);

    List<Tile> copy;
    copy = state.toList();
    copy[index] = copy[index].copyWith(animFrom: true);
    state = copy.toList();

    calculateDirections(eNumTiles);
  }


  void shuffleTiles(double end) {
    List<Tile> copy = state.toList();
    _shuffle(copy, 0, end.toInt());
    state = copy.toList();
  }

  void buildTable(NumTiles eNumTiles) {
    debugPrint("buildTable");

    double numRows = calcNumRows(eNumTiles);
    double numTiles = numRows * numRows;

    empty();

    buildLinearTable(numTiles);

    bool tryAgain = true;
    while(tryAgain){
      shuffleTiles(numTiles - 1);
      if( calculateCorrectTiles(eNumTiles) <= 3){
        tryAgain = false;
      }
    }

    calculateFlips( eNumTiles);

    calculateDirections(eNumTiles);

  }

  int getEmptyI(double numTiles) {
    Tile tile;
    for (int i = 0; i < numTiles; i++) {
      tile = state[i];
      if (tile.empty) {
        return i;
      }
    }
    return 0;
  }


  void calculateFlips(NumTiles eNumTiles) {
    double numRows = calcNumRows(eNumTiles);

    int dx, dy, imgPos, idxPos;
    bool horiz, vert;
    Tile tile;
    List<Tile> copy;
    for (int iy = 0; iy < numRows; iy++) {
      for (int ix = 0; ix < numRows; ix++) {
        idxPos = iy * numRows.toInt() + ix;
        tile = state[idxPos];
        imgPos = tile.imgPos;

        dx = imgPos%numRows.toInt();
        dy = imgPos~/numRows;

        dx = (ix-dx).abs();
        dy = (iy-dy).abs();

        horiz = ( dx % 2.0) == 1;
        vert = ( dy % 2.0) == 1;

        copy = state.toList();
        copy[idxPos] = copy[idxPos].copyWith(flipHoriz:horiz, flipVert:vert );
        state = copy.toList();
      }
    }
  }

  void _shuffle(List elements, [int start = 0, int? end]) {
    Random _random = Random();
    end ??= elements.length;
    var length = end - start;
    while (length > 1) {
      var pos = _random.nextInt(length);
      length--;
      var tmp1 = elements[start + pos];
      elements[start + pos] = elements[start + length];
      elements[start + length] = tmp1;
    }
  }
}

Direction calcPossibleMove(
    {required int index, required int emptyI, required NumTiles eNumTiles}) {
  switch (eNumTiles) {
    case NumTiles.nine:
      switch (emptyI) {
        case 0:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI + 3) {
            return Direction.up;
          }
          break;
        case 1:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI + 3) {
            return Direction.up;
          }
          break;
        case 2:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 3) {
            return Direction.up;
          }
          break;
        case 3:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 3) {
            return Direction.down;
          }
          if (index == emptyI + 3) {
            return Direction.up;
          }
          break;
        case 4:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 3) {
            return Direction.down;
          }
          if (index == emptyI + 3) {
            return Direction.up;
          }
          break;
        case 5:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI - 3) {
            return Direction.down;
          }
          if (index == emptyI + 3) {
            return Direction.up;
          }
          break;
        case 6:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 3) {
            return Direction.down;
          }
          break;
        case 7:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 3) {
            return Direction.down;
          }
          break;
        case 8:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI - 3) {
            return Direction.down;
          }
          break;
      }
      break;
    case NumTiles.twentyFive:
      switch (emptyI) {
        case 0:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI + 5) {
            return Direction.up;
          }
          break;
        case 1:
        case 2:
        case 3:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI + 5) {
            return Direction.up;
          }
          break;
        case 4:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 5) {
            return Direction.up;
          }
          break;
        case 5:
        case 10:
        case 15:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 5) {
            return Direction.down;
          }
          if (index == emptyI + 5) {
            return Direction.up;
          }
          break;
        case 6:
        case 7:
        case 8:
        case 11:
        case 12:
        case 13:
        case 16:
        case 17:
        case 18:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 5) {
            return Direction.down;
          }
          if (index == emptyI + 5) {
            return Direction.up;
          }
          break;
        case 9:
        case 14:
        case 19:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI - 5) {
            return Direction.down;
          }
          if (index == emptyI + 5) {
            return Direction.up;
          }
          break;
        case 20:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 5) {
            return Direction.down;
          }
          break;
        case 21:
        case 22:
        case 23:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 5) {
            return Direction.down;
          }
          break;
        case 24:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI - 5) {
            return Direction.down;
          }
          break;
      }
      break;
    case NumTiles.sixteen:
    default:
      switch (emptyI) {
        case 0:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI + 4) {
            return Direction.up;
          }
          break;
        case 1:
        case 2:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI + 4) {
            return Direction.up;
          }
          break;
        case 3:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 4) {
            return Direction.up;
          }
          break;
        case 4:
        case 8:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 4) {
            return Direction.down;
          }
          if (index == emptyI + 4) {
            return Direction.up;
          }
          break;
        case 5:
        case 6:
        case 9:
        case 10:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 4) {
            return Direction.down;
          }
          if (index == emptyI + 4) {
            return Direction.up;
          }
          break;
        case 7:
        case 11:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI - 4) {
            return Direction.down;
          }
          if (index == emptyI + 4) {
            return Direction.up;
          }
          break;
        case 12:
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 4) {
            return Direction.down;
          }
          break;
        case 13:
        case 14:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI + 1) {
            return Direction.left;
          }
          if (index == emptyI - 4) {
            return Direction.down;
          }
          break;
        case 15:
          if (index == emptyI - 1) {
            return Direction.right;
          }
          if (index == emptyI - 4) {
            return Direction.down;
          }
          break;
      }
      break;
  }
  return Direction.none;
}

double calcNumRows(NumTiles numTiles) {
  switch (numTiles) {
    case NumTiles.nine:
      return 3;
    case NumTiles.twentyFive:
      return 5;
    case NumTiles.sixteen:
    default:
      return 4;
  }
}

// Finally, we are using StateNotifierProvider to allow the UI to interact with
// our tilesNotifier class.
final tilesProvider = StateNotifierProvider<TilesNotifier, List<Tile>>((ref) {
  return TilesNotifier();
});
