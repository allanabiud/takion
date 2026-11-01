class OutboxActionResult {
  const OutboxActionResult({this.remoteId, this.remoteModified});

  final int? remoteId;
  final String? remoteModified;
}
