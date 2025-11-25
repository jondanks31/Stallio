import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/ui/gradient_background.dart';
import '../../../core/ui/snackbar_service.dart';
import '../data/onboarding_repository.dart';

/// Onboarding wizard shown to new users after signup.
/// Guides them through profile setup and yard creation (if applicable).
class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key, this.onComplete});

  /// Called when onboarding is complete.
  final VoidCallback? onComplete;

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final _repository = OnboardingRepository();
  final _pageController = PageController();

  // Form controllers
  final _nameController = TextEditingController();
  final _yardNameController = TextEditingController();
  final _yardAddressController = TextEditingController();

  // State
  int _currentStep = 0;
  bool _isYardOwner = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _yardNameController.dispose();
    _yardAddressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    try {
      // Save profile name
      await _repository.updateProfileName(_nameController.text.trim());

      // Create yard if owner
      if (_isYardOwner) {
        await _repository.createYard(
          name: _yardNameController.text.trim(),
          address: _yardAddressController.text.trim().isEmpty
              ? null
              : _yardAddressController.text.trim(),
        );
      }

      // Mark onboarding complete
      await _repository.completeOnboarding();

      if (mounted) {
        SnackbarService.showSuccess(context, 'Welcome to Stallio!');
        widget.onComplete?.call();
      }
    } on SocketException {
      if (mounted) {
        SnackbarService.showError(context, 'No internet connection.');
      }
    } catch (e) {
      debugPrint('Onboarding error: $e');
      if (mounted) {
        SnackbarService.showError(
          context,
          'Something went wrong: ${e.toString().length > 50 ? e.toString().substring(0, 50) : e}',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  // Header with progress
                  Padding(
                    padding: EdgeInsets.all(isDesktop ? 32 : 24),
                    child: Column(
                      children: [
                        Text(
                          'STALLIO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Progress indicator
                        Row(
                          children: List.generate(3, (index) {
                            final isActive = index <= _currentStep;
                            return Expanded(
                              child: Container(
                                height: 4,
                                margin: EdgeInsets.only(
                                  right: index < 2 ? 8 : 0,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFFFD66B)
                                      : (isDark
                                            ? Colors.white24
                                            : Colors.black12),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  // Page content
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [_buildStep1(), _buildStep2(), _buildStep3()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Step 1: Enter your name
  Widget _buildStep1() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Let's get started",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "First, tell us your name.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full name',
                filled: true,
                fillColor: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _nameController.text.trim().isEmpty ? null : _nextStep,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFFFFD66B),
                foregroundColor: Colors.black87,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Are you a yard owner?
  Widget _buildStep2() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Do you own a yard?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This helps us set up the right experience for you.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            // Option cards
            _buildOptionCard(
              title: 'Yes, I own or manage a yard',
              subtitle: 'Set up your yard, invite staff and customers',
              icon: Icons.home_work_outlined,
              isSelected: _isYardOwner,
              onTap: () => setState(() => _isYardOwner = true),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              title: "No, I'm a horse owner",
              subtitle: 'Manage your horses and join a yard later',
              icon: Icons.pets_outlined,
              isSelected: !_isYardOwner,
              onTap: () => setState(() => _isYardOwner = false),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                TextButton(onPressed: _previousStep, child: const Text('Back')),
                const Spacer(),
                FilledButton(
                  onPressed: _nextStep,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0xFFFFD66B),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Step 3: Yard setup (if owner) or confirmation (if user)
  Widget _buildStep3() {
    if (_isYardOwner) {
      return _buildYardSetup();
    } else {
      return _buildUserConfirmation();
    }
  }

  Widget _buildYardSetup() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set up your yard',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tell us about your yard. You can add more details later.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _yardNameController,
              decoration: InputDecoration(
                labelText: 'Yard name',
                filled: true,
                fillColor: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yardAddressController,
              decoration: InputDecoration(
                labelText: 'Address (optional)',
                filled: true,
                fillColor: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                TextButton(
                  onPressed: _isLoading ? null : _previousStep,
                  child: const Text('Back'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed:
                      _yardNameController.text.trim().isEmpty || _isLoading
                      ? null
                      : _completeOnboarding,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0xFFFFD66B),
                    foregroundColor: Colors.black87,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create yard',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserConfirmation() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "You're all set!",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You can now manage your profile and horses. To access yard features, you'll need to join a yard.",
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            // Info cards
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'How to join a yard',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Ask your yard owner for an invite code\n'
                    '• Or accept an email invitation from them',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                TextButton(
                  onPressed: _isLoading ? null : _previousStep,
                  child: const Text('Back'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0xFFFFD66B),
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Get started',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD66B).withValues(alpha: 0.2)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD66B)
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFFD66B)
                    : (isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.black87
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFFFFD66B),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
