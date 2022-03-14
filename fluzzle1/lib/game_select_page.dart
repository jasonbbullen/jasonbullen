import 'dart:ui';
import '/table/tile.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/size_config.dart';
import '/game_state.dart';
import '/table/table.dart';
import '/bgnd/rising_rects.dart';


class GameSelectPage extends ConsumerWidget {
  GameSelectPage({Key? key}) : super(key: key);
  CarouselController buttonCarouselController = CarouselController();

  SizeConfig sizeConfig = SizeConfig();

  Difficulty _difficulty = Difficulty.flipTiles;
  NumTiles _numTiles = NumTiles.sixteen;
  Numbers _numbers = Numbers.show;

  int _carouselIndex = 0;

  final List<String> gameImages = [
    "assets/bird.jpg",
    "assets/cat.jpg",
    "assets/fish.jpg",
    "assets/waterfall.jpg",
    "assets/flowers.jpg",
    "assets/rainbow.jpg",
    "assets/path.jpg",
    "assets/train.jpg"
  ];

  Container createCarouselCard(String img) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        image: DecorationImage(
          image: AssetImage(img),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void onSelectButton(WidgetRef ref) {
    bool numbers = (_numbers == Numbers.show);
    bool flip = (_difficulty == Difficulty.flipTiles);

    ref.read(gameStateProvider.notifier).setGameState(GameState(
        id: "1",
        numTiles: _numTiles,
        image: gameImages[_carouselIndex],
        difficulty: _difficulty,
        numMoves: 0,
        numSeconds: 0,
        correct: 0,
        numbers: _numbers));
    ref.read(gameStateProvider.notifier).printState();
    ref.read(tilesProvider.notifier).buildTable(_numTiles);
    ref.read(gameStateProvider.notifier).startSecondsTimer();

    ref.read(gameStateProvider.notifier).resetNumMoves();

    int numCorrect = ref
          .read(tilesProvider.notifier)
          .calculateCorrectTiles(_numTiles);
      ref
          .read(gameStateProvider.notifier)
          .setCorrect(numCorrect);
  }

  Widget drawTitle() {
    return Image.asset('assets/fluzzle.png',
        height: sizeConfig.safeBlockVertical * 10);
  }

  ListView drawCarousel() {
    return ListView(
      shrinkWrap: true,
      children: [
        CarouselSlider(
          carouselController: buttonCarouselController,
          items: [
            createCarouselCard(gameImages[0]),
            createCarouselCard(gameImages[1]),
            createCarouselCard(gameImages[2]),
            createCarouselCard(gameImages[3]),
            createCarouselCard(gameImages[4]),
            createCarouselCard(gameImages[5]),
            createCarouselCard(gameImages[6]),
            createCarouselCard(gameImages[7]),
          ],
          options: CarouselOptions(
            onPageChanged: (index, reason) {
              _carouselIndex = index;
            },
            height: sizeConfig.safeBlockVertical * 20,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: Duration(milliseconds: 800),
            viewportFraction: 0.23,
          ),
        ),
      ],
    );
  }

  Row drawCarouselButtons(WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: ElevatedButton(
            onPressed: () => buttonCarouselController.previousPage(
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: const Icon(
              Icons.rotate_left,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
        const SizedBox(width: 150),
        Flexible(
          child: ElevatedButton(
            onPressed: () => buttonCarouselController.nextPage(
                duration: Duration(milliseconds: 300), curve: Curves.easeInOut),
            child: const Icon(
              Icons.rotate_right,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      ],
    );
  }

  ElevatedButton drawPlayButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0x00ffffff))),
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return TablePage();
        }));

        onSelectButton(ref);
      },
      child: Image.asset('assets/play.png',
          height: sizeConfig.safeBlockVertical * 10),
    );
  }

  Container drawNumberRadios(WidgetRef ref) {
    double height = sizeConfig.safeBlockVertical * 10;
    if (height < 120) {
      height = 120;
    }
    return Container(
        height: height,
        width: 300,
        child: GlassMorphism(
          start: 0.35,
          end: 0.15,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: const Text('Show Numbers'),
                  leading: Radio<Numbers>(
                    value: Numbers.show,
                    groupValue: ref.watch(gameStateProvider).numbers,
                    onChanged: (Numbers? value) {
                      ref.read(gameStateProvider.notifier).setNumbers(value);
                      _numbers = Numbers.show;
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Hide Numbers'),
                  leading: Radio<Numbers>(
                    value: Numbers.hide,
                    groupValue: ref.watch(gameStateProvider).numbers,
                    onChanged: (Numbers? value) {
                      ref.read(gameStateProvider.notifier).setNumbers(value);
                      _numbers = Numbers.hide;
                    },
                  ),
                ),
              ]),
        ));
  }

  Container drawDifficultyRadios(WidgetRef ref) {
    double height = sizeConfig.safeBlockVertical * 10;
    if (height < 120) {
      height = 120;
    }
    return Container(
        height: height,
        width: 300,
        child: GlassMorphism(
          start: 0.35,
          end: 0.15,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: const Text('Slide Tiles'),
                  leading: Radio<Difficulty>(
                    value: Difficulty.slideTiles,
                    groupValue: ref.watch(gameStateProvider).difficulty,
                    onChanged: (Difficulty? value) {
                      ref.read(gameStateProvider.notifier).setDifficulty(value);
                      _difficulty = Difficulty.slideTiles;
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Flip Tiles'),
                  leading: Radio<Difficulty>(
                    value: Difficulty.flipTiles,
                    groupValue: ref.watch(gameStateProvider).difficulty,
                    onChanged: (Difficulty? value) {
                      ref.read(gameStateProvider.notifier).setDifficulty(value);
                      _difficulty = Difficulty.flipTiles;
                    },
                  ),
                ),
              ]),
        ));
  }

  Container drawNumTilesRadios(WidgetRef ref) {
    double height = sizeConfig.safeBlockVertical * 10;
    if (height < 170) {
      height = 170;
    }

    return Container(
        height: height,
        width: 300,
        child: GlassMorphism(
          start: 0.35,
          end: 0.15,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: const Text('3x3 Tiles'),
                  leading: Radio<NumTiles>(
                    value: NumTiles.nine,
                    groupValue: ref.watch(gameStateProvider).numTiles,
                    onChanged: (NumTiles? value) {
                      ref.read(gameStateProvider.notifier).setNumTiles(value);
                      _numTiles = NumTiles.nine;
                    },
                  ),
                ),
                ListTile(
                  title: const Text('4x4 Tiles'),
                  leading: Radio<NumTiles>(
                    value: NumTiles.sixteen,
                    groupValue: ref.watch(gameStateProvider).numTiles,
                    onChanged: (NumTiles? value) {
                      ref.read(gameStateProvider.notifier).setNumTiles(value);
                      _numTiles = NumTiles.sixteen;
                    },
                  ),
                ),
                ListTile(
                  title: const Text('5x5 Tiles'),
                  leading: Radio<NumTiles>(
                    value: NumTiles.twentyFive,
                    groupValue: ref.watch(gameStateProvider).numTiles,
                    onChanged: (NumTiles? value) {
                      ref.read(gameStateProvider.notifier).setNumTiles(value);
                      _numTiles = NumTiles.twentyFive;
                    },
                  ),
                ),
              ]),
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    sizeConfig.update(context);
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            drawTitle(),
            Column(children: <Widget>[
              drawCarousel(),
              drawCarouselButtons(ref),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                drawDifficultyRadios(ref),
                const SizedBox(width: 40),
                drawNumberRadios(ref),
              ],
            ),
            drawNumTilesRadios(ref),
            drawPlayButton(context, ref),
          ],
        ),
              ],)
      ),
    );
  }
}

class GlassMorphism extends StatelessWidget {
  final Widget child;
  final double start;
  final double end;
  const GlassMorphism({
    Key? key,
    required this.child,
    required this.start,
    required this.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(start),
                Colors.white.withOpacity(end),
              ],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              width: 1.5,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
