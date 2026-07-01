import 'package:flutter/material.dart';
import 'package:takion/src/presentation/features/profile/widgets/avatar_image_provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
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
    final avatarImage = avatarImageProvider(avatarUrl);
    final backdropImage = avatarImageProvider(backdropPath);
    final pageBackground = Theme.of(context).scaffoldBackgroundColor;
    return Stack(
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
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.4),
                Colors.transparent,
                pageBackground,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Opacity(
                  opacity: 1 - titleOpacity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                      const SizedBox(width: 14),
                      avatarImage != null
                          ? CircleAvatar(
                              radius: 52,
                              backgroundImage: avatarImage,
                            )
                          : const Icon(Icons.account_circle, size: 104),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
