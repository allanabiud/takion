import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:takion/src/domain/entities.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';
import 'package:takion/src/presentation/features/issues/issue_list_tile.dart';
import 'package:takion/src/presentation/features/search/providers/barcode_scan_providers.dart';
import 'package:takion/src/presentation/features/search/widgets/bulk_scan_actions_sheet.dart';
import 'package:takion/src/presentation/features/search/widgets/issue_picker_sheet.dart';
import 'package:takion/src/presentation/features/search/widgets/manual_upc_dialog.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:takion/src/core/logging/app_logger.dart';
import 'package:takion/src/presentation/providers/providers.dart';

const _barcodeFormats = [
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.ean8,
  BarcodeFormat.ean13,
  BarcodeFormat.code128,
];

enum _ScanStatus { awaiting, scanning }

@RoutePage()
class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  late MobileScannerController _scannerController;
  Timer? _scanCooldown;
  bool _isScanningEnabled = true;
  bool _isLookingUp = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info('BarcodeScannerScreen initState');
    _scannerController = MobileScannerController(
      autoStart: false,
      formats: _barcodeFormats,
      detectionTimeoutMs: 250,
      cameraResolution: const Size(1920, 1080),
    );
    _scannerController
        .start()
        .then((_) {
          final running = _scannerController.value.isRunning;
          AppLogger.info(
            'BarcodeScannerScreen camera start(): isRunning=$running',
          );
          if (running) {
            _scannerController.setZoomScale(0.5);
          }
        })
        .catchError((e) {
          AppLogger.error(
            'BarcodeScannerScreen camera start() failed',
            error: e,
          );
        });
  }

  @override
  void dispose() {
    AppLogger.info('BarcodeScannerScreen dispose');
    _scanCooldown?.cancel();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (!_isScanningEnabled || _isLookingUp) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) continue;
      final isDigits = RegExp(r'^\d+$').hasMatch(value);
      if (!isDigits) continue;
      AppLogger.debug('BarcodeScannerScreen detected: $value');

      await HapticFeedback.heavyImpact();
      _isScanningEnabled = false;
      _scanCooldown?.cancel();
      _scanCooldown = Timer(const Duration(seconds: 2), () {
        _isScanningEnabled = true;
      });

      await _lookupUpc(value);
      return;
    }
  }

  Future<void> _lookupUpc(String upc, {bool exactFirst = false}) async {
    if (!mounted) return;
    setState(() => _isLookingUp = true);

    try {
      AppLogger.info('BarcodeScannerScreen lookup UPC: $upc');
      final repo = ref.read(catalogRepositoryProvider);

      IssueSearchPage result;
      if (exactFirst) {
        result = await repo.searchIssuesByUpc(upc);
        if (result.results.isEmpty) {
          result = await repo.searchIssuesByUpcPrefix(upc);
        }
      } else {
        result = await repo.searchIssuesByUpcPrefix(upc);
      }

      if (!mounted) return;

      if (result.results.isEmpty) {
        TakionAlerts.info(context, 'No issue found for barcode $upc');
        return;
      }

      final List<IssueList> issuesToAdd;
      if (result.results.length == 1) {
        issuesToAdd = result.results;
      } else {
        final picked = await showIssuePickerSheet(context, result.results);
        if (!mounted) return;
        if (picked == null || picked.isEmpty) return;
        issuesToAdd = picked;
      }

      final scannedIds = ref.read(scannedIssueIdsProvider);
      var added = 0;
      var skipped = 0;

      for (final issue in issuesToAdd) {
        if (issue.id == null) continue;
        if (scannedIds.any((s) => s.issueId == issue.id)) {
          skipped++;
          continue;
        }

        ref.read(scannedIssueIdsProvider.notifier).addIssue(issue);
        added++;
      }

      if (!mounted) return;
      if (added > 0) {
        final msg = skipped > 0
            ? 'Added $added issue${added > 1 ? 's' : ''} ($skipped already in list)'
            : 'Added $added issue${added > 1 ? 's' : ''}';
        TakionAlerts.success(context, msg);
      } else if (skipped > 0) {
        TakionAlerts.info(
          context,
          'All $skipped issue${skipped > 1 ? 's' : ''} already in list',
        );
      }
    } catch (e) {
      if (!mounted) return;
      TakionAlerts.safeError(
        context,
        e,
        userMessage: 'Failed to look up barcode',
      );
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  String _issueTitle(IssueList issue) {
    final name = issue.name;
    final number = issue.number;
    if (number.isEmpty || name.contains('#$number')) return name;
    return '$name #$number';
  }

  Future<void> _showManualUpcDialog() async {
    final upc = await showManualUpcDialog(context);
    if (upc != null && mounted) {
      await _lookupUpc(upc, exactFirst: true);
    }
  }

  Future<void> _showBulkActionsSheet() async {
    final scannedIssues = ref.read(scannedIssueIdsProvider);
    if (scannedIssues.isEmpty) {
      TakionAlerts.info(context, 'No scanned issues');
      return;
    }
    final issueSeriesIds = <int, int>{};
    final issueReleaseDates = <int, DateTime>{};
    for (final s in scannedIssues) {
      final sid = s.issue.series?.id;
      if (sid != null && sid > 0) issueSeriesIds[s.issueId] = sid;
      final release = s.issue.storeDate ?? s.issue.coverDate;
      if (release != null) issueReleaseDates[s.issueId] = release;
    }
    await showBulkScanActionsSheet(
      context,
      ref,
      issueIds: scannedIssues.map((s) => s.issueId).toList(),
      issueSeriesIds: issueSeriesIds,
      issueReleaseDates: issueReleaseDates,
    );
  }

  void _clearAll() {
    ref.read(scannedIssueIdsProvider.notifier).clearAll();
    TakionAlerts.info(context, 'List cleared');
  }

  @override
  Widget build(BuildContext context) {
    final scannedIssues = ref.watch(scannedIssueIdsProvider);
    final theme = Theme.of(context);
    final scanStatus = _isLookingUp
        ? _ScanStatus.scanning
        : _ScanStatus.awaiting;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Barcode Scanner'),
        actions: [
          IconButton(
            tooltip: 'Enter UPC manually',
            icon: const Icon(Icons.keyboard),
            onPressed: _showManualUpcDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: MobileScanner(
              controller: _scannerController,
              onDetect: _onBarcodeDetected,
              overlayBuilder: (context, constraints) =>
                  _ScannerOverlay(isLookingUp: _isLookingUp),
              errorBuilder: (context, error, child) {
                AppLogger.error(
                  'BarcodeScannerScreen error: ${error.errorCode} '
                  '${error.errorDetails?.message}',
                );
                return Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.errorCode ==
                                  MobileScannerErrorCode.permissionDenied
                              ? 'Camera permission denied. Please grant camera permission in your system settings.'
                              : 'Scanner error: ${error.errorDetails?.message ?? error.errorCode.name}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: scanStatus == _ScanStatus.scanning
                      ? theme.colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        )
                      : theme.colorScheme.surfaceContainer,
                  child: Row(
                    children: [
                      if (scanStatus == _ScanStatus.scanning) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Scanning',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          LucideIcons.scanBarcode,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Awaiting Scan...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (scannedIssues.isNotEmpty)
                        Text(
                          '${scannedIssues.length} issue${scannedIssues.length > 1 ? 's' : ''}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: scannedIssues.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.scanBarcode,
                                size: 48,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Scan barcodes to add issues',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Swipe left to remove from list',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: scannedIssues.length,
                          itemBuilder: (context, index) {
                            final state = scannedIssues[index];
                            return Dismissible(
                              key: ValueKey(state.issueId),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                color: theme.colorScheme.errorContainer,
                                child: Icon(
                                  Icons.delete_outline,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                              onDismissed: (_) {
                                ref
                                    .read(scannedIssueIdsProvider.notifier)
                                    .removeIssue(state.issueId);
                                TakionAlerts.info(
                                  context,
                                  'Removed: ${_issueTitle(state.issue)}',
                                );
                              },
                              child: IssueListTile(
                                issue: state.issue,
                                isFirst: index == 0,
                                isLast: index == scannedIssues.length - 1,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            TextButton.icon(
              onPressed: scannedIssues.isEmpty ? null : _clearAll,
              icon: const Icon(Icons.clear_all),
              label: const Text('CLEAR'),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: scannedIssues.isEmpty ? null : _showBulkActionsSheet,
              icon: const Icon(Icons.more_horiz),
              label: Text(
                scannedIssues.isEmpty
                    ? 'BULK ACTIONS'
                    : 'BULK ACTIONS (${scannedIssues.length})',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final bool isLookingUp;
  const _ScannerOverlay({required this.isLookingUp});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bracketColor = isLookingUp ? theme.colorScheme.primary : Colors.white;
    return Stack(
      children: [
        ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
        Center(
          child: SizedBox(
            width: 250,
            height: 120,
            child: Stack(
              children: [
                _CornerBracket(
                  top: 0,
                  left: 0,
                  border: Border(
                    top: BorderSide(color: bracketColor, width: 3),
                    left: BorderSide(color: bracketColor, width: 3),
                  ),
                ),
                _CornerBracket(
                  top: 0,
                  right: 0,
                  border: Border(
                    top: BorderSide(color: bracketColor, width: 3),
                    right: BorderSide(color: bracketColor, width: 3),
                  ),
                ),
                _CornerBracket(
                  bottom: 0,
                  left: 0,
                  border: Border(
                    bottom: BorderSide(color: bracketColor, width: 3),
                    left: BorderSide(color: bracketColor, width: 3),
                  ),
                ),
                _CornerBracket(
                  bottom: 0,
                  right: 0,
                  border: Border(
                    bottom: BorderSide(color: bracketColor, width: 3),
                    right: BorderSide(color: bracketColor, width: 3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CornerBracket extends StatelessWidget {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final Border border;

  const _CornerBracket({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(border: border),
      ),
    );
  }
}
