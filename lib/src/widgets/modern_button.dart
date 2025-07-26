import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ModernButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool enableHapticFeedback;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ModernButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
    this.height = 56,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.backgroundColor,
    this.foregroundColor,
    this.enableHapticFeedback = true,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTap() {
    if (widget.enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isDisabled ? null : _handleTapDown,
            onTapUp: isDisabled ? null : _handleTapUp,
            onTapCancel: isDisabled ? null : _handleTapCancel,
            onTap: isDisabled ? null : _handleTap,
            child: Container(
              width: widget.isFullWidth ? double.infinity : widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: _getBackgroundColor(theme, isDisabled),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                border: _getBorder(theme, isDisabled),
                boxShadow: _getBoxShadow(theme, isDisabled),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  onTap: isDisabled ? null : widget.onPressed,
                  child: Container(
                    padding: widget.padding ??
                        const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.isLoading) ...[
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getForegroundColor(theme, isDisabled),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ] else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: _getForegroundColor(theme, isDisabled),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: widget.textStyle ??
                                theme.textTheme.labelLarge?.copyWith(
                                  color: _getForegroundColor(theme, isDisabled),
                                  fontWeight: FontWeight.w600,
                                ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(ThemeData theme, bool isDisabled) {
    if (isDisabled) {
      return theme.colorScheme.onSurface.withOpacity(0.12);
    }

    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    switch (widget.type) {
      case ModernButtonType.primary:
        return theme.colorScheme.primary;
      case ModernButtonType.secondary:
        return theme.colorScheme.secondary;
      case ModernButtonType.outline:
      case ModernButtonType.text:
        return Colors.transparent;
      case ModernButtonType.danger:
        return theme.colorScheme.error;
      case ModernButtonType.success:
        return theme.colorScheme.secondary;
    }
  }

  Color _getForegroundColor(ThemeData theme, bool isDisabled) {
    if (isDisabled) {
      return theme.colorScheme.onSurface.withOpacity(0.38);
    }

    if (widget.foregroundColor != null) {
      return widget.foregroundColor!;
    }

    switch (widget.type) {
      case ModernButtonType.primary:
      case ModernButtonType.secondary:
      case ModernButtonType.danger:
      case ModernButtonType.success:
        return theme.colorScheme.onPrimary;
      case ModernButtonType.outline:
        return theme.colorScheme.primary;
      case ModernButtonType.text:
        return theme.colorScheme.primary;
    }
  }

  Border? _getBorder(ThemeData theme, bool isDisabled) {
    if (widget.type == ModernButtonType.outline) {
      return Border.all(
        color: isDisabled
            ? theme.colorScheme.onSurface.withOpacity(0.12)
            : theme.colorScheme.primary,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? _getBoxShadow(ThemeData theme, bool isDisabled) {
    if (isDisabled || widget.type == ModernButtonType.text) {
      return null;
    }

    return [
      BoxShadow(
        color: theme.colorScheme.primary.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

// Botón de acción flotante moderno
class ModernFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double size;

  const ModernFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, size: 24),
    );
  }
}
