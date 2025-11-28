import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/snackbar_service.dart';

/// Logo type options for yard branding
enum LogoType { defaultLogo, text, image }

/// Yard branding settings
class YardBranding {
  final LogoType logoType;
  final String? logoText;
  final String? logoUrl;

  const YardBranding({
    this.logoType = LogoType.defaultLogo,
    this.logoText,
    this.logoUrl,
  });

  factory YardBranding.fromJson(Map<String, dynamic> json) {
    return YardBranding(
      logoType: _parseLogoType(json['logo_type'] as String?),
      logoText: json['logo_text'] as String?,
      logoUrl: json['logo_url'] as String?,
    );
  }

  static LogoType _parseLogoType(String? type) {
    switch (type) {
      case 'text':
        return LogoType.text;
      case 'image':
        return LogoType.image;
      default:
        return LogoType.defaultLogo;
    }
  }

  String get logoTypeString {
    switch (logoType) {
      case LogoType.text:
        return 'text';
      case LogoType.image:
        return 'image';
      default:
        return 'default';
    }
  }
}

/// General settings section for yard management
/// Allows owners to customize yard branding (logo)
class GeneralSection extends StatefulWidget {
  const GeneralSection({
    super.key,
    required this.yardId,
    required this.branding,
    required this.onBrandingChanged,
  });

  final String yardId;
  final YardBranding branding;
  final ValueChanged<YardBranding> onBrandingChanged;

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  final _supabase = Supabase.instance.client;
  final _textController = TextEditingController();
  final _imagePicker = ImagePicker();

  late LogoType _selectedType;
  bool _isUploading = false;
  String? _previewUrl;

  // Logo constraints
  static const int _maxFileSizeBytes = 512 * 1024; // 512KB
  static const int _maxWidth = 400;
  static const int _maxHeight = 100;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.branding.logoType;
    _textController.text = widget.branding.logoText ?? '';
    _previewUrl = widget.branding.logoUrl;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Text(
            'Yard Branding',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize how your yard appears to members. Your logo replaces the default Stallio branding in the app header.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 32),

          // Logo type selector
          Text(
            'Logo Type',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildLogoTypeSelector(isDark),
          const SizedBox(height: 24),

          // Logo preview
          _buildLogoPreview(theme, isDark),
          const SizedBox(height: 24),

          // Logo input based on type
          if (_selectedType == LogoType.text) _buildTextInput(theme, isDark),
          if (_selectedType == LogoType.image) _buildImageUpload(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildLogoTypeSelector(bool isDark) {
    return Row(
      children: [
        _buildTypeOption(
          LogoType.defaultLogo,
          'Default',
          Icons.auto_awesome,
          isDark,
        ),
        const SizedBox(width: 12),
        _buildTypeOption(
          LogoType.text,
          'Custom Text',
          Icons.text_fields,
          isDark,
        ),
        const SizedBox(width: 12),
        _buildTypeOption(
          LogoType.image,
          'Upload Logo',
          Icons.image_outlined,
          isDark,
        ),
      ],
    );
  }

  Widget _buildTypeOption(
    LogoType type,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedType == type;
    final accentColor = const Color(0xFFFFD66B);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedType = type);
          _saveLogoType(type);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.15)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? accentColor
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black87)
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPreview(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          ),
          child: Center(child: _buildLogoWidget(isDark)),
        ),
      ],
    );
  }

  Widget _buildLogoWidget(bool isDark) {
    switch (_selectedType) {
      case LogoType.text:
        final text = _textController.text.isNotEmpty
            ? _textController.text
            : 'YOUR YARD';
        return Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            letterSpacing: 4,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black87,
          ),
        );

      case LogoType.image:
        if (_previewUrl != null) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 50, maxWidth: 200),
            child: Image.network(
              _previewUrl!,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildDefaultLogo(isDark),
            ),
          );
        }
        return _buildDefaultLogo(isDark);

      case LogoType.defaultLogo:
        return _buildDefaultLogo(isDark);
    }
  }

  Widget _buildDefaultLogo(bool isDark) {
    return Text(
      'STALLIO',
      style: TextStyle(
        fontSize: 18,
        letterSpacing: 4,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTextInput(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yard Name',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your yard name (max 20 characters). It will be displayed in uppercase.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _textController,
          maxLength: 20,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'e.g. SUNNY MEADOWS',
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            setState(() {}); // Update preview
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _saveTextLogo,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFFD66B),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Logo Text'),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Logo',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload a logo image. Recommended size: ${_maxWidth}x$_maxHeight pixels. Max file size: 512KB. Supported formats: PNG, JPG, WebP, SVG.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadImage,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                if (_isUploading)
                  const CircularProgressIndicator()
                else ...[
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Click to upload',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PNG, JPG, WebP or SVG',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_previewUrl != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Current logo uploaded',
                  style: TextStyle(color: Colors.green[400], fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: _removeLogo,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
                style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Future<void> _saveLogoType(LogoType type) async {
    try {
      await _supabase
          .from('yards')
          .update({
            'logo_type': type == LogoType.defaultLogo
                ? 'default'
                : (type == LogoType.text ? 'text' : 'image'),
          })
          .eq('id', widget.yardId);

      widget.onBrandingChanged(
        YardBranding(
          logoType: type,
          logoText: widget.branding.logoText,
          logoUrl: widget.branding.logoUrl,
        ),
      );
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update logo type');
      }
    }
  }

  Future<void> _saveTextLogo() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      SnackbarService.showError(context, 'Please enter a yard name');
      return;
    }

    try {
      await _supabase
          .from('yards')
          .update({'logo_type': 'text', 'logo_text': text.toUpperCase()})
          .eq('id', widget.yardId);

      widget.onBrandingChanged(
        YardBranding(
          logoType: LogoType.text,
          logoText: text.toUpperCase(),
          logoUrl: widget.branding.logoUrl,
        ),
      );

      if (mounted) {
        SnackbarService.showSuccess(context, 'Logo text saved');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to save logo text');
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxWidth.toDouble(),
        maxHeight: _maxHeight.toDouble(),
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      // Check file size
      final bytes = await pickedFile.readAsBytes();
      if (bytes.length > _maxFileSizeBytes) {
        if (mounted) {
          SnackbarService.showError(
            context,
            'Image too large. Max size is 512KB.',
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      // Upload to Supabase Storage
      final fileName =
          'logo_${DateTime.now().millisecondsSinceEpoch}.${pickedFile.name.split('.').last}';
      final path = '${widget.yardId}/$fileName';

      await _supabase.storage
          .from('yard-logos')
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _getMimeType(pickedFile.name),
              upsert: true,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from('yard-logos').getPublicUrl(path);

      // Update yard record
      await _supabase
          .from('yards')
          .update({'logo_type': 'image', 'logo_url': publicUrl})
          .eq('id', widget.yardId);

      setState(() {
        _previewUrl = publicUrl;
        _isUploading = false;
      });

      widget.onBrandingChanged(
        YardBranding(
          logoType: LogoType.image,
          logoText: widget.branding.logoText,
          logoUrl: publicUrl,
        ),
      );

      if (mounted) {
        SnackbarService.showSuccess(context, 'Logo uploaded successfully');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        SnackbarService.showError(context, 'Failed to upload logo: $e');
      }
    }
  }

  String _getMimeType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      default:
        return 'image/png';
    }
  }

  Future<void> _removeLogo() async {
    try {
      // Delete from storage if exists
      if (_previewUrl != null) {
        final uri = Uri.parse(_previewUrl!);
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2) {
          final storagePath = pathSegments
              .sublist(pathSegments.indexOf('yard-logos') + 1)
              .join('/');
          await _supabase.storage.from('yard-logos').remove([storagePath]);
        }
      }

      // Update yard record
      await _supabase
          .from('yards')
          .update({'logo_type': 'default', 'logo_url': null})
          .eq('id', widget.yardId);

      setState(() {
        _selectedType = LogoType.defaultLogo;
        _previewUrl = null;
      });

      widget.onBrandingChanged(
        const YardBranding(logoType: LogoType.defaultLogo),
      );

      if (mounted) {
        SnackbarService.showSuccess(context, 'Logo removed');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to remove logo');
      }
    }
  }
}
