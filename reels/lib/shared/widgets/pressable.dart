import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:reels/core/theme/app_theme.dart';

/// A reusable wrapper that adds iOS-native press feedback to any child:
///   • Scale-down to [scaleFactor] on press (default 0.97)
///   • Optional haptic feedback (medium impact)
///   • 150 ms ease-in-out animation (fast & responsive, matching iOS feel)
///
/// Usage:
/// ```dart
/// Pressable(
///   onTap: () => doSomething(),
///   child: MyCard(),
/// )
/// ```
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = AppPressScale.factor,
    this.haptic = true,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final bool haptic;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  void _onTap() {
    if (!widget.enabled) return;
    if (widget.haptic) HapticFeedback.mediumImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap != null ? _onTap : null,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.scaleFactor : 1.0,
        duration: AppDurations.fast,
        curve: AppCurves.standard,
        child: widget.child,
      ),
    );
  }
}
