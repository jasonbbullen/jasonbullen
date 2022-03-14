import 'package:flutter/material.dart';


class MyCustomClipper
	extends CustomClipper<Path> {

  bool noClip = false;

  MyCustomClipper(String s)
  {
    if( s == "noClip") {
      noClip = true;
    }
//    print("HELLOL!!!!!!!!!!!!!" + a.toString());
  }

	@override
	Path getClip(Size size) {
    var path = Path();
    if( noClip ){
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    }
    else{
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);

    }

    return path;
	}
	@override
	bool shouldReclip(oldClipper) => false;
}



class MyCustomClipperRect
	extends CustomClipper<Rect> {

 	@override
	Rect getClip(Size size) {
    final Rect rect;

    rect = const Offset(0, 0) & const Size(120, 120);

    return rect;
  }
	@override
	bool shouldReclip(oldClipper) => false;

  }

