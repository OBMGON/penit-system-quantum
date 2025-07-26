import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ModernListItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData? leadingIcon;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<Widget>? actions;
  final bool isSelected;
  final bool showDivider;

  const ModernListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leadingIcon,
    this.color,
    this.onTap,
    this.onLongPress,
    this.actions,
    this.isSelected = false,
    this.showDivider = true,
  });

  @override
  State<ModernListItem> createState() => _ModernListItemState();
}

class _ModernListItemState extends State<ModernListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? const Color(0xFF17643A);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? color.withOpacity(0.1)
                    : Colors.white
                        .withOpacity(0.9 + _glowAnimation.value * 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected
                      ? color
                      : color.withOpacity(0.1 + _glowAnimation.value * 0.2),
                  width: widget.isSelected ? 2 : 1 + _glowAnimation.value * 0.5,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onLongPress: widget.onLongPress,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (widget.leadingIcon != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              widget.leadingIcon,
                              color: color,
                              size: 20 + _glowAnimation.value * 2,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 16 + _glowAnimation.value,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isSelected
                                      ? color
                                      : Colors.black87,
                                ),
                              ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 16),
                          Text(
                            widget.trailing!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                        if (widget.actions != null) ...[
                          const SizedBox(width: 16),
                          ...widget.actions!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ModernInmateListItem extends StatelessWidget {
  final String name;
  final String? alias;
  final String? dip;
  final String? prison;
  final String? status;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ModernInmateListItem({
    super.key,
    required this.name,
    this.alias,
    this.dip,
    this.prison,
    this.status,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ModernListItem(
      title: name,
      subtitle: alias != null ? 'Alias: $alias' : null,
      trailing: status,
      leadingIcon: Icons.person,
      onTap: onTap,
      actions: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Editar',
          ),
        if (onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
            tooltip: 'Eliminar',
          ),
      ],
    );
  }
}

class ModernAlertListItem extends StatelessWidget {
  final String title;
  final String description;
  final String priority;
  final DateTime date;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;

  const ModernAlertListItem({
    super.key,
    required this.title,
    required this.description,
    required this.priority,
    required this.date,
    this.onTap,
    this.onResolve,
  });

  Color _getPriorityColor() {
    switch (priority.toLowerCase()) {
      case 'crítica':
        return AppTheme.primaryColor;
      case 'alta':
        return Colors.orange;
      case 'media':
        return Colors.yellow.shade700;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor();

    return ModernListItem(
      title: title,
      subtitle: description.length > 60
          ? '${description.substring(0, 60)}...'
          : description,
      trailing: '${date.day}/${date.month}',
      leadingIcon: Icons.warning,
      color: priorityColor,
      onTap: onTap,
      actions: [
        if (onResolve != null)
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: onResolve,
            tooltip: 'Resolver',
          ),
      ],
    );
  }
}

class ModernHospitalizationListItem extends StatelessWidget {
  final String inmateName;
  final String reason;
  final DateTime admissionDate;
  final String? hospital;
  final String status;
  final VoidCallback? onTap;
  final VoidCallback? onDischarge;

  const ModernHospitalizationListItem({
    super.key,
    required this.inmateName,
    required this.reason,
    required this.admissionDate,
    this.hospital,
    required this.status,
    this.onTap,
    this.onDischarge,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'activa':
        return AppTheme.primaryColor;
      case 'alta':
        return Colors.green;
      case 'en tratamiento':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return ModernListItem(
      title: inmateName,
      subtitle: reason,
      trailing: status,
      leadingIcon: Icons.local_hospital,
      color: statusColor,
      onTap: onTap,
      actions: [
        if (onDischarge != null && status.toLowerCase() == 'activa')
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.green),
            onPressed: onDischarge,
            tooltip: 'Dar alta',
          ),
      ],
    );
  }
}
