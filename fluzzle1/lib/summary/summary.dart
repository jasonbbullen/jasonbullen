import 'dart:ui';
import '/table/tile.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/size_config.dart';
import '/game_state.dart';
import '/table/table.dart';

import '/game_select_page.dart';



//const kImageSize = 600.0;

class GameSummaryPage extends ConsumerWidget {
  GameSummaryPage({Key? key}) : super(key: key);
  
  SizeConfig sizeConfig = SizeConfig();

  Widget drawTitle() {
    return Image.asset('assets/fluzzle.png',
        height: sizeConfig.safeBlockVertical * 10);
  }

  ElevatedButton drawPlayButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all<Color>(const Color(0x00ffffff))),

       onPressed: () {

//Navigator.popUntil(context, ModalRoute.withName('GameSelectPage'));},
                      Navigator.of(context).pop();
                    Navigator.of(context).pop();
       },

//       onPressed: () {
//         Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//           return GameSelectPage();
//         }));
// //        onSelectButton(ref);
//       },
      child: Image.asset('assets/continue.png',
          height: sizeConfig.safeBlockVertical * 10),
    );
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            drawTitle(),
            Column(children: <Widget>[
//              drawCarousel(),
//              drawCarouselButtons(ref),
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                drawDifficultyRadios(ref),
//                const SizedBox(width: 40),
//                drawNumberRadios(ref),
              ],
            ),
          Image(image: AssetImage('assets/smileyDoll.png'),),
//            drawNumTilesRadios(ref),
            drawPlayButton(context, ref),
          ],
        ),
      ),
    );
  }
}
// 