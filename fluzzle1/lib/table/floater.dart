import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluzzle1/game_select_page.dart';
import 'tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/game_state.dart';
import 'grid.dart';

class FloaterWidget extends ConsumerStatefulWidget {
  final String id = "1";
  final int imgPos;
  final Direction direction;
  final bool flip;
  final double tileSize;
  final int index;
  final double gridSize;

  FloaterWidget({
    Key? key,
    required this.flip,
    required this.imgPos,
    required this.direction,
    required this.tileSize,
    required this.index,
    required this.gridSize,
  }) : super(key: key);

  @override
  ConsumerState<FloaterWidget> createState() => _FloaterWidgetState();
}

/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _FloaterWidgetState extends ConsumerState<FloaterWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  )
    ..forward()
    ..addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        debugPrint("COMPLETE = " + status.toString());
        NumTiles numTiles = ref.read(gameStateProvider.notifier).getNumTiles();

        ref.read(tilesProvider.notifier).slideComplete(widget.index, numTiles);
        int numCorrect =
            ref.read(tilesProvider.notifier).calculateCorrectTiles(numTiles);

        ref.read(gameStateProvider.notifier).setCorrect(numCorrect);
      }
    });

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Transform updateTransform(bool flip, Direction direction,
      AnimationController controller, Widget child, double tileSize) {
    Point offset;
    if (flip == false) {
      switch (direction) {
        case Direction.up:
          offset = Point(0.0, tileSize);
          break;
        case Direction.down:
          offset = Point(0.0, -tileSize);
          break;
        case Direction.left:
          offset = Point(-tileSize, 0.0);
          break;
        case Direction.right:
        default:
          offset = Point(tileSize, 0.0);
          break;
      }
      return Transform(
        transform: Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
          ..translate(
              offset.x * _controller.value, offset.y * -_controller.value),
//           ..rotateZ(_controller.value * pi * 2.0),
        alignment: FractionalOffset.center,
        child: child,
      );
    }
    double rotX, rotY;
    switch (direction) {
      case Direction.up:
        rotY = 0.0;
        rotX = _controller.value * pi;
        offset = Point(0.0, tileSize);
        break;
      case Direction.down:
        rotY = 0.0;
        rotX = _controller.value * pi;
        offset = Point(0.0, -tileSize);
        break;
      case Direction.left:
        rotY = _controller.value * pi;
        rotX = 0.0;
        offset = Point(tileSize, 0.0);
        break;
      case Direction.right:
      default:
        rotY = _controller.value * pi;
        rotX = 0.0;
        offset = Point(-tileSize, 0.0);
        break;
    }

    return Transform(
      transform: Matrix4(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        ..rotateX(rotX)
        ..rotateY(rotY)
        ..translate(offset.x * _controller.value, offset.y * _controller.value),
//        ..setEntry(3, 1, 0.001),
      alignment: FractionalOffset.center,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    int imgPos = widget.imgPos;
    String img = ref.read(gameStateProvider.notifier).getImage();
    NumTiles numTiles = ref.read(gameStateProvider.notifier).getNumTiles();
    bool flipHoriz =
        ref.read(tilesProvider.notifier).getFlipHoriz(widget.index);
    bool flipVert = ref.read(tilesProvider.notifier).getFlipVert(widget.index);
    Difficulty difficulty =
        ref.read(gameStateProvider.notifier).getDifficulty();

    debugPrint("FLOATER WIDGET value= " + _controller.value.toString());

    return AnimatedBuilder(
      animation: _controller,
      child: Stack(children: <Widget>[
        Grid.transformImageTile(
//            imgPos, img, numTiles, Difficulty.flipTiles, flipHoriz, flipVert, null, widget.gridSize),
            imgPos,
            img,
            numTiles,
            difficulty,
            flipHoriz,
            flipVert,
            widget.gridSize),
        Grid.showNumbers(
            imgPos,
            ref.read(gameStateProvider.notifier).getNumbers(),
            flipHoriz,
            flipVert,
            difficulty),
      ]),
      builder: (BuildContext context, Widget? child) {
        return updateTransform(widget.flip, widget.direction, _controller,
            child!, widget.tileSize);
      },
    );
  }
}


//     return Transform(
//       transform: Matrix4(
//       1,0,0,0,
//       0,1,0,0,
//       0,0,1,0,
//       0,0,0,1,
//       )
//         ..rotateX(rotX)
//         ..rotateY(rotY)
//         ..translate(
//             offset.x * _controller.value, offset.y * _controller.value),
// //        ..setEntry(3, 1, 0.001),
//       alignment: FractionalOffset.center,
//       child: child,
//     );


// ok buddy - ignore this shit - just storing code

    // return AnimatedBuilder(
    //   animation: _controller,
    //   child: Stack(children: <Widget>[
    //     Image.asset(img,
    //       height: 1000,     //JASON TODO - but it works (seems clipped by the gridview)
    //       alignment: Alignment.center,
    //       fit: BoxFit.fill,
    //     ),
    //   ]),
    //   builder: (BuildContext context, Widget? child) {
    //     return updateTransform(widget.flip, widget.direction,_controller,child!, widget.tileSize);
    //   },
    // );



//     AnimatedBuilder(
//       animation: _controller,
//       child: Stack(children: <Widget>[
// Transform(
//       transform: matrix,
//       child:
//         Image.asset(img,
//           height: 150,     //JASON TODO - but it works (seems clipped by the gridview)
//           alignment: Alignment.center,
//           fit: BoxFit.fill,
//         ),
//       ),
//         showNumbers(imgPos, ref.read(gameStateProvider.notifier).getNumbers(), Direction.up),
//       ]),
       
//       builder: (BuildContext context, Widget? child) {
//         return updateTransform(widget.flip, widget.direction,_controller,child!, widget.tileSize);
//       },
//     );












// clips the sliding floater
// return 
//                           ClipRect(
//                             child: Align(
//                               alignment: Alignment.topCenter,
//                               heightFactor: 0.5,
//                               child:

//     AnimatedBuilder(
//       animation: _controller,
//       child: Stack(children: <Widget>[
//       Transform(
//       transform: matrix,
//       child:
//         Image.asset(img,
// //          height: 150,     //JASON TODO - but it works (seems clipped by the gridview)
//           alignment: Alignment.center,
//           fit: BoxFit.fill,
//         ),
//       ),

//         showNumbers(imgPos, ref.read(gameStateProvider.notifier).getNumbers(), Direction.up),
//       ]),
       
//       builder: (BuildContext context, Widget? child) {
//         return updateTransform(widget.flip, widget.direction,_controller,child!, widget.tileSize);
//       },
//     )));


//debugPrint("floater - imgPos = " + imgPos.toString());
//return 
                          // ClipRect(
                          //   child: Align(
                          //     alignment: Alignment.topCenter,
                          //     heightFactor: 0.5,
                          //     child:

//     AnimatedBuilder(
//       animation: _controller,
//       child: Stack(children: <Widget>[
//       Transform(
//       transform: matrix,
//       child:
//                           ClipRect(
//                             child: Align(
//                               alignment: Alignment.topCenter,
//                               heightFactor: 0.5,
//                               child:
//         Image.asset(img,
// //          height: 150,     //JASON TODO - but it works (seems clipped by the gridview)
//           alignment: Alignment.center,
//           fit: BoxFit.fill,
//         ),
//       ),),),

//         showNumbers(imgPos, ref.read(gameStateProvider.notifier).getNumbers(), Direction.up),
//       ]),
       
//       builder: (BuildContext context, Widget? child) {
//         return updateTransform(widget.flip, widget.direction,_controller,child!, widget.tileSize);
//       },
//     );




