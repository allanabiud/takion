import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/core/storage/hive_service.dart';
import 'package:takion/src/presentation/widgets/floating_icons_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@RoutePage()
class AllDoneScreen extends ConsumerStatefulWidget {
  const AllDoneScreen({super.key});

  @override
  ConsumerState<AllDoneScreen> createState() => _AllDoneScreenState();
}

class _AllDoneScreenState extends ConsumerState<AllDoneScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishSetup() async {
    final hiveService = ref.read(hiveServiceProvider);
    final settingsBox = await hiveService.openBox('settings_box');
    await settingsBox.put('has_seen_onboarding', true);

    if (!mounted || !context.mounted) return;
    context.router.replaceAll([const MainRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const FloatingIconsBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _scale,
                            child: Icon(
                              LucideIcons.badgeCheck,
                              size: 120,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'All Done!',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You\'re all set to start organizing your comic collection.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _finishSetup,
                      child: const Text('Finish Setup'),
                    ),                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
