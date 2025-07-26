import 'package:flutter/material.dart';

enum ModernCardType {
  default_,
  elevated,
  outlined,
  filled,
  interactive,
}

class ModernCard extends StatefulWidget {
  final Widget child;
  final ModernCardType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? loadingWidget;
  final bool enableHoverEffect;
  final bool enableRippleEffect;

  const ModernCard({
    super.key,
    required this.child,
    this.type = ModernCardType.default_,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.onTap,
    this.isLoading = false,
    this.loadingWidget,
    this.enableHoverEffect = true,
    this.enableRippleEffect = true,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  final bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
    if (widget.onTap != null && widget.enableRippleEffect) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null && widget.enableRippleEffect) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null && widget.enableRippleEffect) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInteractive = widget.onTap != null;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getBackgroundColor(theme),
              borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
              border: _getBorder(theme),
              boxShadow: _getBoxShadow(theme),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isLoading ? null : widget.onTap,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.all(16),
                  child: widget.isLoading
                      ? widget.loadingWidget ?? _buildLoadingWidget(theme)
                      : widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (widget.backgroundColor != null) {
      return widget.backgroundColor!;
    }

    switch (widget.type) {
      case ModernCardType.default_:
        return theme.cardColor;
      case ModernCardType.elevated:
        return theme.cardColor;
      case ModernCardType.outlined:
        return Colors.transparent;
      case ModernCardType.filled:
        return theme.colorScheme.surfaceContainerHighest;
      case ModernCardType.interactive:
        return theme.cardColor;
    }
  }

  Border? _getBorder(ThemeData theme) {
    if (widget.borderColor != null) {
      return Border.all(color: widget.borderColor!);
    }

    switch (widget.type) {
      case ModernCardType.default_:
      case ModernCardType.elevated:
      case ModernCardType.filled:
      case ModernCardType.interactive:
        return null;
      case ModernCardType.outlined:
        return Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        );
    }
  }

  List<BoxShadow>? _getBoxShadow(ThemeData theme) {
    if (widget.elevation != null) {
      return [
        BoxShadow(
          color: theme.shadowColor.withOpacity(0.1),
          blurRadius: widget.elevation!,
          offset: Offset(0, widget.elevation! / 2),
        ),
      ];
    }

    switch (widget.type) {
      case ModernCardType.default_:
        return [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case ModernCardType.elevated:
        return [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      case ModernCardType.outlined:
      case ModernCardType.filled:
        return null;
      case ModernCardType.interactive:
        return [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];
    }
  }
}

// Tarjeta de información moderna
class ModernInfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;

  const ModernInfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primaryContainer;

    return ModernCard(
      type: ModernCardType.filled,
      backgroundColor: cardColor,
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 16),
          ] else if (icon != null) ...[
            Icon(
              icon,
              color: theme.colorScheme.onPrimaryContainer,
              size: 24,
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 16),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// Tarjeta de estadísticas moderna
class ModernStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String? change;
  final bool isPositive;
  final IconData? icon;
  final Color? color;

  const ModernStatsCard({
    super.key,
    required this.title,
    required this.value,
    this.change,
    this.isPositive = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.surface;

    return ModernCard(
      type: ModernCardType.elevated,
      backgroundColor: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (change != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  change!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
