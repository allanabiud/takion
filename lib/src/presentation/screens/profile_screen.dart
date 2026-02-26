import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takion/src/core/network/supabase_service.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final service = ref.watch(supabaseProfileServiceProvider);
  return service.getCurrentProfile();
});

@RoutePage()
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  static const double _expandedHeight = 188;

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
      setState(() {
        _titleOpacity = next;
      });
    }
  }

  String _profileDisplayName(Map<String, dynamic> profile) {
    final displayName = (profile['display_name'] as String?)?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return 'Takion Reader';
  }

  String _profileEmail(Map<String, dynamic> profile) {
    final email = (profile['email'] as String?)?.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }
    return 'No email';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile available.'));
          }

          final displayName = _profileDisplayName(profile);
          final email = _profileEmail(profile);

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: _expandedHeight,
                backgroundColor: colorScheme.surface,
                surfaceTintColor: colorScheme.surface,
                title: Opacity(
                  opacity: _titleOpacity,
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(
                    displayName: displayName,
                    email: email,
                    titleOpacity: _titleOpacity,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(displayName),
                      subtitle: Text(email),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.titleOpacity,
  });

  final String displayName;
  final String email;
  final double titleOpacity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colorScheme.primaryContainer, colorScheme.surface],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
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
                      radius: 30,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
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
        ),
      ),
    );
  }
}
