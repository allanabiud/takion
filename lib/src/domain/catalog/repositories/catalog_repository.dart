import "arc_repository.dart";
import "character_repository.dart";
import "creator_repository.dart";
import "imprint_repository.dart";
import "issue_repository.dart";
import "metron_reading_list_repository.dart";
import "publisher_repository.dart";
import "series_repository.dart";
import "team_repository.dart";
import "universe_repository.dart";

abstract class CatalogRepository
    implements
        IssueRepository,
        SeriesRepository,
        ArcRepository,
        CharacterRepository,
        CreatorRepository,
        PublisherRepository,
        ImprintRepository,
        TeamRepository,
        UniverseRepository,
        MetronReadingListRepository {}
