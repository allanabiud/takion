import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/local_profile_service.dart';
import 'package:takion/src/presentation/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/providers/profile_provider.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/takion_alerts.dart';

@RoutePage()
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  static const double _expandedHeight = 250;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncTitleOpacity);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncTitleOpacity)
      ..dispose();
    super.dispose();
  }

  void _syncTitleOpacity() {
    final offset = _scrollController.hasClients ? _scrollController.offset : 0;
    const fadeStart = 8.0;
    final fadeEnd = _expandedHeight - kToolbarHeight;
    final next = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);
    if ((next - _titleOpacity).abs() > 0.01) {
      setState(() => _titleOpacity = next);
    }
  }

  String _stringField(
    Map<String, dynamic> profile,
    String key,
    String fallback,
  ) {
    final value = (profile[key] as String?)?.trim();
    return (value == null || value.isEmpty) ? fallback : value;
  }

  Future<void> _showEditProfileSheet(Map<String, dynamic> profile) async {
    final didUpdate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _EditProfileSheet(profile: profile),
    );

    if (!mounted) return;
    if (didUpdate == true) {
      TakionAlerts.success(context, 'Profile updated.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final insightsAsync = ref.watch(profileInsightsProvider);
    final pageBackground = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      body: profileAsync.when(
        loading: () => const _ProfileLoadingView(),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (profile) {
          if (profile == null) {
            return const EmptyContentState(
              icon: Icons.person_outline,
              message: 'No profile available.',
            );
          }
          final displayName = _stringField(
            profile,
            'display_name',
            'Takion Reader',
          );
          final avatarUrl = _stringField(profile, 'avatar_url', '');
          final backdropPath = _stringField(profile, 'backdrop_image_path', '');

          return NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight,
                backgroundColor: pageBackground,
                surfaceTintColor: pageBackground,
                title: Opacity(
                  opacity: _titleOpacity,
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _showEditProfileSheet(profile),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(
                    displayName: displayName,
                    avatarUrl: avatarUrl,
                    backdropPath: backdropPath,
                    titleOpacity: _titleOpacity,
                  ),
                ),
              ),
            ],
            body: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                insightsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('$error'),
                  ),
                  data: (insights) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Collection Stats',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.5,
                        children: [
                          _StatChip(label: 'Owned', value: '${insights.totalOwned}', icon: Icons.inventory_2_outlined),
                          _StatChip(label: 'Read %', value: '${insights.readPercent.toStringAsFixed(1)}%', icon: Icons.menu_book_outlined),
                          _StatChip(label: 'Wishlist', value: '${insights.wishlistCount}', icon: Icons.turned_in_not),
                          _StatChip(label: 'Subscriptions', value: '${insights.subscriptionsCount}', icon: Icons.subscriptions_outlined),
                          _StatChip(label: 'Pulls (Month)', value: '${insights.pullsThisMonth}', icon: Icons.shopping_bag_outlined),
                        ],
                      ),
                      if (insights.topPublishers.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _TagSection(title: 'Top publishers', values: insights.topPublishers),
                        ),
                      ],
                      const Divider(height: 48, thickness: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Reading Insights',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _StatChip(label: 'Streak', value: '${insights.streakDays}d', icon: Icons.local_fire_department_outlined),
                            _StatChip(label: 'Avg rating', value: insights.averageRating == 0 ? '-' : insights.averageRating.toStringAsFixed(2), icon: Icons.star_border),
                            _StatChip(label: 'Most-read', value: insights.mostReadSeries ?? '-', icon: Icons.auto_stories_outlined),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Monthly Read Chart',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _MonthlyReadChart(points: insights.monthlyReads),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: const Icon(Icons.history_outlined),
                        title: const Text('View Reading History', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('See all read issues in your collection'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.pushRoute(const ReadingHistoryRoute()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final Map<String, dynamic> profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _displayNameController;
  late final String _avatarStoragePath;
  String _selectedAvatarPath = '';
  String _selectedBackdropPath = '';
  bool _avatarChanged = false;
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
    _avatarStoragePath = _stringField('avatar_storage_path', '');
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
      _avatarChanged = true;
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
    await ref.read(userProfileProvider.notifier).saveProfile(
          displayName: _displayNameController.text,
          avatarUrl: _avatarChanged ? _selectedAvatarPath : _avatarStoragePath,
          backdropImagePath: _selectedBackdropPath,
          bio: '',
          location: '',
          notificationPreferences: const {'email_pulls': false},
        );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                            foregroundPainter: _DottedRoundedBorderPainter(
                              color: Theme.of(context).colorScheme.outline,
                              radius: 42,
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              backgroundImage: _avatarImageProvider(_selectedAvatarPath),
                              child: _avatarImageProvider(_selectedAvatarPath) == null
                                  ? const Icon(Icons.add_a_photo_outlined)
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
                            child: Icon(Icons.edit, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: _pickBackdrop,
                      child: CustomPaint(
                        foregroundPainter: _DottedRoundedBorderPainter(
                          color: Theme.of(context).colorScheme.outline,
                          radius: 14,
                        ),
                        child: Container(
                          width: 180,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_avatarImageProvider(_selectedBackdropPath) != null)
                                Image(image: _avatarImageProvider(_selectedBackdropPath)!, fit: BoxFit.cover)
                              else
                                const Icon(Icons.landscape_outlined),
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
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
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.avatarUrl,
    required this.backdropPath,
    required this.titleOpacity,
  });

  final String displayName;
  final String avatarUrl;
  final String backdropPath;
  final double titleOpacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final pageBackground = Theme.of(context).scaffoldBackgroundColor;
    final avatarImage = _avatarImageProvider(avatarUrl);
    final backdropImage = _avatarImageProvider(backdropPath);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (backdropImage != null)
            Image(image: backdropImage, fit: BoxFit.cover)
          else
            ColoredBox(color: colorScheme.surfaceContainerHighest),
          DecoratedBox(
            decoration: BoxDecoration(
              color: pageBackground.withValues(alpha: 0.46),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.55, 1],
                colors: [
                  Colors.black.withValues(alpha: 0.56),
                  Colors.black.withValues(alpha: 0.30),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Opacity(
                    opacity: 1 - titleOpacity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: avatarImage,
                          child: avatarImage == null
                              ? Icon(Icons.person_outline, size: 42, color: colorScheme.primary)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 1)),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    final pageBackground = Theme.of(context).scaffoldBackgroundColor;
    return NestedScrollView(
      headerSliverBuilder: (context, _) => [
        SliverAppBar(
          pinned: true,
          expandedHeight: 250,
          backgroundColor: pageBackground,
          surfaceTintColor: pageBackground,
          title: const Text('Profile'),
          flexibleSpace: const FlexibleSpaceBar(
            background: _ProfileHeader(
              displayName: '',
              avatarUrl: '',
              backdropPath: '',
              titleOpacity: 0,
            ),
          ),
        ),
      ],
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

ImageProvider<Object>? _avatarImageProvider(String avatarUrl) {
  final normalized = avatarUrl.trim();
  if (normalized.isEmpty) return null;
  if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
    return NetworkImage(normalized);
  }
  final file = File(normalized);
  if (file.existsSync()) {
    return FileImage(file);
  }
  return null;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.map((value) => Chip(label: Text(value))).toList(),
        ),
      ],
    );
  }
}

class _DottedRoundedBorderPainter extends CustomPainter {
  const _DottedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 1.5;
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect.deflate(strokeWidth / 2));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedRoundedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _MonthlyReadChart extends StatelessWidget {
  const _MonthlyReadChart({required this.points});

  final List<MonthlyReadPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxCount = points.isEmpty
        ? 1
        : points.map((point) => point.count).reduce((a, b) => a > b ? a : b).clamp(1, 9999);
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((point) {
          final fraction = point.count / maxCount;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${point.count}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: (90 * fraction).clamp(4, 90),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    point.label,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
