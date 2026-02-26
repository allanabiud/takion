import 'dart:convert';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/providers/auth_provider.dart';

@RoutePage()
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _settingsBoxName = 'settings_box';
  static const _seenOnboardingKey = 'has_seen_onboarding';
  static const _logoHeroTag = 'takion-app-logo';
  static const _coversDirectory = 'assets/images/covers/';
  static const List<String> _coverExtensions = [
    '.webp',
    '.jpg',
    '.jpeg',
    '.png',
  ];
  static const List<String> _fallbackCoverAssets = [
    'assets/images/covers/cover1.webp',
    'assets/images/covers/cover2.webp',
    'assets/images/covers/cover3.webp',
    'assets/images/covers/cover4.webp',
    'assets/images/covers/cover5.webp',
    'assets/images/covers/cover6.webp',
    'assets/images/covers/cover7.webp',
    'assets/images/covers/cover8.webp',
    'assets/images/covers/cover9.webp',
    'assets/images/covers/cover10.webp',
    'assets/images/covers/cover11.webp',
    'assets/images/covers/cover12.webp',
    'assets/images/covers/cover13.webp',
    'assets/images/covers/cover14.webp',
    'assets/images/covers/cover15.webp',
    'assets/images/covers/cover16.webp',
    'assets/images/covers/cover17.webp',
    'assets/images/covers/cover18.webp',
    'assets/images/covers/cover19.webp',
    'assets/images/covers/cover20.webp',
  ];

  bool _isCheckingFirstLaunch = true;
  List<String> _coverAssets = List<String>.from(_fallbackCoverAssets);

  @override
  void initState() {
    super.initState();
    _loadCoverAssetsFromManifest();
    _checkFirstLaunch();
  }

  Future<void> _loadCoverAssetsFromManifest() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = jsonDecode(manifestContent) as Map<String, dynamic>;
      final discoveredCoverAssets =
          manifestMap.keys
              .where(
                (assetPath) =>
                    assetPath.startsWith(_coversDirectory) &&
                    _coverExtensions.any(
                      (extension) =>
                          assetPath.toLowerCase().endsWith(extension),
                    ),
              )
              .toList()
            ..sort();

      if (!mounted || discoveredCoverAssets.isEmpty) {
        return;
      }

      setState(() {
        _coverAssets = discoveredCoverAssets;
      });
    } catch (_) {}
  }

  Future<void> _checkFirstLaunch() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox(_settingsBoxName);
    final hasSeen =
        settingsBox.get(_seenOnboardingKey, defaultValue: false) == true;

    if (!mounted) return;

    if (hasSeen) {
      final authStatus = await ref.read(authStateProvider.future);
      if (!mounted) return;

      if (authStatus == AuthStatus.authenticated) {
        context.router.replace(const MainRoute());
      } else {
        context.router.replace(LoginRoute());
      }
      return;
    }

    setState(() {
      _isCheckingFirstLaunch = false;
    });
  }

  Future<void> _handleGetStarted() async {
    context.router.push(LoginRoute());
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstLaunch) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _OnboardingCoversBackground(coverAssets: _coverAssets),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.89),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.98),
                  Colors.black.withValues(alpha: 0.93),
                  Colors.black.withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 28),
                  Hero(
                    tag: _logoHeroTag,
                    child: SvgPicture.asset(
                      'assets/images/takion_logo.svg',
                      height: 128,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Takion',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Discover, track, and organize your comic collection.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _handleGetStarted,
                      child: const Text('Get Started'),
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

class _OnboardingCoversBackground extends StatefulWidget {
  const _OnboardingCoversBackground({required this.coverAssets});

  final List<String> coverAssets;

  @override
  State<_OnboardingCoversBackground> createState() =>
      _OnboardingCoversBackgroundState();
}

class _OnboardingCoversBackgroundState
    extends State<_OnboardingCoversBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  List<String> _buildShuffledAssetsForColumn(int columnIndex) {
    if (widget.coverAssets.isEmpty) return const [];
    final assets = List<String>.from(widget.coverAssets);
    final random = math.Random((columnIndex * 9973) + 17);

    for (var i = assets.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = assets[i];
      assets[i] = assets[j];
      assets[j] = temp;
    }

    return assets;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 54),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const tileWidth = 100.0;
            const tileHeight = 155.0;
            const tileGap = 12.0;
            const columnGap = 12.0;

            final width = constraints.maxWidth;
            final computedColumnCount =
                ((width + columnGap) / (tileWidth + columnGap)).floor();
            final maxColumns = width < 430 ? 4 : 5;
            final columnCount = computedColumnCount.clamp(1, maxColumns);
            final totalColumnsWidth =
                (columnCount * tileWidth) + ((columnCount - 1) * columnGap);
            final horizontalInset = width > totalColumnsWidth
                ? (width - totalColumnsWidth) / 2
                : 0.0;
            final columnAssetOrders = List.generate(
              columnCount,
              _buildShuffledAssetsForColumn,
            );

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Stack(
                  children: List.generate(columnCount, (index) {
                    final left =
                        horizontalInset + (index * (tileWidth + columnGap));
                    return Positioned(
                      left: left,
                      top: 0,
                      bottom: 0,
                      width: tileWidth,
                      child: RepaintBoundary(
                        child: _CoverFlowColumn(
                          columnAssets: columnAssetOrders[index],
                          progress: _controller.value,
                          columnIndex: index,
                          tileWidth: tileWidth,
                          tileHeight: tileHeight,
                          gap: tileGap,
                          viewportHeight: constraints.maxHeight,
                        ),
                      ),
                    );
                  }),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _CoverFlowColumn extends StatelessWidget {
  const _CoverFlowColumn({
    required this.columnAssets,
    required this.progress,
    required this.columnIndex,
    required this.tileWidth,
    required this.tileHeight,
    required this.gap,
    required this.viewportHeight,
  });

  final List<String> columnAssets;
  final double progress;
  final int columnIndex;
  final double tileWidth;
  final double tileHeight;
  final double gap;
  final double viewportHeight;

  int _wrapIndex(int value, int length) {
    final wrapped = value % length;
    return wrapped < 0 ? wrapped + length : wrapped;
  }

  @override
  Widget build(BuildContext context) {
    if (columnAssets.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = columnAssets.length;
    final itemExtent = tileHeight + gap;
    final isDownward = columnIndex.isOdd;
    final speed = 0.18 + (columnIndex % 4) * 0.035;
    final phase = (columnIndex * 0.31) % 1.0;
    final travelInItems = (((progress * speed) + phase) % 1.0) * itemCount;
    final wholeItems = travelInItems.floor();
    final partialOffset = (travelInItems - wholeItems) * itemExtent;
    final repeatedCount = (viewportHeight / itemExtent).ceil() + 5;
    final cacheWidth = (tileWidth * MediaQuery.devicePixelRatioOf(context))
        .round();
    final cacheHeight = (tileHeight * MediaQuery.devicePixelRatioOf(context))
        .round();

    return ClipRect(
      child: Transform.rotate(
        angle: columnIndex.isEven ? -0.008 : 0.008,
        child: Stack(
          clipBehavior: Clip.none,
          children: List.generate(repeatedCount, (index) {
            final assetIndex = isDownward
                ? _wrapIndex(wholeItems - index, itemCount)
                : _wrapIndex(wholeItems + index, itemCount);
            final asset = columnAssets[assetIndex];
            final top = isDownward
                ? ((index - 2) * itemExtent) + partialOffset
                : ((index - 1) * itemExtent) - partialOffset;

            return Positioned(
              top: top,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: Image.asset(
                  asset,
                  width: tileWidth,
                  height: tileHeight,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  cacheWidth: cacheWidth,
                  cacheHeight: cacheHeight,
                  color: Colors.white.withValues(alpha: 0.88),
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
