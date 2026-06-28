import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:takion/src/presentation/common/takion_alerts.dart';

@RoutePage()
class IssueCoverGalleryScreen extends StatefulWidget {
  const IssueCoverGalleryScreen({
    super.key,
    required this.imageUrls,
    this.imageLabels,
    this.imageCaptions,
    this.initialIndex = 0,
    this.title,
    this.heroTag,
  });

  final List<String> imageUrls;
  final List<String>? imageLabels;
  final List<String>? imageCaptions;
  final int initialIndex;
  final String? title;
  final String? heroTag;

  @override
  State<IssueCoverGalleryScreen> createState() =>
      _IssueCoverGalleryScreenState();
}

class _IssueCoverGalleryScreenState extends State<IssueCoverGalleryScreen> {
  late final PageController _pageController;
  final Dio _dio = Dio();
  late int _currentIndex;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    final maxIndex = widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _dio.close(force: true);
    _pageController.dispose();
    super.dispose();
  }

  String _safeFileComponent(String value) {
    final normalized = value.trim().toLowerCase();
    final safe = normalized.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    return safe.replaceAll(RegExp(r'^_+|_+$'), '');
  }

  String _fileExtensionFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final path = uri?.path ?? '';
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex < 0 || dotIndex == path.length - 1) return 'jpg';
    final ext = path.substring(dotIndex + 1).toLowerCase();
    if (ext.length > 5) return 'jpg';
    return ext;
  }

  String _downloadFileName() {
    final label = _labelForIndex(_currentIndex);
    final title = widget.title ?? 'issue_cover';
    final titlePart = _safeFileComponent(title);
    final labelPart = _safeFileComponent(label);
    final extension = _fileExtensionFromUrl(widget.imageUrls[_currentIndex]);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final base = [
      if (titlePart.isNotEmpty) titlePart,
      if (labelPart.isNotEmpty) labelPart,
      timestamp.toString(),
    ].join('_');
    return '$base.$extension';
  }

  Future<void> _downloadCurrentCover() async {
    setState(() => _isDownloading = true);

    try {
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (status.isPermanentlyDenied) {
          if (!mounted) return;
          TakionAlerts.error(
            context,
            'Storage permission is required to save images. Please enable it in settings.',
          );
          openAppSettings();
          return;
        }
      }

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final url = widget.imageUrls[_currentIndex];
      final tempDir = await getTemporaryDirectory();
      final fileName = _downloadFileName();
      final filePath = '${tempDir.path}/$fileName';

      await _dio.download(url, filePath);

      await Gal.putImage(filePath, album: 'Takion');

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      if (!mounted) return;
      TakionAlerts.success(context, 'Cover saved to gallery.');
    } catch (e) {
      if (!mounted) return;
      TakionAlerts.error(context, 'Failed to save cover: $e');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  String _labelForIndex(int index) {
    final labels = widget.imageLabels;
    if (labels != null &&
        index < labels.length &&
        labels[index].trim().isNotEmpty) {
      return labels[index].trim();
    }
    if (index == 0) return 'Main Cover';
    return 'Variant $index';
  }

  String? _captionForIndex(int index) {
    final captions = widget.imageCaptions;
    if (captions != null && index < captions.length) {
      final caption = captions[index].trim();
      if (caption.isNotEmpty) return caption;
    }
    return null;
  }

  String? _priceFromCaption(int index) {
    final caption = _captionForIndex(index);
    if (caption == null) return null;
    final parts = caption.split('•');
    if (parts.length < 2) return null;
    final trailing = parts.last.trim();
    if (!trailing.startsWith('\$') || trailing.length <= 1) return null;
    return trailing;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = _labelForIndex(_currentIndex);
    final price = _priceFromCaption(_currentIndex);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title ?? 'Covers',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Download current cover',
            onPressed: _isDownloading ? null : _downloadCurrentCover,
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final image = CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.contain,
                );

                final zoomable = InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: image,
                );

                if (index == 0 && widget.heroTag != null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Hero(tag: widget.heroTag!, child: zoomable),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: zoomable,
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        price,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(widget.imageUrls.length, (index) {
                      final isSelected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: isSelected ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
