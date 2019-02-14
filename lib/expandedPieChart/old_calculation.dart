
////    _______________
////    |
////    |  1        2
////    |______________
////    |
////    |  3        4
////    |______________
//    int quadrant;
//    if (tapPosition.dx < squareCenter.dx) {
//      if (tapPosition.dy < squareCenter.dy) quadrant = 1;
//      else quadrant = 3;
//    } else {
//      if (tapPosition.dy < squareCenter.dy) quadrant = 2;
//      else quadrant = 4;
//    }
//
//    double distanceTabToCenter = (tapPosition.dx-squareCenter.dx)*(tapPosition.dx-squareCenter.dx)
//        + (tapPosition.dy - squareCenter.dy)*(tapPosition.dy - squareCenter.dy);
//    distanceTabToCenter = sqrt(distanceTabToCenter);
//
//    double distanceKatetToCenter = 0 + (tapPosition.dy - squareCenter.dy)*(tapPosition.dy - squareCenter.dy);
//    distanceKatetToCenter = sqrt(distanceKatetToCenter);
//
//    double angleCos = distanceKatetToCenter/distanceTabToCenter;
//    double angleInRad = acos(angleCos);
//    double angleInGradus = angleInRad*180/pi;
//
//    //finding angle to bottom part of vertical line
//    double angleToBottomVerticalGrad;
//    switch (quadrant) {
//      case 1:
//        angleToBottomVerticalGrad = 180+angleInGradus;
//        break;
//      case 2:
//        angleToBottomVerticalGrad = 180-angleInGradus;
//        break;
//      case 3:
//        angleToBottomVerticalGrad = 360-angleInGradus;
//        break;
//      case 4:
//        angleToBottomVerticalGrad = angleInGradus;
//        break;
//    }