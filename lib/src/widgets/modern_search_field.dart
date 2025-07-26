import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernSearchField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool enableClearButton;
  final bool enableSearchButton;
  final VoidCallback? onSearchTap;
  final bool enableVoiceSearch;
  final VoidCallback? onVoiceSearchTap;
  final bool enableFilters;
  final VoidCallback? onFiltersTap;
  final List<String>? recentSearches;
  final ValueChanged<String>? onRecentSearchTap;

  const ModernSearchField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding,
    this.enableClearButton = true,
    this.enableSearchButton = true,
    this.onSearchTap,
    this.enableVoiceSearch = false,
    this.onVoiceSearchTap,
    this.enableFilters = false,
    this.onFiltersTap,
    this.recentSearches,
    this.onRecentSearchTap,
  });

  @override
  State<ModernSearchField> createState() => _ModernSearchFieldState();
}

class _ModernSearchFieldState extends State<ModernSearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFocused = false;
  bool _hasText = false;
  late TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = widget.controller ?? TextEditingController();
    _hasText = _textController.text.isNotEmpty;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _textController.dispose();
    }
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChanged() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused != _isFocused) {
      setState(() => _isFocused = isFocused);
      if (isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _onClear() {
    _textController.clear();
    widget.onClear?.call();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor ?? theme.colorScheme.surface,
                  borderRadius:
                      widget.borderRadius ?? BorderRadius.circular(16),
                  border: Border.all(
                    color: _isFocused
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: _isFocused ? 2 : 1,
                  ),
                  boxShadow: _isFocused
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: widget.prefixIcon!,
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Icon(
                          Icons.search,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ],
                    Expanded(
                      child: TextFormField(
                        controller: _textController,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        autofocus: widget.autofocus,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        inputFormatters: widget.inputFormatters,
                        validator: widget.validator,
                        onChanged: widget.onChanged,
                        onFieldSubmitted: widget.onSubmitted,
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: widget.hintText ?? 'Buscar...',
                          labelText: widget.labelText,
                          border: InputBorder.none,
                          contentPadding: widget.contentPadding ??
                              const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    if (widget.enableClearButton && _hasText) ...[
                      IconButton(
                        onPressed: _onClear,
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                    if (widget.enableVoiceSearch) ...[
                      IconButton(
                        onPressed: widget.onVoiceSearchTap,
                        icon: Icon(
                          Icons.mic,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                    if (widget.enableFilters) ...[
                      IconButton(
                        onPressed: widget.onFiltersTap,
                        icon: Icon(
                          Icons.tune,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                    if (widget.suffixIcon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: widget.suffixIcon!,
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.recentSearches != null &&
                  widget.recentSearches!.isNotEmpty &&
                  _isFocused) ...[
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildRecentSearches(theme),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Búsquedas recientes',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...widget.recentSearches!.map((search) => ListTile(
                leading: Icon(
                  Icons.history,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                title: Text(
                  search,
                  style: theme.textTheme.bodyMedium,
                ),
                onTap: () {
                  _textController.text = search;
                  widget.onRecentSearchTap?.call(search);
                  _focusNode.unfocus();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
              )),
        ],
      ),
    );
  }
}

// Campo de búsqueda con filtros
class ModernSearchFieldWithFilters extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<ModernSearchFilter> filters;
  final List<ModernSearchFilter> selectedFilters;
  final ValueChanged<ModernSearchFilter>? onFilterChanged;

  const ModernSearchFieldWithFilters({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    required this.filters,
    required this.selectedFilters,
    this.onFilterChanged,
  });

  @override
  State<ModernSearchFieldWithFilters> createState() =>
      _ModernSearchFieldWithFiltersState();
}

class _ModernSearchFieldWithFiltersState
    extends State<ModernSearchFieldWithFilters> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ModernSearchField(
          hintText: widget.hintText,
          controller: widget.controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          enableFilters: true,
          onFiltersTap: _showFilterDialog,
        ),
        if (widget.selectedFilters.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedFilters.map((filter) {
              return Chip(
                label: Text(filter.label),
                onDeleted: () {
                  widget.onFilterChanged?.call(filter);
                },
                backgroundColor: theme.colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                deleteIcon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 18,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        filters: widget.filters,
        selectedFilters: widget.selectedFilters,
        onFilterChanged: widget.onFilterChanged,
      ),
    );
  }
}

class ModernSearchFilter {
  final String id;
  final String label;
  final IconData? icon;
  final Color? color;

  const ModernSearchFilter({
    required this.id,
    required this.label,
    this.icon,
    this.color,
  });
}

class _FilterBottomSheet extends StatelessWidget {
  final List<ModernSearchFilter> filters;
  final List<ModernSearchFilter> selectedFilters;
  final ValueChanged<ModernSearchFilter>? onFilterChanged;

  const _FilterBottomSheet({
    required this.filters,
    required this.selectedFilters,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Filtros',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilters.contains(filter);

                return ListTile(
                  leading: Icon(
                    filter.icon ?? Icons.filter_list,
                    color: filter.color ?? theme.colorScheme.primary,
                  ),
                  title: Text(filter.label),
                  trailing: Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      onFilterChanged?.call(filter);
                    },
                  ),
                  onTap: () {
                    onFilterChanged?.call(filter);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aplicar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
