import 'dart:math' as math;

import 'package:flutter/material.dart';

class KingColors {
  KingColors._();

  static const Color orange = Color(0xFFFF7A1A);
  static const Color amber = Color(0xFFFFB066);
  static const Color ground = Color(0xFF0A0908);
  static const Color panel = Color(0xFF141210);
  static const Color panelHigh = Color(0xFF181512);
  static const Color line = Color(0xFF3A2C20);
  static const Color lineSoft = Color(0xFF2A211A);
  static const Color text = Color(0xFFEDE6DD);
  static const Color muted = Color(0xFFA8998A);
}

const String kKingLogoAsset = 'assets/king_logo.webp';

// Turns the black-ink-on-white logo into orange ink on black.
const ColorFilter kKingLogoFilter = ColorFilter.matrix(<double>[
  -0.299, -0.587, -0.114, 0, 255, //
  -0.143, -0.281, -0.054, 0, 122, //
  -0.030, -0.060, -0.012, 0, 26, //
  0, 0, 0, 1, 0, //
]);

bool _motionDisabled(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;

class _Looping extends StatefulWidget {
  final Duration period;
  final bool reverse;
  final Widget Function(BuildContext, Animation<double>) builder;

  const _Looping({
    required this.period,
    required this.builder,
    this.reverse = false,
  });

  @override
  State<_Looping> createState() => _LoopingState();
}

class _LoopingState extends State<_Looping>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionDisabled(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: widget.reverse);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}

class KingGear extends StatelessWidget {
  final double size;
  final int teeth;
  final Color color;
  final Duration period;
  final bool clockwise;

  const KingGear({
    super.key,
    required this.size,
    this.teeth = 14,
    this.color = KingColors.orange,
    this.period = const Duration(seconds: 14),
    this.clockwise = true,
  });

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: period,
      builder: (context, anim) => AnimatedBuilder(
        animation: anim,
        builder: (context, child) => Transform.rotate(
          angle: (clockwise ? 1 : -1) * anim.value * 2 * math.pi,
          child: child,
        ),
        child: CustomPaint(
          size: Size.square(size),
          painter: _GearPainter(teeth: teeth, color: color),
        ),
      ),
    );
  }
}

class _GearPainter extends CustomPainter {
  final int teeth;
  final Color color;

  _GearPainter({required this.teeth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final outer = size.shortestSide / 2;
    final rim = outer * 0.78;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, outer * 0.07);
    final fill = Paint()..color = color;

    final toothW = 2 * math.pi * rim / teeth * 0.5;
    for (var i = 0; i < teeth; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * 2 * math.pi / teeth);
      canvas.drawRect(
          Rect.fromLTRB(-toothW / 2, -outer, toothW / 2, -rim + 1), fill);
      canvas.restore();
    }
    canvas.drawCircle(c, rim, stroke);
    canvas.drawCircle(c, rim * 0.28, stroke);
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * rim * 0.28,
        c + Offset(math.cos(a), math.sin(a)) * rim,
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_GearPainter old) =>
      old.teeth != teeth || old.color != color;
}

/// Two meshing gears turning in opposite directions.
class KingGearPair extends StatelessWidget {
  final double size;

  const KingGearPair({super.key, this.size = 72});

  @override
  Widget build(BuildContext context) {
    final small = size * 0.66;
    return SizedBox(
      width: size + small * 0.8,
      height: size + small * 0.55,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: KingGear(size: size, teeth: 14),
          ),
          Positioned(
            left: size * 0.82,
            top: size * 0.6,
            child: KingGear(
              size: small,
              teeth: 10,
              color: KingColors.amber,
              period: const Duration(milliseconds: 9800),
              clockwise: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// The logo in a round frame, ringed by a turning gear and a soft pulse.
class KingEmblem extends StatelessWidget {
  final double size;

  const KingEmblem({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.7;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          KingGear(size: size, teeth: 22, period: const Duration(seconds: 18)),
          _Looping(
            period: const Duration(milliseconds: 1300),
            reverse: true,
            builder: (context, anim) => AnimatedBuilder(
              animation: anim,
              builder: (context, child) => Container(
                width: inner,
                height: inner,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  border: Border.all(color: KingColors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: KingColors.orange.withOpacity(0.55 * anim.value),
                      blurRadius: 18 * anim.value,
                    ),
                  ],
                ),
                child: child,
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: kKingLogoFilter,
                  child: Transform.scale(
                    scale: 1.06,
                    child: Image.asset(
                      kKingLogoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated orange/black warning stripes.
class KingHazardStripe extends StatelessWidget {
  final double height;

  const KingHazardStripe({super.key, this.height = 6});

  @override
  Widget build(BuildContext context) {
    return _Looping(
      period: const Duration(milliseconds: 1400),
      builder: (context, anim) => SizedBox(
        width: double.infinity,
        height: height,
        child: AnimatedBuilder(
          animation: anim,
          builder: (context, _) =>
              CustomPaint(painter: _HazardPainter(phase: anim.value)),
        ),
      ),
    );
  }
}

class _HazardPainter extends CustomPainter {
  final double phase;

  _HazardPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    const band = 10.0;
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A1512));
    final paint = Paint()..color = KingColors.orange;
    final shift = phase * band * 2;
    for (var x = -size.height - band * 2 + shift;
        x < size.width + band;
        x += band * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + band, size.height)
        ..lineTo(x + band + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_HazardPainter old) => old.phase != phase;
}

/// Full-window startup screen laid over [child]; fades out on its own or on tap.
class KingSplashOverlay extends StatefulWidget {
  final Widget child;
  final String title;

  const KingSplashOverlay({super.key, required this.child, required this.title});

  @override
  State<KingSplashOverlay> createState() => _KingSplashOverlayState();
}

class _KingSplashOverlayState extends State<KingSplashOverlay> {
  static bool _shownOnce = false;
  static const _hold = Duration(milliseconds: 2400);
  static const _fade = Duration(milliseconds: 500);

  bool _visible = !_shownOnce;
  bool _fading = false;

  @override
  void initState() {
    super.initState();
    if (_visible) {
      _shownOnce = true;
      Future.delayed(_hold, _dismiss);
    }
  }

  void _dismiss() {
    if (!mounted || _fading) return;
    setState(() => _fading = true);
    Future.delayed(_fade, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return widget.child;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _fading,
            child: AnimatedOpacity(
              opacity: _fading ? 0 : 1,
              duration: _fade,
              child: GestureDetector(
                onTap: _dismiss,
                child: _KingSplashBody(title: widget.title, hold: _hold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KingSplashBody extends StatelessWidget {
  final String title;
  final Duration hold;

  const _KingSplashBody({required this.title, required this.hold});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KingColors.ground,
      child: Column(
        children: [
          const KingHazardStripe(height: 8),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const KingEmblem(size: 220),
                    const SizedBox(height: 28),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: KingColors.text,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 320,
                      height: 14,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: KingColors.orange),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.05, end: 1),
                        duration: hold,
                        curve: Curves.easeInOut,
                        builder: (context, v, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: v,
                            child: const KingHazardStripe(height: 8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const KingHazardStripe(height: 8),
        ],
      ),
    );
  }
}
