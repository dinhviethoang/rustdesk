import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hbb/common.dart';

/// Cyber tech HUD frame with 4 cyan corner brackets and panel background.
class CyberFrame extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color borderColor;
  final Color cornerColor;
  final double cornerLength;
  final double cornerThickness;

  const CyberFrame({
    super.key,
    this.child,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFF070D14),
    this.borderColor = const Color(0xFF12303A),
    this.cornerColor = const Color(0xFF00E5FF),
    this.cornerLength = 12.0,
    this.cornerThickness = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CyberFramePainter(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        cornerColor: cornerColor,
        cornerLength: cornerLength,
        cornerThickness: cornerThickness,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        child: child,
      ),
    );
  }
}

class _CyberFramePainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final Color cornerColor;
  final double cornerLength;
  final double cornerThickness;

  _CyberFramePainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.cornerColor,
    required this.cornerLength,
    required this.cornerThickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, bgPaint);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, borderPaint);

    final cornerPaint = Paint()
      ..color = cornerColor
      ..strokeWidth = cornerThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    final cl = math.min(cornerLength, math.min(w / 2, h / 2));

    // Top-left corner
    final pathTL = Path()
      ..moveTo(0, cl)
      ..lineTo(0, 0)
      ..lineTo(cl, 0);
    canvas.drawPath(pathTL, cornerPaint);

    // Top-right corner
    final pathTR = Path()
      ..moveTo(w - cl, 0)
      ..lineTo(w, 0)
      ..lineTo(w, cl);
    canvas.drawPath(pathTR, cornerPaint);

    // Bottom-left corner
    final pathBL = Path()
      ..moveTo(0, h - cl)
      ..lineTo(0, h)
      ..lineTo(cl, h);
    canvas.drawPath(pathBL, cornerPaint);

    // Bottom-right corner
    final pathBR = Path()
      ..moveTo(w - cl, h)
      ..lineTo(w, h)
      ..lineTo(w, h - cl);
    canvas.drawPath(pathBR, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberFramePainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.cornerColor != cornerColor ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.cornerThickness != cornerThickness;
  }
}

/// Cyber tech 24px grid background.
class CyberGridBackground extends StatelessWidget {
  final Widget? child;
  final double gridSize;
  final Color backgroundColor;
  final Color gridColor;

  const CyberGridBackground({
    super.key,
    this.child,
    this.gridSize = 24.0,
    this.backgroundColor = const Color(0xFF04070B),
    this.gridColor = const Color(0x1F00E5FF), // rgba(0,229,255,.12)
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CyberGridPainter(
        gridSize: gridSize,
        backgroundColor: backgroundColor,
        gridColor: gridColor,
      ),
      child: child,
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double gridSize;
  final Color backgroundColor;
  final Color gridColor;

  _CyberGridPainter({
    required this.gridSize,
    required this.backgroundColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    final linePaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.gridColor != gridColor;
  }
}

/// Cyber tech animated radar with degree ticks, dashed counter-rotating circle,
/// 2 inner rings, crosshair, rotating sweep gradient, and 2 blinking green blips.
class CyberRadar extends StatefulWidget {
  final double size;

  const CyberRadar({
    super.key,
    this.size = 160.0,
  });

  @override
  State<CyberRadar> createState() => _CyberRadarState();
}

class _CyberRadarState extends State<CyberRadar>
    with TickerProviderStateMixin {
  late final AnimationController _sweepController;
  late final AnimationController _dashController;
  late final AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _dashController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _dashController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _sweepController,
          _dashController,
          _blinkController,
        ]),
        builder: (context, _) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _CyberRadarPainter(
              sweepAngle: _sweepController.value * 2 * math.pi,
              dashAngle: -_dashController.value * 2 * math.pi,
              blinkValue: _blinkController.value,
            ),
          );
        },
      ),
    );
  }
}

class _CyberRadarPainter extends CustomPainter {
  final double sweepAngle;
  final double dashAngle;
  final double blinkValue;

  _CyberRadarPainter({
    required this.sweepAngle,
    required this.dashAngle,
    required this.blinkValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width / 2;

    // 1. Degree ticks around border (every 10 deg = 36 ticks)
    final tickPaint = Paint()
      ..color = const Color(0x8C00E5FF) // c2
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 36; i++) {
      final angle = i * (2 * math.pi / 36);
      final rOut = R - 1.0;
      final rIn = R - 6.0;
      final p1 = center + Offset(math.cos(angle) * rIn, math.sin(angle) * rIn);
      final p2 = center + Offset(math.cos(angle) * rOut, math.sin(angle) * rOut);
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 2. Dashed circle rotating slowly 30s counter-clockwise
    final dashRadius = R - 4.0;
    final dashPaint = Paint()
      ..color = const Color(0x8C00E5FF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const dashCount = 24;
    for (int d = 0; d < dashCount; d++) {
      final startA = dashAngle + d * (2 * math.pi / dashCount);
      const sweepA = (2 * math.pi / dashCount) * 0.55;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: dashRadius),
        startA,
        sweepA,
        false,
        dashPaint,
      );
    }

    // 3. Two inner rings
    final ringPaint = Paint()
      ..color = const Color(0xFF12303A)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 0.78 * R, ringPaint);
    canvas.drawCircle(center, 0.62 * R, ringPaint);

    // 4. Crosshair
    final crossPaint = Paint()
      ..color = const Color(0xFF12303A)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final crossR = 0.84 * R;
    canvas.drawLine(
      Offset(center.dx - crossR, center.dy),
      Offset(center.dx + crossR, center.dy),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - crossR),
      Offset(center.dx, center.dy + crossR),
      crossPaint,
    );

    // 5. Sweep gradient rotating 3s/rev
    final sweepRadius = 0.84 * R;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweepAngle);

    final sweepGradient = SweepGradient(
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: const [
        Color(0x8000E5FF), // rgba(0,229,255,.5)
        Color(0x0000E5FF), // transparent
        Color(0x0000E5FF),
      ],
      stops: const [0.0, 60.0 / 360.0, 1.0],
    );

    final sweepPaint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: sweepRadius),
      )
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, sweepRadius, sweepPaint);
    canvas.restore();

    // 6. Two glowing green blinking blips
    final blip1 = Offset(
      center.dx - 0.46 * R,
      center.dy - 0.38 * R,
    );
    final blip2 = Offset(
      center.dx + 0.32 * R,
      center.dy + 0.22 * R,
    );

    final opacity1 = (0.2 + 0.8 * blinkValue).clamp(0.0, 1.0);
    final opacity2 = (0.2 + 0.8 * (1.0 - blinkValue)).clamp(0.0, 1.0);

    _drawBlip(canvas, blip1, opacity1);
    _drawBlip(canvas, blip2, opacity2);
  }

  void _drawBlip(Canvas canvas, Offset pos, double opacity) {
    final glowPaint = Paint()
      ..color = const Color(0xFF00FF9F).withOpacity(opacity * 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 6.0, glowPaint);

    final dotPaint = Paint()
      ..color = const Color(0xFF00FF9F).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _CyberRadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.dashAngle != dashAngle ||
        oldDelegate.blinkValue != blinkValue;
  }
}

/// 5 ascending signal bars (4-5 cyan, 3 yellow, 1-2 red, off #12303A).
class CyberSignalBars extends StatelessWidget {
  final int level;

  const CyberSignalBars({
    super.key,
    required this.level,
  });

  static Color levelColor(int lv) {
    if (lv >= 4) return const Color(0xFF00E5FF);
    if (lv == 3) return const Color(0xFFFFB020);
    return const Color(0xFFFF3B5C);
  }

  @override
  Widget build(BuildContext context) {
    final clampedLevel = level.clamp(0, 5);
    final activeColor = levelColor(clampedLevel);

    return SizedBox(
      height: 16.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (index) {
          final isActive = index < clampedLevel;
          final color = isActive ? activeColor : const Color(0xFF12303A);
          final barHeight = 4.0 + index * 3.0;

          return Padding(
            padding: EdgeInsets.only(right: index < 4 ? 3.0 : 0.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 4.0,
              height: barHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Latency level mapper: <40->5, <80->4, <150->3, <250->2, else 1.
int levelFromPing(int? ms) {
  if (ms == null) return 0;
  if (ms < 40) return 5;
  if (ms < 80) return 4;
  if (ms < 150) return 3;
  if (ms < 250) return 2;
  return 1;
}

Color colorFromPing(int? ms) {
  final lv = levelFromPing(ms);
  if (lv >= 4) return const Color(0xFF00E5FF);
  if (lv == 3) return const Color(0xFFFFB020);
  if (lv >= 1) return const Color(0xFFFF3B5C);
  return const Color(0xFF5C7A86);
}

int? parseDelay(String? delayStr) {
  if (delayStr == null || delayStr.isEmpty) return null;
  final match = RegExp(r'\d+').firstMatch(delayStr);
  if (match != null) {
    return int.tryParse(match.group(0)!);
  }
  return null;
}

/// CyberPing displays latency "PING 023ms" or "PING ---".
class CyberPing extends StatelessWidget {
  final int? ms;
  final double fontSize;

  const CyberPing({
    super.key,
    this.ms,
    this.fontSize = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final text = ms == null
        ? 'PING ---'
        : 'PING ${ms.toString().padLeft(3, '0')}ms';
    final color = colorFromPing(ms);

    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        letterSpacing: 1.0,
        fontWeight: FontWeight.w600,
        fontFamily: MyTheme.monoFontFamily,
        fontFamilyFallback: MyTheme.monoFontFamilyFallback,
      ),
    );
  }
}

/// Cyan scan line moving vertically from top to bottom (5s per loop).
class CyberScanLine extends StatefulWidget {
  const CyberScanLine({super.key});

  @override
  State<CyberScanLine> createState() => _CyberScanLineState();
}

class _CyberScanLineState extends State<CyberScanLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.6,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final top = _controller.value * constraints.maxHeight;
                return Stack(
                  children: [
                    Positioned(
                      top: top,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1.0,
                        decoration: const BoxDecoration(
                          color: Color(0x8C00E5FF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00E5FF),
                              blurRadius: 10.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// UPPERCASE tracked label (size 10, letterSpacing 2.5, #5C7A86).
class CyberLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final double? letterSpacing;
  final TextAlign? textAlign;

  const CyberLabel(
    this.text, {
    super.key,
    this.color,
    this.fontSize,
    this.letterSpacing,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize ?? 10.0,
        letterSpacing: letterSpacing ?? 2.5,
        color: color ?? const Color(0xFF5C7A86),
        fontFamily: MyTheme.monoFontFamily,
        fontFamilyFallback: MyTheme.monoFontFamilyFallback,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Square 30x30 icon box with #12303A border, 15px cyan icon (red when danger).
class CyberIcon extends StatelessWidget {
  final Widget? child;
  final IconData? icon;
  final Color? color;
  final bool danger;
  final VoidCallback? onTap;
  final String? tooltip;

  const CyberIcon({
    super.key,
    this.child,
    this.icon,
    this.color,
    this.danger = false,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (danger ? const Color(0xFFFF3B5C) : const Color(0xFF00E5FF));
    final borderColor = danger
        ? const Color(0x66FF3B5C)
        : const Color(0xFF12303A);

    Widget content = Container(
      width: 30.0,
      height: 30.0,
      decoration: BoxDecoration(
        color: const Color(0xFF070D14),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      alignment: Alignment.center,
      child: child ??
          (icon != null
              ? Icon(
                  icon,
                  size: 15.0,
                  color: effectiveColor,
                )
              : null),
    );

    if (onTap != null) {
      content = Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      );
    }
    if (tooltip != null && tooltip!.isNotEmpty) {
      content = Tooltip(
        message: tooltip!,
        child: content,
      );
    }
    return content;
  }
}

/// A container or button with chamfered (beveled) corners.
class CyberCutBox extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double cut;
  final bool twoCorners; // true: cuts top-left & bottom-right (HUD style)
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final String? tooltip;
  final bool glow;

  const CyberCutBox({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.backgroundColor = const Color(0xFF070D14),
    this.borderColor = const Color(0xFF12303A),
    this.borderWidth = 1.0,
    this.cut = 6.0,
    this.twoCorners = true,
    this.onTap,
    this.onTapDown,
    this.tooltip,
    this.glow = false,
  });

  ShapeBorder _buildShape() {
    final radius = Radius.circular(cut);
    final borderRadius = twoCorners
        ? BorderRadius.only(topLeft: radius, bottomRight: radius)
        : BorderRadius.all(radius);
    return BeveledRectangleBorder(
      borderRadius: borderRadius,
      side: BorderSide(color: borderColor, width: borderWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = _buildShape();

    Widget content = Material(
      color: backgroundColor,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: shape,
        onTap: onTap,
        onTapDown: onTapDown,
        splashColor: borderColor.withOpacity(0.2),
        highlightColor: borderColor.withOpacity(0.1),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    if (glow) {
      content = DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
          shadows: [
            BoxShadow(
              color: borderColor.withOpacity(0.25),
              blurRadius: 8.0,
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: content,
      );
    }

    if (tooltip != null && tooltip!.isNotEmpty) {
      content = Tooltip(
        message: tooltip!,
        waitDuration: Duration.zero,
        child: content,
      );
    }

    return content;
  }
}

/// Chamfered HUD button with cyan or red accent.
class CyberCutButton extends StatelessWidget {
  final Widget? icon;
  final String text;
  final VoidCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double height;
  final double letterSpacing;
  final double fontSize;
  final String? tooltip;
  final bool danger;

  const CyberCutButton({
    super.key,
    this.icon,
    required this.text,
    this.onTap,
    this.onTapDown,
    this.color,
    this.textColor,
    this.borderColor,
    this.width,
    this.height = 36.0,
    this.letterSpacing = 2.0,
    this.fontSize = 11.0,
    this.tooltip,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ??
        (danger ? const Color(0xFFFF3B5C) : const Color(0xFF00E5FF));
    final effectiveBgColor = color ??
        (danger ? const Color(0x14FF3B5C) : const Color(0x1F00E5FF));
    final effectiveTextColor = textColor ??
        (danger ? const Color(0xFFFF3B5C) : const Color(0xFF00E5FF));

    return CyberCutBox(
      width: width,
      height: height,
      backgroundColor: effectiveBgColor,
      borderColor: effectiveBorderColor,
      cut: 7.0,
      twoCorners: true,
      onTap: onTap,
      onTapDown: onTapDown,
      tooltip: tooltip,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                color: effectiveTextColor,
                fontSize: fontSize,
                letterSpacing: letterSpacing,
                fontWeight: FontWeight.w600,
                fontFamily: MyTheme.monoFontFamily,
                fontFamilyFallback: MyTheme.monoFontFamilyFallback,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blinking/pulsing status dot with aura (green #00FF9F default).
class CyberPulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const CyberPulsingDot({
    super.key,
    this.color = const Color(0xFF00FF9F),
    this.size = 7.0,
  });

  @override
  State<CyberPulsingDot> createState() => _CyberPulsingDotState();
}

class _CyberPulsingDotState extends State<CyberPulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.3 + 0.7 * _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(opacity),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.6 * _controller.value),
                blurRadius: 6.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
        );
      },
    );
  }
}

