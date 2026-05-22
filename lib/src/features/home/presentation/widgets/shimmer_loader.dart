import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  final Widget child;
  final Duration period;

  const ShimmerLoader({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 1200),
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)..repeat();
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
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final width = bounds.width;
            final dx = width * 2 * _controller.value - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE6E8EE),
                Color(0xFFF6F7FA),
                Color(0xFFE6E8EE),
              ],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlidingGradientTransform(slidePercent: _controller.value, dx: dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  final double dx;

  const _SlidingGradientTransform({required this.slidePercent, required this.dx});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

class ShimmerBookCard extends StatelessWidget {
  const ShimmerBookCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              _ShimmerBox(width: 72, height: 100, radius: 8),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerBox(width: double.infinity, height: 18, radius: 6),
                    SizedBox(height: 10),
                    _ShimmerBox(width: 120, height: 14, radius: 6),
                    SizedBox(height: 18),
                    _ShimmerBox(width: double.infinity, height: 12, radius: 6),
                    SizedBox(height: 8),
                    _ShimmerBox(width: 80, height: 12, radius: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8EE),
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return ShimmerLoader(child: box);
  }
}
