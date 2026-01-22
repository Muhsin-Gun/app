
import 'package:flutter/material.dart';

class AppAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);

  // Curve constants
  static const Curve defaultCurve = Curves.easeOut;

  /// Slide and Fade transition builder for PageRoutes
  static Widget slideFadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnim = Tween(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: defaultCurve));
    
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: offsetAnim, child: child),
    );
  }

  /// Scale animation for button taps
  static Widget scaleButton(
    double scale,
    Widget child,
  ) {
    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: child,
    );
  }
}

/// Interactive Scale Button for Tap effects
class ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final double scale;

  const ScaleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 120),
    this.scale = 0.96,
  });

  @override
  State<ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<ScaleButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = widget.scale),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

/// Hover Widget for Web Interactions
class HoverWidget extends StatefulWidget {
  final Widget child;
  final double lift;
  final Duration duration;

  const HoverWidget({
    super.key,
    required this.child,
    this.lift = 4.0,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: widget.duration,
        transform: _hovering
            ? Matrix4.translationValues(0, -widget.lift, 0)
            : Matrix4.identity(),
        child: widget.child,
      ),
    );
  }
}

/// Staggered List Entrance Animation
class FadeListItem extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration duration;

  const FadeListItem({
    super.key,
    required this.index,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration.inMilliseconds + index * 50),
      curve: Curves.easeOut,
      builder: (_, double v, __) {
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - v)),
            child: child,
          ),
        );
      },
    );
  }
}
