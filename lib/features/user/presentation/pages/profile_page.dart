import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/ui/gradient_background.dart';
import '../../../../core/ui/snackbar_service.dart';
import '../../../horses/data/horse_model.dart';
import '../../../horses/data/horses_repository.dart';
import 'my_horses_page.dart';

/// User profile page - view and edit profile info, see horses
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.yardId, this.userId});

  final String yardId;

  /// If null, shows current user's profile (editable)
  /// If provided, shows that user's profile (view only)
  final String? userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  final _horsesRepository = HorsesRepository();
  final _picker = ImagePicker();

  bool _isLoading = true;
  bool _isUploadingPhoto = false;
  bool _isOwnProfile = true;

  // Profile data
  String? _fullName;
  String? _bio;
  String? _avatarUrl;

  // Horses
  List<Horse> _horses = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadHorses();
  }

  Future<void> _loadProfile() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    final targetUserId = widget.userId ?? currentUserId;
    if (targetUserId == null) return;

    // Determine if viewing own profile
    _isOwnProfile = widget.userId == null || widget.userId == currentUserId;

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', targetUserId)
          .maybeSingle();

      if (mounted && response != null) {
        setState(() {
          _fullName = response['full_name'] as String?;
          _bio = response['bio'] as String?;
          _avatarUrl = response['avatar_url'] as String?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadHorses() async {
    final currentUserId = _supabase.auth.currentUser?.id;
    final targetUserId = widget.userId ?? currentUserId;
    if (targetUserId == null) return;

    try {
      // If viewing own profile, get own horses; otherwise get target user's horses
      final horses = _isOwnProfile
          ? await _horsesRepository.getMyHorses()
          : await _horsesRepository.getHorsesByOwner(targetUserId);
      if (mounted) {
        setState(() => _horses = horses);
      }
    } catch (e) {
      debugPrint('Error loading horses: $e');
    }
  }

  Future<void> _uploadPhoto() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() => _isUploadingPhoto = true);

      final ext = image.path.split('.').last.toLowerCase();
      final path = '$userId/avatar.$ext';

      // Upload to storage
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        await _supabase.storage
            .from('avatars')
            .uploadBinary(
              path,
              bytes,
              fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
            );
      } else {
        await _supabase.storage
            .from('avatars')
            .upload(
              path,
              File(image.path),
              fileOptions: FileOptions(upsert: true, contentType: 'image/$ext'),
            );
      }

      // Get public URL
      final url = _supabase.storage.from('avatars').getPublicUrl(path);

      // Update profile
      await _supabase
          .from('profiles')
          .update({
            'avatar_url': url,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      if (mounted) {
        setState(() {
          _avatarUrl = url;
          _isUploadingPhoto = false;
        });
        SnackbarService.showSuccess(context, 'Photo updated!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        SnackbarService.showError(context, 'Failed to upload photo');
      }
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _fullName);
    final bioController = TextEditingController(text: _bio);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 3,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell us about yourself...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, {
              'name': nameController.text.trim(),
              'bio': bioController.text.trim(),
            }),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      final updates = <String, dynamic>{};
      if (result['name'] != _fullName) {
        updates['full_name'] = result['name'];
      }
      if (result['bio'] != _bio) {
        updates['bio'] = result['bio'];
      }
      if (updates.isNotEmpty) {
        await _updateProfile(updates);
        setState(() {
          _fullName = result['name'];
          _bio = result['bio'];
        });
      }
    }
  }

  Future<void> _updateProfile(Map<String, dynamic> updates) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('profiles')
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId);

      if (mounted) {
        SnackbarService.showSuccess(context, 'Profile updated!');
      }
    } catch (e) {
      if (mounted) {
        SnackbarService.showError(context, 'Failed to update profile');
      }
    }
  }

  void _navigateToHorse(Horse horse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(horse.name),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: GradientBackground(
            child: SafeArea(child: MyHorsesPage(yardId: widget.yardId)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_isOwnProfile ? 'My Profile' : 'Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : isDesktop
              ? _buildDesktopLayout(isDark, screenWidth)
              : _buildMobileLayout(isDark),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark, double screenWidth) {
    // Constrain max width and center content
    final contentWidth = screenWidth > 1200 ? 900.0 : screenWidth * 0.7;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: SizedBox(
          width: contentWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Profile card (fixed width)
              SizedBox(width: 320, child: _buildProfileCard(isDark)),
              const SizedBox(width: 32),
              // Right: Horses section (flexible)
              Expanded(child: _buildHorsesSection(isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(isDark),
          const SizedBox(height: 24),
          _buildHorsesSection(isDark),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Avatar (with camera button only for own profile)
          Stack(
            children: [
              GestureDetector(
                onTap: _isOwnProfile && !_isUploadingPhoto
                    ? _uploadPhoto
                    : null,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFD66B).withValues(alpha: 0.2),
                    image: _avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 48,
                          color: Color(0xFFFFD66B),
                        )
                      : null,
                ),
              ),
              if (_isOwnProfile)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingPhoto ? null : _uploadPhoto,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD66B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: _isUploadingPhoto
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black87,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black87,
                            ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            _fullName ?? 'No name set',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _fullName != null
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white38 : Colors.black38),
            ),
            textAlign: TextAlign.center,
          ),

          // Bio (centered text, no box)
          if (_bio?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              _bio!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Edit Profile button (only for own profile)
          if (_isOwnProfile) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _editProfile,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white70 : Colors.black54,
                side: BorderSide(
                  color: isDark ? Colors.white24 : Colors.black12,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorsesSection(bool isDark) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.pets,
                size: 20,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                _isOwnProfile ? 'My Horses' : 'Horses',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '${_horses.length} ${_horses.length == 1 ? 'horse' : 'horses'}',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horse cards
          if (_horses.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.pets_outlined,
                      size: 48,
                      color: isDark ? Colors.white24 : Colors.black12,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No horses yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: isDesktop ? 16 : 12,
              runSpacing: isDesktop ? 16 : 12,
              children: _horses
                  .map((horse) => _buildHorseCard(horse, isDark, isDesktop))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHorseCard(Horse horse, bool isDark, bool isDesktop) {
    final cardWidth = isDesktop ? 120.0 : 100.0;
    final avatarSize = isDesktop ? 64.0 : 56.0;
    final iconSize = isDesktop ? 32.0 : 28.0;

    return GestureDetector(
      onTap: () => _navigateToHorse(horse),
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(isDesktop ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            // Horse avatar
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFD66B).withValues(alpha: 0.15),
                image: horse.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(horse.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: horse.photoUrl == null
                  ? Icon(
                      Icons.pets,
                      size: iconSize,
                      color: const Color(0xFFFFD66B),
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            // Horse name
            Text(
              horse.name,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
