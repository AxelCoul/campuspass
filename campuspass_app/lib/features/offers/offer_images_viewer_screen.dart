import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/theme/app_text_styles.dart';

/// Viewer plein écran pour les images d’une offre.
/// Permet de scroller horizontalement si plusieurs images.
class OfferImagesViewerScreen extends StatefulWidget {
  const OfferImagesViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.heroTag,
  });

  final List<String> imageUrls;
  final int initialIndex;
  final String? heroTag;

  @override
  State<OfferImagesViewerScreen> createState() =>
      _OfferImagesViewerScreenState();
}

class _OfferImagesViewerScreenState extends State<OfferImagesViewerScreen> {
  late final PageController _controller;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    final safeIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageIndex = safeIndex;
    _controller = PageController(initialPage: safeIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.65),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Images (${_pageIndex + 1}/${widget.imageUrls.length})',
          style: AppTextStyles.body(context).copyWith(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _controller,
          onPageChanged: (i) => setState(() => _pageIndex = i),
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            final url = widget.imageUrls[index];
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Center(
                child: Image.network(
                  resolveImageUrl(url),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

