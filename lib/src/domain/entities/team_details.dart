import 'package:takion/src/domain/entities/universe_details.dart';

class TeamCreatorRef {
  const TeamCreatorRef({required this.id, required this.name, this.modified});

  final int id;
  final String name;
  final DateTime? modified;
}

class TeamDetails {
  const TeamDetails({
    required this.id,
    required this.name,
    this.desc,
    this.image,
    this.creators = const [],
    this.universes = const [],
    this.cvId,
    this.gcdId,
    this.resourceUrl,
    this.modified,
  });

  final int id;
  final String name;
  final String? desc;
  final String? image;
  final List<TeamCreatorRef> creators;
  final List<UniverseNamedRef> universes;
  final int? cvId;
  final int? gcdId;
  final String? resourceUrl;
  final DateTime? modified;
}
