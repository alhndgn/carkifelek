import 'package:flutter/material.dart';

import '../theme/palette.dart';

/// Tüm ekranların altında duran koyu gradyan zemin + parıltı blobları.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: kBackgroundGradient,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -120,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[Color(0x338B5CF6), Color(0x008B5CF6)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -110,
            child: IgnorePointer(
              child: Container(
                width: 280,
                height: 280,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[Color(0x223E9BEF), Color(0x003E9BEF)],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: -60,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: <Color>[Color(0x1A8B5CF6), Color(0x008B5CF6)],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
