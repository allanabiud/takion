import 'package:flutter/material.dart';
import 'package:takion/src/presentation/features/profile/providers/profile_insights_provider.dart';
import 'package:takion/src/presentation/features/profile/widgets/top_entity_tile.dart';

class TopCharactersScreen extends StatelessWidget {
  final List<EntityStat> characters;

  const TopCharactersScreen({super.key, required this.characters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Characters')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: characters.length,
        itemBuilder: (context, index) {
          return TopEntityTile(
            index: index,
            entity: characters[index],
            isCharacter: true,
            isLast: index == characters.length - 1,
          );
        },
      ),
    );
  }
}
