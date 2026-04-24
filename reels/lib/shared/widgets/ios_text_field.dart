import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:reels/core/theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════════
//  iOS TEXT FIELD — URL Paste Input
//
//  iOS search-bar style with:
//   • Deep frosted glass background
//   • Smart suffix: Paste button when empty → Clear button when has text
//   • Leading link icon
//   • Haptic feedback on paste action
// ════════════════════════════════════════════════════════════════════════════════

class IosTextField extends StatefulWidget {
  const IosTextField({
    super.key,
    this.controller,
    this.placeholder = 'Paste video URL…',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  @override
  State<IosTextField> createState() => _IosTextFieldState();
}

class _IosTextFieldState extends State<IosTextField> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChange);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  Future<void> _pasteFromClipboard() async {
    HapticFeedback.mediumImpact();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      _controller.selection =
          TextSelection.collapsed(offset: data.text!.length);
      widget.onChanged?.call(data.text!);
    }
  }

  void _clearText() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.mdAll,
        boxShadow: AppShadows.subtle, // Add subtle drop shadow
      ),
      child: ClipRRect(
        borderRadius: AppRadius.mdAll,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32), // Aggressive blur
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF), // Deep glass
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
            child: CupertinoTextField(
              controller: _controller,
              placeholder: widget.placeholder,
              placeholderStyle: AppTypography.body.copyWith(
                color: AppColors.textTertiary,
              ),
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
              autofocus: widget.autofocus,
              autocorrect: false,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: 18, // Taller padding for premium feel
              ),
              decoration: null, // Remove default decoration
              prefix: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.base), // Match padding
                child: Icon(
                  CupertinoIcons.link,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
              suffix: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: AnimatedSwitcher(
                  duration: AppDurations.fast,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: AppCurves.spring,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: _hasText
                      ? _SuffixButton(
                          key: const ValueKey('clear'),
                          icon: CupertinoIcons.clear_thick_circled, // Bolder icon
                          color: AppColors.textTertiary,
                          onTap: _clearText,
                        )
                      : _SuffixButton(
                          key: const ValueKey('paste'),
                          icon: CupertinoIcons.doc_on_clipboard,
                          color: AppColors.primary,
                          onTap: _pasteFromClipboard,
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── SUFFIX BUTTON ───────────────────────────────────────────────────────────

class _SuffixButton extends StatelessWidget {
  const _SuffixButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm), // Larger tap target
        child: Icon(icon, color: color, size: 22), // Slightly larger icon
      ),
    );
  }
}
