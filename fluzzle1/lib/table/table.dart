import 'package:flutter/material.dart';
import 'package:fluzzle1/game_select_page.dart';
import 'tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'grid.dart';
import '/game_state.dart';
import '/size_config.dart';
import '/bgnd/rising_rects.dart';
import '/summary/summary.dart';

const double borderPerc = 1.0;

const double kGridSize = 200.0;
const double kTopSize = 24.0 * borderPerc;
const double kBottomSize = 24.0 * borderPerc;
const double kSideSize = 24.0 * borderPerc;

class TablePage extends ConsumerWidget {
  SizeConfig sizeConfig = SizeConfig();
  TablePage({Key? key}) : super(key: key);

  Widget drawTitle() {
    return Image.asset('assets/fluzzle.png',
        height: sizeConfig.safeBlockVertical * 10);
  }

  Widget drawCorrectText(
      int numCorrect, double numTiles, BuildContext context, WidgetRef ref ) {
    if (numCorrect == numTiles) {
      ref.read(gameStateProvider.notifier).cancelSecondsTimer();

      return drawContinueButton(context);
    } else {
      String comp = numCorrect.toString() + "/" + (numTiles.toInt()).toString();
      return Column(children: [
        const Text(
          "CORRECT TILES",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          comp,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50),
        ),
      ]);
    }
  }

  Widget drawMovesText(int numMoves) {
    return Column(
      children: [
        const Text(
          "NUMBER OF MOVES",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          numMoves.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50),
        )
      ],
    );
  }

  Widget drawTimeText(int numSecs) {
    return Column(
      children: [
        const Text(
          "NUMBER OF SECONDS",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          numSecs.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50),
        )
      ],
    );
  }

  Widget drawTimeTextOpt(WidgetRef ref) {
    int NumSeconds = ref.watch(gameStateProvider).numSeconds;

    return Column(
      children: [
        const Text(
          "NUMBER OF SECONDS",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          NumSeconds.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 50),
        )
      ],
    );
  }

  Widget drawHelpImage(String sImg) {
    return Image(
      image: AssetImage(sImg),
      height: 200.0,
      width: 200.0,
    );
  }

  Widget drawGridAndBorder(double gridSize) {
    return Center(
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: kSideSize,
                height: kTopSize,
                child: Image.asset(
                  'assets/border/borderTL.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: gridSize,
                height: kTopSize,
                child: Image.asset(
                  'assets/border/borderT.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: kSideSize,
                height: kTopSize,
                child: Image.asset(
                  'assets/border/borderTR.png',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: kSideSize,
                height: gridSize,
                child: Image.asset(
                  'assets/border/borderL.png',
                  fit: BoxFit.fill,
                ),
              ),
              // Positioned.fill(

              Container(
                color: const Color(0xff3ccff9),
                height: gridSize,
                width: gridSize,
                child: Grid(),
              ),
              Container(
                width: kSideSize,
                height: gridSize,
                child: Image.asset(
                  'assets/border/borderR.png',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: kSideSize,
                height: kBottomSize,
                child: Image.asset(
                  'assets/border/borderBL.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: gridSize,
                height: kBottomSize,
                child: Image.asset(
                  'assets/border/borderB.png',
                  fit: BoxFit.fill,
                ),
              ),
              Container(
                width: kSideSize,
                height: kBottomSize,
                child: Image.asset(
                  'assets/border/borderBR.png',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        ]));
  }

  ElevatedButton drawContinueButton(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0x00ffffff))),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Image.asset('assets/continue.png',
          height: sizeConfig.safeBlockVertical * 5),
    );
  }

  ElevatedButton drawShuffleButton() {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0x00ffffff))),
      onPressed: () {},
      child: Image.asset('assets/shuffle.png',
          height: sizeConfig.safeBlockVertical * 5),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("TABLE BUILD");

    sizeConfig.update(context);
    String img = ref.watch(gameStateProvider.notifier).getImage();
    NumTiles numTiles = ref.watch(gameStateProvider.notifier).getNumTiles();
    double numRows = calcNumRows(numTiles);

    int NumMoves = ref.watch(gameStateProvider).numMoves;
//    int NumSeconds = ref.watch(gameStateProvider).numSeconds;

    double gridSize = sizeConfig.safeBlockVertical * 50;
    bool portrait = sizeConfig.portraitMode;

    int numCorrect = ref.read(gameStateProvider.notifier).getCorrect();

    if (portrait) {
      return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/bgndSquaresVert.jpg'),
              fit: BoxFit.fill,
            )),
            child: Stack(
              children: [
                Positioned.fill(child: Particles(20)),
                Column(
                  // crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    drawTitle(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          drawMovesText(NumMoves),
                          drawHelpImage(img),
//                          drawTimeText(NumSeconds),
                          drawTimeTextOpt(ref),
                        ]),
                    drawGridAndBorder(gridSize),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0x00ffffff))),
                          onPressed: () {
                            ref
                                .read(tilesProvider.notifier)
                                .buildTable(numTiles);
                            ref
                                .read(gameStateProvider.notifier)
                                .resetSecondsTimer();
                            ref
                                .read(gameStateProvider.notifier)
                                .resetNumMoves();
                            numCorrect = ref
                                .read(tilesProvider.notifier)
                                .calculateCorrectTiles(numTiles);
                            ref
                                .read(gameStateProvider.notifier)
                                .setCorrect(numCorrect);
                        },
                          child: Image.asset('assets/shuffle.png',
                              height: sizeConfig.safeBlockVertical * 5),
                        ),

                        drawCorrectText(numCorrect, numRows * numRows, context, ref),
                        (numCorrect != numRows * numRows)?
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    const Color(0x00ffffff))),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Image.asset('assets/back.png',
                                height: sizeConfig.safeBlockVertical * 5),
                          ):Container(),
                        ],
                    )
                  ],
                ),
              ],
            )),
      );
    } else {
      return Scaffold(
          body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
          image: AssetImage('assets/bgndSquares.jpg'),
          fit: BoxFit.fill,
        )),
        child: Stack(
          children: [
            Positioned.fill(child: Particles(20)),
            Column(

                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  drawTitle(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              drawMovesText(NumMoves),
                              const SizedBox(
                                height: 40,
                              ),
                              drawHelpImage(img),
                              const SizedBox(
                                height: 40,
                              ),
//                                drawTimeText(NumSeconds),
                              drawTimeTextOpt(ref),
                            ]),
                        drawGridAndBorder(gridSize),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0x00ffffff))),
                              onPressed: () {
                                ref
                                    .read(tilesProvider.notifier)
                                    .buildTable(numTiles);
                                ref
                                    .read(gameStateProvider.notifier)
                                    .resetSecondsTimer();
                                ref
                                    .read(gameStateProvider.notifier)
                                    .resetNumMoves();

                                numCorrect = ref
                                    .read(tilesProvider.notifier)
                                    .calculateCorrectTiles(numTiles);
                                ref
                                    .read(gameStateProvider.notifier)
                                    .setCorrect(numCorrect);
                              },
                              child: Image.asset('assets/shuffle.png',
                                  height: sizeConfig.safeBlockVertical * 5),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            drawCorrectText(
                                numCorrect, numRows * numRows, context,ref),
                            const SizedBox(
                              height: 40,
                            ),
                            (numCorrect != numRows * numRows)?
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0x00ffffff))),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Image.asset('assets/back.png',
                                  height: sizeConfig.safeBlockVertical * 5),
                            ):Container(),
                          ],
                        ),
                      ])
                ])
          ],
        ),
      ));
    }
  }
}
