import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/core/router/app_router.gr.dart';
import 'package:takion/src/presentation/providers/search_state_provider.dart';

@RoutePage()
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: kSearchBarHeroTag,
              child: Material(
                color: Colors.transparent,
                child: SearchBar(
                  hintText: 'Search comics...',
                  leading: const Icon(Icons.search, size: 24),
                  onTap: () {
                    context.pushRoute(const SearchRoute());
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
