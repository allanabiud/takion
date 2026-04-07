import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/network/supabase_service.dart';
import 'package:takion/src/presentation/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/providers/profile_provider.dart';
import 'package:takion/src/presentation/widgets/empty_content_state.dart';
import 'package:takion/src/presentation/widgets/rounded_tab_chrome.dart';
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

  Map<String, dynamic> _notificationPrefs(Map<String, dynamic> profile) {
    final raw = profile['notification_preferences'];
    if (raw is Map) {
      final prefs = raw.cast<String, dynamic>();
      return {'email_pulls': (prefs['email_pulls'] as bool?) ?? false};
    }
    return const {'email_pulls': false};
  }

  DateTime? _joinedDate(Map<String, dynamic> profile) {
    final raw = profile['created_at'];
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  Future<void> _showEditActionsSheet(Map<String, dynamic> profile) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Actions',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Edit Profile'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Future<void>.delayed(Duration.zero);
                    if (!mounted) return;
                    await _showEditProfileSheet(profile);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Edit Account'),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await Future<void>.delayed(Duration.zero);
                    if (!mounted) return;
                    await _showEditAccountSheet();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditAccountSheet() async {
    final result = await showModalBottomSheet<_EditAccountAction>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => const _EditAccountSheet(),
    );

    if (!mounted) return;
    if (result == _EditAccountAction.passwordUpdated) {
      TakionAlerts.success(context, 'Password updated.');
    } else if (result == _EditAccountAction.accountDeleted) {
      TakionAlerts.success(context, 'Account deleted.');
    }
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
    final colorScheme = Theme.of(context).colorScheme;
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
          final email = _stringField(profile, 'email', 'No email');
          final avatarUrl = _stringField(profile, 'avatar_url', '');
          final backdropPath = _stringField(profile, 'backdrop_image_path', '');
          final bio = _stringField(profile, 'bio', 'No bio yet.');
          final location = _stringField(profile, 'location', 'Not set');
          final joinedDate = _joinedDate(profile);
          final prefs = _notificationPrefs(profile);

          return DefaultTabController(
            length: 2,
            child: NestedScrollView(
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
                      onPressed: () => _showEditActionsSheet(profile),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: _ProfileHeader(
                      displayName: displayName,
                      email: email,
                      avatarUrl: avatarUrl,
                      backdropPath: backdropPath,
                      titleOpacity: _titleOpacity,
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SegmentedTabSliverHeaderDelegate(
                    child: Container(
                      color: pageBackground,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: SegmentedTabs(
                        labels: const ['Profile', 'Stats'],
                        selectedColor: colorScheme.primary,
                        selectedTextColor: colorScheme.onPrimary,
                        unselectedColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.9),
                        unselectedTextColor: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(bio),
                              const SizedBox(height: 8),
                              _ProfileMetaRow(
                                icon: Icons.location_on_outlined,
                                label: 'Location',
                                value: location,
                              ),
                              _ProfileMetaRow(
                                icon: Icons.event_outlined,
                                label: 'Joined',
                                value: joinedDate == null
                                    ? '-'
                                    : '${joinedDate.year}-${joinedDate.month.toString().padLeft(2, '0')}-${joinedDate.day.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notification Preferences',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              _PrefRow(
                                label: 'Email notifications for pulls',
                                enabled:
                                    (prefs['email_pulls'] as bool?) ?? false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      insightsAsync.when(
                        loading: () => const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        error: (error, _) => Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text('$error'),
                          ),
                        ),
                        data: (insights) => Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Collection Stats',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your collection at a glance',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 10),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 2.25,
                                      children: [
                                        _StatChip(
                                          label: 'Owned',
                                          value: '${insights.totalOwned}',
                                          icon: Icons.inventory_2_outlined,
                                        ),
                                        _StatChip(
                                          label: 'Read %',
                                          value:
                                              '${insights.readPercent.toStringAsFixed(1)}%',
                                          icon: Icons.menu_book_outlined,
                                        ),
                                        _StatChip(
                                          label: 'Wishlist',
                                          value: '${insights.wishlistCount}',
                                          icon: Icons.bookmark_border,
                                        ),
                                        _StatChip(
                                          label: 'Subscriptions',
                                          value:
                                              '${insights.subscriptionsCount}',
                                          icon: Icons.subscriptions_outlined,
                                        ),
                                        _StatChip(
                                          label: 'Pulls (Month)',
                                          value: '${insights.pullsThisMonth}',
                                          icon: Icons.shopping_bag_outlined,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (insights.topPublishers.isEmpty)
                                      const Text('Top publishers: -')
                                    else
                                      _TagSection(
                                        title: 'Top publishers',
                                        values: insights.topPublishers,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reading Insights',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Your reading habits and momentum',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      children: [
                                        _StatChip(
                                          label: 'Streak',
                                          value: '${insights.streakDays}d',
                                          icon: Icons
                                              .local_fire_department_outlined,
                                        ),
                                        _StatChip(
                                          label: 'Avg rating',
                                          value: insights.averageRating == 0
                                              ? '-'
                                              : insights.averageRating
                                                    .toStringAsFixed(2),
                                          icon: Icons.star_border,
                                        ),
                                        _StatChip(
                                          label: 'Most-read series',
                                          value: insights.mostReadSeries ?? '-',
                                          icon: Icons.auto_stories_outlined,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Monthly Read Chart',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: _MonthlyReadChart(
                                        points: insights.monthlyReads,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Reading History',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      margin: EdgeInsets.zero,
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.history_outlined,
                                        ),
                                        title: const Text(
                                          'View Reading History',
                                        ),
                                        subtitle: const Text(
                                          'See all read issues in your collection',
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                        ),
                                        onTap: () {
                                          context.pushRoute(
                                            const ReadingHistoryRoute(),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
  late final TextEditingController _bioController;
  late final TextEditingController _locationController;
  late final Map<String, dynamic> _prefs;
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

  Map<String, dynamic> _notificationPrefs() {
    final raw = widget.profile['notification_preferences'];
    if (raw is Map) {
      final prefs = raw.cast<String, dynamic>();
      return {'email_pulls': (prefs['email_pulls'] as bool?) ?? false};
    }
    return {'email_pulls': false};
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(
      text: _stringField('display_name', ''),
    );
    _bioController = TextEditingController(text: _stringField('bio', ''));
    _locationController = TextEditingController(
      text: _stringField('location', ''),
    );
    _prefs = Map<String, dynamic>.from(_notificationPrefs());
    _selectedAvatarPath = _stringField('avatar_url', '');
    _avatarStoragePath = _stringField('avatar_storage_path', '');
    _selectedBackdropPath = _stringField('backdrop_image_path', '');
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
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

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await ref
        .read(userProfileProvider.notifier)
        .saveProfile(
          displayName: _displayNameController.text,
          avatarUrl: _avatarChanged ? _selectedAvatarPath : _avatarStoragePath,
          backdropImagePath: _selectedBackdropPath,
          bio: _bioController.text,
          location: _locationController.text,
          notificationPreferences: _prefs,
        );
    if (!mounted) return;
    Navigator.of(context).pop(true);
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
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              backgroundImage: _avatarImageProvider(
                                _selectedAvatarPath,
                              ),
                              child:
                                  _avatarImageProvider(_selectedAvatarPath) ==
                                      null
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
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Email notifications for pulls'),
                value: (_prefs['email_pulls'] as bool?) ?? false,
                onChanged: (value) =>
                    setState(() => _prefs['email_pulls'] = value),
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

class _EditAccountSheet extends ConsumerStatefulWidget {
  const _EditAccountSheet();

  @override
  ConsumerState<_EditAccountSheet> createState() => _EditAccountSheetState();
}

enum _EditAccountAction { passwordUpdated, accountDeleted }

class _EditAccountSheetState extends ConsumerState<_EditAccountSheet>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  late final TabController _tabController;
  bool _isSaving = false;
  bool _isDeleting = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (password.length < 8) {
      setState(() {
        _errorText = 'Password must be at least 8 characters.';
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _errorText = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    try {
      await ref
          .read(supabaseClientProvider)
          .auth
          .updateUser(UserAttributes(password: password));
      await ref
          .read(supabaseProfileServiceProvider)
          .updateStoredPassword(password);
      if (!mounted) return;
      Navigator.of(context).pop(_EditAccountAction.passwordUpdated);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = error.message;
        _isSaving = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = '$error';
        _isSaving = false;
      });
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete account?'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (!mounted || confirmed != true) return;

    setState(() {
      _errorText = null;
      _isDeleting = true;
    });

    try {
      await ref.read(supabaseProfileServiceProvider).deleteCurrentAccount();
      if (!mounted) return;
      Navigator.of(context).pop(_EditAccountAction.accountDeleted);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorText = '$error';
        _isDeleting = false;
      });
    }
  }

  Widget _buildPasswordTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'New password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
                icon: Icon(
                  _obscureNewPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm new password',
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: (_isSaving || _isDeleting) ? null : _submit,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Update Password'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Delete Account',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This will permanently delete your profile, collection, pull list, and subscriptions.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: (_isSaving || _isDeleting) ? null : _deleteAccount,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_outline),
              label: const Text('Delete Account'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Edit Account',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              splashBorderRadius: BorderRadius.circular(999),
              labelStyle: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
              tabs: const [
                Tab(text: 'Update Password'),
                Tab(text: 'Delete Account'),
              ],
              labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
              unselectedLabelColor: Theme.of(
                context,
              ).textTheme.bodyMedium?.color,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _tabController.index == 0
                  ? _buildPasswordTab(context)
                  : _buildDeleteAccountTab(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.backdropPath,
    required this.titleOpacity,
  });

  final String displayName;
  final String email;
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
                              ? Icon(
                                  Icons.person_outline,
                                  size: 42,
                                  color: colorScheme.primary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
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
                              const SizedBox(height: 4),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black45,
                                          blurRadius: 8,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                              ),
                            ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final pageBackground = Theme.of(context).scaffoldBackgroundColor;
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
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
                email: '',
                avatarUrl: '',
                backdropPath: '',
                titleOpacity: 0,
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SegmentedTabSliverHeaderDelegate(
              child: Container(
                color: pageBackground,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: SegmentedTabs(
                  labels: const ['Profile', 'Stats'],
                  selectedColor: colorScheme.primary,
                  selectedTextColor: colorScheme.onPrimary,
                  unselectedColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.9),
                  unselectedTextColor: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
        body: const Center(child: CircularProgressIndicator()),
      ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMetaRow extends StatelessWidget {
  const _ProfileMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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

class _PrefRow extends StatelessWidget {
  const _PrefRow({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(
        enabled ? Icons.notifications_active : Icons.notifications_off_outlined,
      ),
      title: Text(label),
      trailing: Icon(
        enabled ? Icons.check_circle : Icons.remove_circle_outline,
      ),
    );
  }
}

class _MonthlyReadChart extends StatelessWidget {
  const _MonthlyReadChart({required this.points});

  final List<MonthlyReadPoint> points;

  @override
  Widget build(BuildContext context) {
    final maxCount = points.isEmpty
        ? 1
        : points
              .map((point) => point.count)
              .reduce((a, b) => a > b ? a : b)
              .clamp(1, 9999);
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
