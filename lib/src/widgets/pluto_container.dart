import 'package:flutter/material.dart';

class PlutoContainer extends StatelessWidget {
  final double height;
  final Color? color;

  const PlutoContainer({
    required this.height,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: height,
          color: color,
        ),
      ],
    );
  }
}
