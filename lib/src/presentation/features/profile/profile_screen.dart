import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_provider.dart';
import 'package:takion/src/presentation/common/empty_content_state.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';
import 'package:takion/src/presentation/components/takion_bottom_sheet.dart';
import 'package:takion/src/presentation/features/profile/widgets/profile_charts.dart';

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
  ProfileFilter _filter = ProfileFilter.month;

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
    final didUpdate = await TakionBottomSheet.show<bool>(
      context: context,
      title: 'Edit Profile',
      child: _EditProfileSheet(profile: profile),
    );

    if (!mounted) return;
    if (didUpdate == true) {
      TakionAlerts.success(context, 'Profile updated.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final insightsAsync = ref.watch(profileInsightsProvider(_filter));
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
              padding: EdgeInsets.only(
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: ProfileFilter.values
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                f == ProfileFilter.allTime
                                    ? 'All-Time'
                                    : f.name[0].toUpperCase() +
                                          f.name.substring(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: _filter == f,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _filter = f);
                                }
                              },
                              shape: const StadiumBorder(),
                              showCheckmark: true,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: insightsAsync.when(
                    loading: () => const Padding(
                      key: ValueKey('loading'),
                      padding: EdgeInsets.only(top: 100),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, _) => Padding(
                      key: ValueKey('error'),
                      padding: const EdgeInsets.all(16),
                      child: Text('$error'),
                    ),
                    data: (insights) => Column(
                      key: ValueKey(_filter),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Library Stats',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
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
                          childAspectRatio: 2.2,
                          children: [
                            _StatCard(
                              label: 'Total Owned',
                              value: '${insights.totalOwned}',
                              icon: Icons.inventory_2_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            _StatCard(
                              label: 'Read %',
                              value:
                                  '${insights.readPercent.toStringAsFixed(1)}%',
                              icon: Icons.menu_book_outlined,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            _StatCard(
                              label: 'Reads (${_filterLabel(_filter)})',
                              value: '${insights.readsInPeriod}',
                              icon: Icons.auto_stories_outlined,
                              color: Colors.green,
                            ),
                            _StatCard(
                              label: 'Pulls (${_filterLabel(_filter)})',
                              value: '${insights.pullsInPeriod}',
                              icon: Icons.shopping_bag_outlined,
                              color: Colors.orange,
                            ),
                            _StatCard(
                              label: 'Wishlist',
                              value: '${insights.wishlistCount}',
                              icon: Icons.turned_in_not,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            _StatCard(
                              label: 'Subscriptions',
                              value: '${insights.subscriptionsCount}',
                              icon: Icons.notifications_outlined,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Reading Trends',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ReadingTrendChart(
                            data: insights.readingTrends,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Reading Insights',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                _InsightRow(
                                  label: 'Current Streak',
                                  value: '${insights.streakDays} Days',
                                  icon: Icons.local_fire_department,
                                  iconColor: Colors.orange,
                                ),
                                const Divider(height: 24),
                                _InsightRow(
                                  label: 'Avg Rating',
                                  value: insights.averageRating == 0
                                      ? '-'
                                      : insights.averageRating.toStringAsFixed(
                                          2,
                                        ),
                                  icon: Icons.star,
                                  iconColor: Colors.amber,
                                ),
                                const Divider(height: 24),
                                // Most-Read Series: wrap to two lines and use app series icon
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.collections_bookmark_outlined,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Most-Read Series',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 180,
                                      ),
                                      child: Text(
                                        insights.mostReadSeries ?? '-',
                                        textAlign: TextAlign.right,
                                        maxLines: 2,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (insights.topPublishers.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Top Publishers',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: PublisherDistributionChart(
                              publishers: insights.topPublishers,
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.history_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(
                              'Reading History',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'View all issues you have finished reading',
                            ),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () =>
                                context.pushRoute(const ReadingHistoryRoute()),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _filterLabel(ProfileFilter filter) {
    switch (filter) {
      case ProfileFilter.week:
        return 'Week';
      case ProfileFilter.month:
        return 'Month';
      case ProfileFilter.year:
        return 'Year';
      case ProfileFilter.allTime:
        return 'All-Time';
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
    await ref
        .read(userProfileProvider.notifier)
        .saveProfile(
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
                        foregroundPainter: _DottedRoundedBorderPainter(
                          color: Theme.of(context).colorScheme.outline,
                          radius: 42,
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          backgroundImage: _avatarImageProvider(
                            _selectedAvatarPath,
                          ),
                          child:
                              _avatarImageProvider(_selectedAvatarPath) == null
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
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (_avatarImageProvider(_selectedBackdropPath) !=
                              null)
                            Image(
                              image: _avatarImageProvider(
                                _selectedBackdropPath,
                              )!,
                              fit: BoxFit.cover,
                            )
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
                              child: const Icon(
                                Icons.edit,
                                size: 12,
                                color: Colors.white,
                              ),
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.6),
                    colorScheme.secondaryContainer.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: pageBackground.withValues(alpha: 0.3),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.55, 1],
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.2),
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
                        avatarImage != null
                            ? CircleAvatar(
                                radius: 52,
                                backgroundImage: avatarImage,
                              )
                            : const Icon(Icons.account_circle, size: 104),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 8,
                                        offset: Offset(0, 1),
                                      ),
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
