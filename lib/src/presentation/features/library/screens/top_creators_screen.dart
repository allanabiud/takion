import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";
import "package:takion/src/presentation/features/library/providers/library_stats_models.dart";
import "package:takion/src/presentation/features/library/widgets/top_entity_tile.dart";

@RoutePage()
class TopCreatorsScreen extends StatelessWidget {
  final List<EntityStat> creators;

  const TopCreatorsScreen({super.key, required this.creators});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top Creators")),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: creators.length,
        itemBuilder: (context, index) {
          return TopEntityTile(
            index: index,
            entity: creators[index],
            isCharacter: false,
            isLast: index == creators.length - 1,
          );
        },
      ),
    );
  }
}
