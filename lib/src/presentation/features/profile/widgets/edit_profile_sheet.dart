import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/features/profile/widgets/avatar_image_provider.dart';
import 'package:takion/src/presentation/features/profile/widgets/dotted_rounded_border_painter.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key, required this.profile});

  final Map<String, dynamic> profile;

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _displayNameController;
  String _selectedAvatarPath = '';
  String _selectedBackdropPath = '';
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();

  String _stringField(String key, String fallback) {
    final value = (widget.profile[key] as String?)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: _stringField('display_name', ''),
    );
    _selectedAvatarPath = _stringField('avatar_url', '');
    _selectedBackdropPath = _stringField('backdrop_image_path', '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedAvatarPath = picked.path;
    });
  }

  Future<void> _pickBackdrop() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _selectedBackdropPath = picked.path;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await ref
        .read(userProfileProvider.notifier)
        .saveProfile(
          displayName: _displayNameController.text,
          avatarUrl: _selectedAvatarPath,
          backdropImagePath: _selectedBackdropPath,
        );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CustomPaint(
                        foregroundPainter: DottedRoundedBorderPainter(
                          color: Theme.of(context).colorScheme.outline,
                          radius: 42,
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          backgroundImage: avatarImageProvider(
                            _selectedAvatarPath,
                          ),
                          child:
                              avatarImageProvider(_selectedAvatarPath) == null
                              ? Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 28,
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: _pickBackdrop,
                      child: CustomPaint(
                        foregroundPainter: DottedRoundedBorderPainter(
                          color: Theme.of(context).colorScheme.outline,
                          radius: 14,
                        ),
                        child: Container(
                          width: 180,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: avatarImageProvider(_selectedBackdropPath) !=
                                  null
                              ? Image(
                                  image: avatarImageProvider(
                                    _selectedBackdropPath,
                                  )!,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.landscape_outlined,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  size: 28,
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _displayNameController,
            decoration: const InputDecoration(labelText: 'Display name'),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
