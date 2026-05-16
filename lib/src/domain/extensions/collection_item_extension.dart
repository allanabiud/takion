import 'package:takion/src/domain/entities/collection_item.dart';
import 'package:takion/src/domain/entities/issue_list.dart';

extension CollectionItemToIssueList on CollectionItem {
  IssueList toIssueList() {
    final issue = this.issue;
    return IssueList(
      id: issue?.id,
      name: issue?.series?.name ?? 'Unknown',
      number: issue?.number ?? '',
      series: null,
      coverDate: issue?.coverDate,
      storeDate: issue?.storeDate,
      image: issue?.image,
      modified: issue?.modified,
    );
  }
}
