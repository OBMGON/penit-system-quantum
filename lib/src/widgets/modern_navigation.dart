import 'package:flutter/material.dart';

class ModernNavigationBar extends StatefulWidget {
  final int currentIndex;
  final List<ModernNavigationItem> items;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double elevation;
  final bool enableAnimation;

  const ModernNavigationBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.elevation = 8,
    this.enableAnimation = true,
  });

  @override
  State<ModernNavigationBar> createState() => _ModernNavigationBarState();
}

class _ModernNavigationBarState extends State<ModernNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: widget.elevation,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              widget.items.length,
              (index) => _buildNavigationItem(index, theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index, ThemeData theme) {
    final item = widget.items[index];
    final isSelected = index == widget.currentIndex;
    final color = isSelected
        ? (widget.selectedColor ?? theme.colorScheme.primary)
        : (widget.unselectedColor ?? theme.colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTapDown: (_) {
        if (widget.enableAnimation) {
          _animationController.forward();
        }
      },
      onTapUp: (_) {
        if (widget.enableAnimation) {
          _animationController.reverse();
        }
        widget.onTap(index);
      },
      onTapCancel: () {
        if (widget.enableAnimation) {
          _animationController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ModernNavigationItem {
  final IconData icon;
  final String label;
  final String? badge;

  const ModernNavigationItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}

// Navegación lateral moderna
class ModernDrawer extends StatelessWidget {
  final List<ModernDrawerItem> items;
  final Widget? header;
  final Widget? footer;
  final Color? backgroundColor;

  const ModernDrawer({
    super.key,
    required this.items,
    this.header,
    this.footer,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                if (item.isDivider) {
                  return const Divider(height: 1);
                }
                return _buildDrawerItem(context, item, theme);
              },
            ),
          ),
          if (footer != null) footer!,
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, ModernDrawerItem item, ThemeData theme) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.color ?? theme.colorScheme.onSurfaceVariant,
        size: 24,
      ),
      title: Text(
        item.title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: item.color ?? theme.colorScheme.onSurface,
          fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: item.trailing,
      selected: item.isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: item.onTap,
    );
  }
}

class ModernDrawerItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? color;
  final bool isDivider;

  const ModernDrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isSelected = false,
    this.color,
    this.isDivider = false,
  });

  const ModernDrawerItem.divider()
      : icon = Icons.space_bar,
        title = '',
        subtitle = null,
        trailing = null,
        onTap = null,
        isSelected = false,
        color = null,
        isDivider = true;
}

// Header moderno para drawer
class ModernDrawerHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? avatar;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ModernDrawerHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatar,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerColor = backgroundColor ?? theme.colorScheme.primaryContainer;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            if (avatar != null) ...[
              avatar!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
