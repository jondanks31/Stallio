import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A widget that displays the yard's custom logo or the default Stallio branding.
/// Automatically fetches and caches the yard's branding settings.
class YardLogo extends StatefulWidget {
  const YardLogo({
    super.key,
    required this.yardId,
    this.height = 20,
    this.maxWidth = 150,
  });

  final String yardId;
  final double height;
  final double maxWidth;

  @override
  State<YardLogo> createState() => _YardLogoState();
}

class _YardLogoState extends State<YardLogo> {
  final _supabase = Supabase.instance.client;

  String _logoType = 'default';
  String? _logoText;
  String? _logoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranding();
  }

  @override
  void didUpdateWidget(YardLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.yardId != widget.yardId) {
      _loadBranding();
    }
  }

  Future<void> _loadBranding() async {
    try {
      final data = await _supabase
          .from('yards')
          .select('logo_type, logo_text, logo_url')
          .eq('id', widget.yardId)
          .single();

      if (mounted) {
        setState(() {
          _logoType = data['logo_type'] as String? ?? 'default';
          _logoText = data['logo_text'] as String?;
          _logoUrl = data['logo_url'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return _buildDefaultLogo(theme, isDark);
    }

    switch (_logoType) {
      case 'text':
        return _buildTextLogo(theme, isDark);
      case 'image':
        return _buildImageLogo(isDark);
      default:
        return _buildDefaultLogo(theme, isDark);
    }
  }

  Widget _buildDefaultLogo(ThemeData theme, bool isDark) {
    return Text(
      'STALLIO',
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 4,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextLogo(ThemeData theme, bool isDark) {
    return Text(
      _logoText ?? 'STALLIO',
      style: theme.textTheme.labelSmall?.copyWith(
        letterSpacing: 4,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : Colors.black87,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildImageLogo(bool isDark) {
    if (_logoUrl == null) {
      return _buildDefaultLogo(Theme.of(context), isDark);
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.height,
        maxWidth: widget.maxWidth,
      ),
      child: Image.network(
        _logoUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            _buildDefaultLogo(Theme.of(context), isDark),
      ),
    );
  }
}
