import 'dart:ui';

import 'package:flutter/material.dart';

class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double aspectRadio;

  ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.overlayColor = const Color(0x88000000),
    this.aspectRadio,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(10.0);

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect)
      ..lineTo(
        rect.right,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.bottom,
      )
      ..lineTo(
        rect.left,
        rect.top,
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    const lineSize = 20;
    final width = rect.width;
    final borderWidthSize = width *0.1;
    final height = rect.height;
    final borderHeightSize = height - (width - borderWidthSize);
    final borderSize = Size(borderWidthSize / 2, borderHeightSize / 2);
    final paddingTop = (height-width*0.9/aspectRadio)/2;
    final paddingBottom = (height-width*0.9/aspectRadio)/2;

    var paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.top, rect.right, rect.top+paddingTop),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.height-paddingBottom, rect.right, rect.bottom),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.left, rect.top+paddingTop, rect.left + borderSize.width, rect.height-paddingBottom),
        paint,
      )
      ..drawRect(
        Rect.fromLTRB(rect.right - borderSize.width, rect.top+paddingTop, rect.right, rect.height-paddingBottom),
        paint,
      );

    paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderOffset = borderWidth / 2;
    final realReact = Rect.fromLTRB(
        borderSize.width + borderOffset,
        paddingTop + borderOffset + rect.top,
        width - borderSize.width - borderOffset,
        rect.height-paddingBottom);

    //Draw top right corner
    canvas
      ..drawPath(
          Path()
            ..moveTo(realReact.right+3, realReact.top)
            ..lineTo(realReact.right+3, realReact.top + lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.right, realReact.top-3)
            ..lineTo(realReact.right - lineSize, realReact.top-3),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.right+3, realReact.top-3)],
        paint,
      )

    //Draw top left corner
      ..drawPath(
          Path()
            ..moveTo(realReact.left-3, realReact.top)
            ..lineTo(realReact.left-3, realReact.top + lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.left, realReact.top-3)
            ..lineTo(realReact.left + lineSize, realReact.top-3),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.left-3, realReact.top-3)],
        paint,
      )

    //Draw bottom right corner
      ..drawPath(
          Path()
            ..moveTo(realReact.right+3, realReact.bottom)
            ..lineTo(realReact.right+3, realReact.bottom - lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.right, realReact.bottom)
            ..lineTo(realReact.right - lineSize, realReact.bottom),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.right+3, realReact.bottom)],
        paint,
      )

    //Draw bottom left corner
      ..drawPath(
          Path()
            ..moveTo(realReact.left-3, realReact.bottom)
            ..lineTo(realReact.left-3, realReact.bottom - lineSize),
          paint)
      ..drawPath(
          Path()
            ..moveTo(realReact.left, realReact.bottom)
            ..lineTo(realReact.left + lineSize, realReact.bottom),
          paint)
      ..drawPoints(
        PointMode.points,
        [Offset(realReact.left-3, realReact.bottom)],
        paint,
      );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
      aspectRadio: aspectRadio
    );
  }
}