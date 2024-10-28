// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class DrawingPoint {
  int id;
  List<Offset> offset;
  Color color;
  double width;
  DrawingPoint({
    this.id = -1,
    this.offset = const [],
    this.color = Colors.black,
    this.width = 2,
  });

  DrawingPoint copyWith({List<Offset>? offset}) {
    return DrawingPoint(
      color: color,
      id: id,
      offset: offset ?? this.offset,
      width: width,
    );
  }
}
