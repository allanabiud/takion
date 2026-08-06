import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:takion/src/presentation/shared/alerts/takion_alerts.dart';

@RoutePage()
class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({
    super.key,
    required this.imageUrl,
    this.title,
    this.heroTag,
  });

  final String imageUrl;
  final String? title;
  final String? heroTag;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final Dio _dio = Dio();
  bool _isDownloading = false;

  @override
  void dispose() {
    _dio.close(force: true);
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
    final title = widget.title ?? 'image';
    final titlePart = _safeFileComponent(title);
    final extension = _fileExtensionFromUrl(widget.imageUrl);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final base = [
      if (titlePart.isNotEmpty) titlePart,
      timestamp.toString(),
    ].join('_');
    return '$base.$extension';
  }

  Future<void> _downloadImage() async {
    setState(() => _isDownloading = true);

    try {
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

      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = _downloadFileName();
      final filePath = '${tempDir.path}/$fileName';

      await _dio.download(widget.imageUrl, filePath);

      await Gal.putImage(filePath, album: 'Takion');

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      if (!mounted) return;
      TakionAlerts.success(context, 'Image Saved');
    } catch (e) {
      if (!mounted) return;
      TakionAlerts.safeError(context, e, userMessage: 'Failed to save image');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.contain,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.title != null
            ? Text(
                widget.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Download image',
            onPressed: _isDownloading ? null : _downloadImage,
            icon: _isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: Center(
        child: widget.heroTag != null
            ? Hero(tag: widget.heroTag!, child: image)
            : image,
      ),
    );
  }
}
