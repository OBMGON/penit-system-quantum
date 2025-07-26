import 'package:flutter/material.dart';

enum ModernLoaderType {
  circular,
  linear,
  dots,
  pulse,
  shimmer,
  skeleton,
}

class ModernLoader extends StatefulWidget {
  final ModernLoaderType type;
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;
  final Duration duration;
  final bool enableAnimation;

  const ModernLoader({
    super.key,
    this.type = ModernLoaderType.circular,
    this.message,
    this.color,
    this.size = 40,
    this.strokeWidth = 3,
    this.duration = const Duration(milliseconds: 1500),
    this.enableAnimation = true,
  });

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableAnimation) {
      _animationController.repeat();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildLoader(color),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildLoader(Color color) {
    switch (widget.type) {
      case ModernLoaderType.circular:
        return _buildCircularLoader(color);
      case ModernLoaderType.linear:
        return _buildLinearLoader(color);
      case ModernLoaderType.dots:
        return _buildDotsLoader(color);
      case ModernLoaderType.pulse:
        return _buildPulseLoader(color);
      case ModernLoaderType.shimmer:
        return _buildShimmerLoader(color);
      case ModernLoaderType.skeleton:
        return _buildSkeletonLoader(color);
    }
  }

  Widget _buildCircularLoader(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: CircularProgressIndicator(
              strokeWidth: widget.strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinearLoader(Color color) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.strokeWidth,
      child: LinearProgressIndicator(
        backgroundColor: color.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildDotsLoader(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delay = index * 0.2;
            final animationValue = (_animationController.value + delay) % 1.0;
            final scale = 0.5 + (animationValue * 0.5);
            final opacity = 0.3 + (animationValue * 0.7);

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPulseLoader(Color color) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color.withOpacity(1 - _animationController.value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoader(Color color) {
    return Container(
      width: widget.size * 2,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(widget.size / 2),
      ),
    );
  }

  Widget _buildSkeletonLoader(Color color) {
    return Container(
      width: widget.size * 2,
      height: widget.size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Loader de pantalla completa
class ModernFullScreenLoader extends StatelessWidget {
  final String? message;
  final ModernLoaderType type;
  final Color? backgroundColor;
  final Color? loaderColor;

  const ModernFullScreenLoader({
    super.key,
    this.message,
    this.type = ModernLoaderType.circular,
    this.backgroundColor,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      child: Center(
        child: ModernLoader(
          type: type,
          message: message,
          color: loaderColor,
          size: 48,
        ),
      ),
    );
  }
}

// Loader de botón
class ModernButtonLoader extends StatelessWidget {
  final Color? color;
  final double size;

  const ModernButtonLoader({
    super.key,
    this.color,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}

// Skeleton loader para contenido
class ModernSkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const ModernSkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius,
    this.color,
  });

  @override
  State<ModernSkeletonLoader> createState() => _ModernSkeletonLoaderState();
}

class _ModernSkeletonLoaderState extends State<ModernSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.color ?? theme.colorScheme.onSurfaceVariant;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
              stops: [
                _animation.value - 0.5,
                _animation.value,
                _animation.value + 0.5,
              ].map((value) => value.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

// Lista de skeleton loaders
class ModernSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const ModernSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 60,
    this.padding,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        return ModernSkeletonLoader(
          height: itemHeight,
          borderRadius: BorderRadius.circular(12),
        );
      },
    );
  }
}
