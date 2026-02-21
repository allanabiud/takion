import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:takion/src/presentation/widgets/action_card.dart';

@RoutePage()
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ActionCard(
                  icon: Icons.auto_stories_outlined,
                  value: '1.2k',
                  label: 'Issues',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                ActionCard(
                  icon: Icons.library_books_outlined,
                  value: '42',
                  label: 'Series',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                ActionCard(
                  icon: Icons.star_outline,
                  value: '15',
                  label: 'Favorites',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Center(child: Text('More library content coming soon...')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
