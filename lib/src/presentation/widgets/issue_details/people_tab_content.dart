import 'package:flutter/material.dart';
import 'package:takion/src/domain/entities/issue_details.dart';
import 'package:takion/src/presentation/widgets/people_info_list_tile.dart';

class IssueCreatorsTabContent extends StatelessWidget {
  const IssueCreatorsTabContent({super.key, required this.issue});

  final IssueDetails issue;

  String _creatorTitle(IssueDetailsCredit credit) {
    final creator = credit.creator?.trim();
    if (creator != null && creator.isNotEmpty) {
      return creator;
    }
    return 'Unknown Creator';
  }

  String? _creatorSubtitle(IssueDetailsCredit credit) {
    final roles = credit.roles
        .map((role) => role.name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (roles.isEmpty) {
      return null;
    }

    return roles.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final credits = issue.credits;

    if (credits.isEmpty) {
      return Text(
        'No creators available.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: List.generate(credits.length, (index) {
        final credit = credits[index];
        return PeopleInfoListTile(
          title: _creatorTitle(credit),
          subtitle: _creatorSubtitle(credit),
          isFirst: index == 0,
          isLast: index == credits.length - 1,
        );
      }),
    );
  }
}

class IssueCharactersTabContent extends StatelessWidget {
  const IssueCharactersTabContent({super.key, required this.issue});

  final IssueDetails issue;

  @override
  Widget build(BuildContext context) {
    final characters = issue.characters;

    if (characters.isEmpty) {
      return Text(
        'No characters available.',
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      children: List.generate(characters.length, (index) {
        final characterName = characters[index].name.trim();
        return PeopleInfoListTile(
          title: characterName.isNotEmpty ? characterName : 'Unknown Character',
          isFirst: index == 0,
          isLast: index == characters.length - 1,
        );
      }),
    );
  }
}
