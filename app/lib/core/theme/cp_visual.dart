import 'package:flutter/material.dart';
import 'app_colors.dart';

/// CP Colonel visual language.
///
/// This layer is intentionally separate from ThemeData:
/// ThemeData controls semantic Material behavior, while these tokens
/// control the branded CP Colonel visual identity.
abstract final class CpVisual {
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 30;

  static const double borderWidth = 1.15;
  static const double glowBorderWidth = 1.4;

  static const Color darkCanvas = Color(0xFF05080D);
  static const Color darkSurface = Color(0xFF0B111A);
  static const Color darkSurface2 = Color(0xFF111A26);
  static const Color darkSurface3 = Color(0xFF162131);

  static const Color lightCanvas = Color(0xFFF4F5F7);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF8F9FB);

  static const Color blue = Color(0xFF2196F3);
  static const Color green = Color(0xFF16B978);
  static const Color gold = Color(0xFFE3A629);
  static const Color purple = Color(0xFF9B4DFF);
  static const Color cyan = Color(0xFF18C7D9);

  static Color canvas(Brightness brightness) =>
      brightness == Brightness.dark ? darkCanvas : lightCanvas;

  static Color surface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color surface2(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface2 : lightSurface2;

  static Color surface3(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface3 : const Color(0xFFFFFFFF);

  static Color outline(Brightness brightness) =>
      brightness == Brightness.dark
          ? const Color(0xFF28394A)
          : const Color(0xFFD5D9E0);

  static Color strongOutline(Brightness brightness) =>
      brightness == Brightness.dark
          ? AppColors.red.withValues(alpha: .72)
          : AppColors.red.withValues(alpha: .36);

  static Color glow(Brightness brightness) =>
      brightness == Brightness.dark
          ? AppColors.red.withValues(alpha: .30)
          : AppColors.red.withValues(alpha: .14);

  static BoxDecoration panel(
    Brightness brightness, {
    Color? color,
    bool redAccent = false,
    double radius = radiusLg,
  }) {
    final dark = brightness == Brightness.dark;

    return BoxDecoration(
      color: color ?? surface(brightness),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: redAccent ? strongOutline(brightness) : outline(brightness),
        width: redAccent ? glowBorderWidth : borderWidth,
      ),
      boxShadow: dark && redAccent
          ? [
              BoxShadow(
                color: glow(brightness),
                blurRadius: 18,
                spreadRadius: -4,
              ),
            ]
          : const [],
    );
  }

  static BoxDecoration glass(
    Brightness brightness, {
    bool redAccent = false,
    double radius = radiusLg,
  }) {
    final dark = brightness == Brightness.dark;

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: dark
            ? [
                darkSurface3.withValues(alpha: .96),
                darkSurface.withValues(alpha: .98),
              ]
            : [
                lightSurface.withValues(alpha: .98),
                lightSurface2.withValues(alpha: .98),
              ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: redAccent ? strongOutline(brightness) : outline(brightness),
        width: redAccent ? glowBorderWidth : borderWidth,
      ),
      boxShadow: dark && redAccent
          ? [
              BoxShadow(
                color: glow(brightness),
                blurRadius: 22,
                spreadRadius: -5,
              ),
            ]
          : const [],
    );
  }

  static BoxDecoration iconTile(
    Color accent, {
    bool dark = true,
    double radius = radiusMd,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accent.withValues(alpha: dark ? .30 : .14),
          accent.withValues(alpha: dark ? .08 : .05),
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: accent.withValues(alpha: dark ? .72 : .34),
        width: 1.15,
      ),
      boxShadow: dark
          ? [
              BoxShadow(
                color: accent.withValues(alpha: .16),
                blurRadius: 14,
                spreadRadius: -4,
              ),
            ]
          : const [],
    );
  }

  static LinearGradient redGradient({bool dark = true}) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: dark
          ? const [
              Color(0xFFFF2632),
              Color(0xFFD71920),
              Color(0xFF76070D),
            ]
          : const [
              Color(0xFFFF3B43),
              Color(0xFFD71920),
              Color(0xFFB20E16),
            ],
    );
  }
}


class CpMasterHeaderBackground extends StatelessWidget {
  const CpMasterHeaderBackground({super.key});
  @override
  Widget build(BuildContext context) => const RepaintBoundary(
    child: CustomPaint(painter: _CpMasterHeaderPainter(), child: SizedBox.expand()),
  );
}

class _CpMasterHeaderPainter extends CustomPainter {
  const _CpMasterHeaderPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()..shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF040609), Color(0xFF19070B), Color(0xFF080B10)],
    ).createShader(rect);
    canvas.drawRect(rect, base);
    void streak(double x,double y,double dx,double dy,double width,double alpha) {
      final p = Paint()
        ..color = const Color(0xFFD71920).withValues(alpha: alpha)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawLine(Offset(x,y), Offset(x+dx,y+dy), p);
    }
    streak(size.width*.02,size.height*.88,size.width*.48,-size.height*.48,3.4,.34);
    streak(size.width*.28,size.height*.70,size.width*.42,-size.height*.40,2.2,.22);
    streak(size.width*.56,size.height*.92,size.width*.38,-size.height*.55,2.8,.30);
    streak(size.width*.72,size.height*.36,size.width*.32,-size.height*.28,2.8,.20);
    final neon = Paint()
      ..color = const Color(0xFFFF2630).withValues(alpha:.88)
      ..strokeWidth = 1.15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal,1.6);
    canvas.drawLine(Offset(size.width*.35,size.height),Offset(size.width*.73,0),neon);
    neon.color = const Color(0xFFD71920).withValues(alpha:.58);
    canvas.drawLine(Offset(size.width*.60,size.height),Offset(size.width,size.height*.20),neon);
    final edge = Paint()..color=const Color(0xFFFF3038).withValues(alpha:.90)..strokeWidth=1;
    canvas.drawLine(Offset(0,size.height-1),Offset(size.width,size.height-1),edge);
  }
  @override
  bool shouldRepaint(covariant _CpMasterHeaderPainter oldDelegate)=>false;
}
