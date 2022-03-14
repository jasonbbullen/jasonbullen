import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/game_state.dart';
import '/game_select_page.dart';
import '/table/tile.dart';
import '/table/floater.dart';
import '/size_config.dart';

class Grid extends ConsumerWidget {
  SizeConfig sizeConfig = SizeConfig();

  late double gridSize;

  Grid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String img = ref.read(gameStateProvider.notifier).getImage();
    NumTiles numTiles = ref.read(gameStateProvider.notifier).getNumTiles();

    List<Tile> tiles = ref.watch(tilesProvider);
    sizeConfig.update(context);
    gridSize = sizeConfig.safeBlockVertical * 50;

    return Stack(
      children: <Widget>[
        GridView.builder(
            shrinkWrap: true,
            itemCount: tiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: calcNumRows(numTiles).toInt(),
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              return gridWidget(tiles[index].id, tiles[index].imgPos, index,
                  tiles, img, numTiles, tiles[index].possibleMove, ref);
            }),
      ],
    );
  }

  Widget gridWidget(String tileId, int imgPos, int index, List<Tile> tiles,
      String img, NumTiles numTiles, Direction move, WidgetRef ref) {
    if (tiles[index].empty) {
      return Container();
    }
    if (tiles[index].animFrom) {
      double tileSize;
      double numRows = calcNumRows(numTiles);
      Difficulty difficulty =
          ref.read(gameStateProvider.notifier).getDifficulty();
      tileSize = gridSize / numRows;
      return FloaterWidget(
          flip: difficulty == Difficulty.flipTiles,
          direction: move,
          imgPos: imgPos,
          tileSize: tileSize,
          index: index,
          gridSize: gridSize);
    }
    return gridTile(imgPos, index, img, numTiles, move, ref);
    // return
    // GestureDetector(
    //         onTapUp: crap,
    //         child:
    // gridTile(imgPos, index, img, numTiles, move, ref),
    //       );
  }

  crap(TapUpDetails) {
//    transformImageTile._onTapUp();
    debugPrint("TapUpDetails");
  }

  static Widget transformImageTile(int imgPos, String img, NumTiles numTiles,
      Difficulty flipMode, bool flipHoriz, bool flipVert, double gridSize) {
    double imgXPosMod = 0;
    double imgXMod = 0;
    double imgYMod = 0;
    double matXMod = 1.0;
    double matYMod = 1.0;

    double numRows = calcNumRows(numTiles);

    double imgY;
    double imgX;

    if (flipMode == Difficulty.slideTiles) {
      imgY =
          -(imgPos / numRows).floorToDouble() * (gridSize / numRows) / numRows;

      imgX =
          -(imgPos % numRows).floorToDouble() * (gridSize / numRows) / numRows;

      flipHoriz = false; // just in case the tile vars are true!
      flipVert = false;
    } else {
      double iMod = -gridSize / numRows;

      if (flipHoriz) {
        imgXPosMod = 1;
        imgXMod = iMod;
        matXMod = -1;
      }

      if (flipVert) {
        imgYMod = iMod;
        matYMod = -1;
      }

      var invertTileLinearMap = [
        0,
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24
      ];

      var invertTile3Map = [3, 4, 5, 6, 7, 8, 0, 1, 2];

      var invertTile4Map = [
        4,
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        0,
        1,
        2,
        3,
      ];

      var invertTile5Map = [
        5,
        6,
        7,
        8,
        9,
        10,
        11,
        12,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
        20,
        21,
        22,
        23,
        24,
        0,
        1,
        2,
        3,
        4
      ];

      if (!flipVert) {
        imgY = -((invertTileLinearMap[imgPos]) / numRows).floorToDouble() *
            (gridSize / numRows) /
            numRows;
      } else {
        if (numRows == 3.0) {
          imgY = -((invertTile3Map[imgPos]) / numRows).floorToDouble() *
              (gridSize / numRows) /
              numRows;
        } else if (numRows == 4.0) {
          imgY = -((invertTile4Map[imgPos]) / numRows).floorToDouble() *
              (gridSize / numRows) /
              numRows;
        } else {
          imgY = -((invertTile5Map[imgPos]) / numRows).floorToDouble() *
              (gridSize / numRows) /
              numRows;
        }
      }
      imgX = -((imgPos + imgXPosMod) % numRows).floorToDouble() *
          (gridSize / numRows) /
          numRows;

      if (imgX == 0.0) {
        imgX = imgXMod;
      }

      if (imgY == -0.0 || imgY == 0.0) {
        imgY = imgYMod;
      }
    }
    Matrix4 matrix = Matrix4(
      matXMod,
      0,
      0,
      0,
      0,
      matYMod,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
    );

    matrix.scale(numRows, numRows);
    matrix.translate(imgX, imgY);

    return ClipRect(
        child: Transform(
            transform: matrix,
            child: Image(
              image: AssetImage(img),
            )));
  }

  Widget gridTile(int imgPos, int index, String img, NumTiles numTiles,
      Direction move, WidgetRef ref) {
    return GestureDetector(
        onTapUp: (details) {
          if (!ref.read(tilesProvider.notifier).getFloaterAnim()) {
            ref.read(tilesProvider.notifier).slideTile(index, numTiles, ref);
          }
        },
        child: Stack(children: <Widget>[
          transformImageTile(
              imgPos,
              img,
              numTiles,
              ref.read(gameStateProvider.notifier).getDifficulty(),
              ref.read(tilesProvider.notifier).getFlipHoriz(index),
              ref.read(tilesProvider.notifier).getFlipVert(index),
              gridSize),
          Grid.showNumbers(
              imgPos,
              ref.read(gameStateProvider.notifier).getNumbers(),
              ref.read(tilesProvider.notifier).getFlipHoriz(index),
              ref.read(tilesProvider.notifier).getFlipVert(index),
              Difficulty.slideTiles),
        ]));
  }

  static Widget drawTileNumber(int imgPos) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Stack(
        children: <Widget>[
          Text(
            (imgPos + 1).toString(),
            style: TextStyle(
              fontSize: 40,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 4
                ..color = Colors.black,
            ),
          ),
          Text(
            (imgPos + 1).toString(),
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  static Widget showNumbers(
      int imgPos, Numbers nums, bool horiz, bool vert, Difficulty diff) {
    if (nums == Numbers.hide) {
      return Container();
    }
//debugPrint("_controller.value = " + value.toString());

    // if( value == -1.0 ){
    //   return Container();
    // }

    if (diff == Difficulty.flipTiles) {
      return Container();
    }

    return Container(
        child: Align(
      alignment: Alignment.topLeft,
      child: drawTileNumber(imgPos),
    ));

//     if( !horiz && !vert){
// //    if( value > 0.5 || value == -1.0 ){
//       else{
// //      if( horiz && !vert){
//         return Row(children: [
//           Container(
//             child: Transform(
//               alignment: Alignment.center, //origin: Offset(100, 100)
//               transform: Matrix4.rotationY(22.0/7.0),
//               child: Container(
//                 child: drawTileNumber(imgPos),
//               ),
//             ),
//           )
//         ],
//         mainAxisAlignment: MainAxisAlignment.end
//       );

//       }
    //   if( !horiz && vert){
    //     return Container(
    //       child: Align(alignment: Alignment.bottomLeft,
    //         child: drawTileNumber(imgPos),
    //       ));
    //     }
    //     if( horiz && vert){
    //       return Container(
    //         child: Align(alignment: Alignment.bottomRight,
    //           child: drawTileNumber(imgPos),
    //         ));
    //       }

    // // return Column(
    // //   mainAxisAlignment: MainAxisAlignment.start,
    // //   crossAxisAlignment: CrossAxisAlignment.start,
    // //   children: <Widget>[

    //     return Container();

    //       Row(
    //         children: [
    // Transform(
    //   transform: Matrix4(
    //   -1,0,0,0,
    //   0,1,0,0,
    //   0,0,1,0,
    //   0,0,0,1,
    //   ),
    //   alignment: FractionalOffset.center,
    //   child:

    //           drawTileNumber(imgPos),

    // )
    //         ]
    //         )]

    //         );
  }
} // Text(

// Offstage(
//   offstage: true,
//   child:

// Opacity(
//   opacity: 1.0,
//   child:
