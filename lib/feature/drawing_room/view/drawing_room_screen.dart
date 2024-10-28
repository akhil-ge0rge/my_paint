import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_paint/feature/drawing_room/model/drawing_point.dart';

class DrawingRoomScreen extends StatefulWidget {
  const DrawingRoomScreen({super.key});

  @override
  State<DrawingRoomScreen> createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<DrawingRoomScreen> {
  var availableColors = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var selectedColor;
  var selectedWidth;

  var historyDrawingPoint = <DrawingPoint>[];
  var drawingPoint = <DrawingPoint>[];

  DrawingPoint? currentDrawingPoint;

  @override
  void initState() {
    selectedColor = availableColors.elementAt(0);
    selectedWidth = 2.0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: (details) {
              setState(() {
                currentDrawingPoint = DrawingPoint(
                    color: selectedColor,
                    width: selectedWidth,
                    id: DateTime.now().microsecondsSinceEpoch,
                    offset: [details.localPosition]);

                if (currentDrawingPoint == null) return;
                drawingPoint.add(currentDrawingPoint!);
                historyDrawingPoint = List.of(drawingPoint);
              });
            },
            onPanUpdate: (details) {
              setState(() {
                if (currentDrawingPoint == null) return;
                currentDrawingPoint = currentDrawingPoint?.copyWith(
                  offset: currentDrawingPoint!.offset
                    ..add(details.localPosition),
                );
                drawingPoint.last = currentDrawingPoint!;
                historyDrawingPoint = List.of(drawingPoint);
              });
            },
            onPanEnd: (details) {
              setState(() {
                currentDrawingPoint = null;
              });
            },
            child: CustomPaint(
              painter: DrawingPainter(drawingPoints: drawingPoint),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 18,
            right: 16,
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedColor = availableColors.elementAt(index);
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border:
                            selectedColor == availableColors.elementAt(index)
                                ? Border.all(color: Colors.blueGrey, width: 2)
                                : null,
                        shape: BoxShape.circle,
                        color: availableColors.elementAt(index),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(
                  width: 8,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            bottom: 150,
            right: 0,
            child: RotatedBox(
              quarterTurns: 3,
              child: Slider(
                value: selectedWidth / 10,
                onChanged: (value) {
                  setState(() {
                    final newVal = value * 10;

                    selectedWidth = newVal;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            shape: const CircleBorder(),
            heroTag: "Undo",
            child: Icon(Icons.undo),
            onPressed: () {
              if (drawingPoint.isNotEmpty && historyDrawingPoint.isNotEmpty) {
                setState(() {
                  drawingPoint.removeLast();
                });
              }
            },
          ),
          const SizedBox(
            width: 20,
          ),
          FloatingActionButton(
            shape: const CircleBorder(),
            heroTag: "Redo",
            child: const Icon(
              Icons.redo,
            ),
            onPressed: () {
              if (drawingPoint.length < historyDrawingPoint.length) {
                final index = drawingPoint.length;
                setState(() {
                  drawingPoint.add(historyDrawingPoint[index]);
                });
              }
            },
          )
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});
  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < drawingPoint.offset.length; i++) {
        var notLatOffset = i != drawingPoint.offset.length - 1;
        if (notLatOffset) {
          final current = drawingPoint.offset[i];
          final next = drawingPoint.offset[i + 1];
          canvas.drawLine(current, next, paint);
        } else {}
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
