import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/ui/snackbar_service.dart';
import '../../../../horses/data/horse_model.dart';
import '../../../../horses/data/horses_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HORSE AVATAR CARD - Avatar display with photo upload
// ─────────────────────────────────────────────────────────────────────────────

/// Large horse avatar with camera button for photo management
class HorseAvatarCard extends StatelessWidget {
  const HorseAvatarCard({
    super.key,
    required this.horse,
    required this.onTap,
    required this.onPhotoUpdated,
  });

  final Horse? horse;
  final VoidCallback? onTap;
  final VoidCallback onPhotoUpdated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    border: Border.all(
                      color: const Color(0xFFFFD66B),
                      width: 3,
                    ),
                  ),
                  child: horse?.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            horse!.photoUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.pets,
                              size: 48,
                              color: isDark ? Colors.white38 : Colors.black26,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.pets,
                          size: 48,
                          color: isDark ? Colors.white38 : Colors.black26,
                        ),
                ),
                if (horse != null)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: _PhotoUploadButton(
                      horse: horse!,
                      onPhotoUpdated: onPhotoUpdated,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              horse?.name ?? 'No horse selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            if (horse != null)
              Text(
                _buildHorseSubtitle(horse!),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              )
            else
              Text(
                'Add a horse to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _buildHorseSubtitle(Horse horse) {
    final parts = <String>[];
    if (horse.color != null) parts.add(horse.color!);
    if (horse.age != null) parts.add(horse.ageDisplay);
    return parts.isEmpty ? 'Tap to edit details' : parts.join(' • ');
  }
}

/// Camera button for uploading horse photos
class _PhotoUploadButton extends StatelessWidget {
  const _PhotoUploadButton({required this.horse, required this.onPhotoUpdated});

  final Horse horse;
  final VoidCallback onPhotoUpdated;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _uploadPhoto(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFD66B),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            width: 2,
          ),
        ),
        child: const Icon(Icons.camera_alt, size: 16, color: Colors.black87),
      ),
    );
  }

  Future<void> _uploadPhoto(BuildContext context) async {
    final repository = HorsesRepository();
    final picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (horse.photoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context, null),
              ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;

    // User chose to remove photo
    if (source == null && horse.photoUrl != null) {
      try {
        await repository.deleteHorsePhoto(horse.id);
        onPhotoUpdated();
        if (context.mounted) {
          SnackbarService.showSuccess(context, 'Photo removed');
        }
      } catch (e) {
        if (context.mounted) {
          SnackbarService.showError(context, 'Failed to remove photo');
        }
      }
      return;
    }

    if (source == null) return;

    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    try {
      await repository.uploadHorsePhoto(horse.id, File(pickedFile.path));
      onPhotoUpdated();
      if (context.mounted) {
        SnackbarService.showSuccess(context, 'Photo updated');
      }
    } catch (e) {
      if (context.mounted) {
        SnackbarService.showError(context, 'Failed to upload photo');
      }
    }
  }
}
