import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final maxIndex = widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

                if (index == 0 && widget.heroTag != null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Hero(tag: widget.heroTag!, child: image),
                  );
                }

                return Padding(padding: const EdgeInsets.all(16), child: image);
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 10),
                  child: Text(
                    _captionForIndex(_currentIndex) ??
                        _labelForIndex(_currentIndex),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.imageUrls.length, (index) {
                    final isSelected = _currentIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
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
        ],
      ),
    );
  }
}
