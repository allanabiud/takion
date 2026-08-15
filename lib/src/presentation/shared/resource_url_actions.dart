import "package:flutter/material.dart";
import "package:share_plus/share_plus.dart";
import "package:takion/src/presentation/shared/alerts/takion_alerts.dart";
import "package:url_launcher/url_launcher.dart";

/// Shared share / open-in-browser actions for Metron resource URLs.
///
/// Implementers supply the URL + display label + share subject for their
/// specific entity type, then delegate to [shareResourceUrl] /
/// [openResourceUrlInBrowser] from their detail screen state.
mixin ResourceUrlActions<T> {
  String? resourceUrlOf(T details);
  String get resourceLabel;
  String shareSubjectOf(T details);

  Uri? resourceUri(T details) {
    final resourceUrl = resourceUrlOf(details)?.trim();
    if (resourceUrl == null || resourceUrl.isEmpty) return null;
    return Uri.tryParse(resourceUrl);
  }

  Future<void> shareResourceUrl(BuildContext context, T details) async {
    final uri = resourceUri(details);
    if (uri == null) {
      TakionAlerts.noShareUrl(context, resourceLabel);
      return;
    }
    await SharePlus.instance.share(
      ShareParams(text: uri.toString(), subject: shareSubjectOf(details)),
    );
  }

  Future<void> openResourceUrlInBrowser(BuildContext context, T details) async {
    final uri = resourceUri(details);
    if (uri == null) {
      TakionAlerts.noBrowserUrl(context, resourceLabel);
      return;
    }
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      TakionAlerts.couldNotOpenInBrowser(context, resourceLabel);
    }
  }
}
