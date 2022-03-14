import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'game_select_page.dart';
import 'navigator.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(        
        debugShowCheckedModeBanner: false,
        home: GameSelectPage()),
    ),
  );
}


  // Container drawTestSquare() {
  //   return Container(
  //     height: sizeConfig.blockSizeVertical * 5,
  //     width: sizeConfig.blockSizeHorizontal * 50,
  //     color: Colors.orange,
  //   );
  // }

//nice transition
//https://l.messenger.com/l.php?u=https%3A%2F%2Fmedium.com%2F%40agungsurya%2Fcreate-custom-router-transition-in-flutter-using-pageroutebuilder-73a1a9c4a171&h=AT0zOmfqmMZamPi-QWrwBw5XeDv7JJC2WmYszfs6Eyw9rrIsFSxGGQ58XNv0roJrsHFXvpEXDXPddGpboelIxZJ1LIAhaYNdLjk5yDlv8qu5bESyWHVD1MYvkar0Wb-qgVQ




// //TODO
// fix blue line between tiles

// maybe show a summary screen - LOL

//fix spacing between table buttons at bottom

// add groovy particles to newely correct tile position

// drag the image selector

// enable tapping the text number of the tile

