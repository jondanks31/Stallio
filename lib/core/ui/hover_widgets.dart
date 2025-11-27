import 'package:flutter/material.dart';

/// Card with hover effect - lifts and increases shadow on hover.
class HoverCard extends StatefulWidget {
  const HoverCard({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.borderRadius = 16,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;
  final double borderRadius;

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.9)
                : widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.06),
                blurRadius: _isHovered ? 16 : 8,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          transform: _isHovered
              ? (Matrix4.identity()..setTranslationRaw(0.0, -2.0, 0.0))
              : Matrix4.identity(),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Small icon button with hover background effect.
class HoverIconButton extends StatefulWidget {
  const HoverIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.size = 14,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final double size;

  @override
  State<HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? Colors.grey;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _isHovered ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: baseColor.withValues(alpha: _isHovered ? 1.0 : 0.7),
          ),
        ),
      ),
    );
  }
}

/// Sidebar menu item with hover effect.
class HoverMenuItem extends StatefulWidget {
  const HoverMenuItem({
    super.key,
    required this.child,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final Widget child;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  State<HoverMenuItem> createState() => _HoverMenuItemState();
}

class _HoverMenuItemState extends State<HoverMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Selected state takes priority over hover
    Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = const Color(0xFF1E1E1E); // Charcoal
    } else if (_isHovered) {
      backgroundColor = widget.isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05);
    } else {
      backgroundColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
