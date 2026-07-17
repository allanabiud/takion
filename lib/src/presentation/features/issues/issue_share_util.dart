import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:takion/src/domain/entities/entities.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

String issueDisplayTitle(IssueDetails issue) {
  final seriesName = issue.series?.name.trim();
  final issueNumber = issue.number.trim();
  final storyTitle = issue.title?.trim();

  String baseName;
  if (seriesName != null && seriesName.isNotEmpty && issueNumber.isNotEmpty) {
    baseName = '$seriesName #$issueNumber';
  } else if (issue.names.isNotEmpty && issue.names.first.trim().isNotEmpty) {
    baseName = issue.names.first.trim();
  } else {
    baseName = issueNumber.isNotEmpty ? 'Issue #$issueNumber' : 'Issue';
  }

  if (storyTitle != null && storyTitle.isNotEmpty) {
    return '$baseName: $storyTitle';
  }

  return baseName;
}

Future<void> shareIssueResourceUrl(BuildContext context, IssueDetails issue) async {
  final resourceUrl = issue.resourceUrl?.trim();
  if (resourceUrl == null || resourceUrl.isEmpty) {
    TakionAlerts.noShareUrl(context, 'issue');
    return;
  }

  final uri = Uri.tryParse(resourceUrl);
  if (uri == null) {
    TakionAlerts.noShareUrl(context, 'issue');
    return;
  }

  await SharePlus.instance.share(
    ShareParams(text: uri.toString(), subject: issueDisplayTitle(issue)),
  );
}
