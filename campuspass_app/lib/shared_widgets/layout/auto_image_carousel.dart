import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:video_player/video_player.dart';

class CarouselItem {
  const CarouselItem({
    this.imageUrl,
    this.videoUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String? imageUrl;
  final String? videoUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class AutoImageCarousel extends StatefulWidget {
  const AutoImageCarousel({
    super.key,
    required this.items,
    this.height = 190,
    this.borderRadius = 16,
    this.interval = const Duration(seconds: 4),
  });

  final List<CarouselItem> items;
  final double height;
  final double borderRadius;
  final Duration interval;

  @override
  State<AutoImageCarousel> createState() => _AutoImageCarouselState();
}

class _AutoImageCarouselState extends State<AutoImageCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;
  List<VideoPlayerController?> _videoControllers = [];
  List<bool> _videoInitialized = [];
  List<bool> _videoFailed = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _setupVideoControllers();
    _startTimerIfNeeded();
  }

  void _disposeVideoControllers() {
    for (final c in _videoControllers) {
      c?.dispose();
    }
    _videoControllers = [];
    _videoInitialized = [];
    _videoFailed = [];
  }

  void _setupVideoControllers() {
    _disposeVideoControllers();

    _videoControllers = List<VideoPlayerController?>.filled(widget.items.length, null);
    _videoInitialized = List<bool>.filled(widget.items.length, false);
    _videoFailed = List<bool>.filled(widget.items.length, false);

    for (var i = 0; i < widget.items.length; i++) {
      final videoUrl = widget.items[i].videoUrl;
      if (videoUrl == null || videoUrl.isEmpty) continue;

      final uri = Uri.tryParse(videoUrl);
      if (uri == null) continue;

      final controller = VideoPlayerController.networkUrl(uri);
      _videoControllers[i] = controller;

      controller.setLooping(true);
      controller.setVolume(0.0); // mute: le hero est discret

      controller.initialize().then((_) {
        if (!mounted) return;
        _videoInitialized[i] = true;
        _videoFailed[i] = false;
        if (i == _currentIndex) controller.play();
        setState(() {});
      }).catchError((_) {
        // Fallback : on reste sur le placeholder.
        if (!mounted) return;
        _videoFailed[i] = true;
        setState(() {});
      });
    }
  }

  void _startTimerIfNeeded() {
    if (widget.items.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.interval, (timer) {
      if (!mounted) return;
      final next = (_currentIndex + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void didUpdateWidget(covariant AutoImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final videosChanged = oldWidget.items
        .map((e) => e.videoUrl ?? '')
        .toList()
        .join('|') !=
        widget.items.map((e) => e.videoUrl ?? '').toList().join('|');

    if (oldWidget.items.length != widget.items.length || videosChanged) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
      _disposeVideoControllers();
      _setupVideoControllers();
      _startTimerIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeVideoControllers();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    for (var i = 0; i < _videoControllers.length; i++) {
      final c = _videoControllers[i];
      if (c == null) continue;
      if (!_videoInitialized[i]) continue;
      if (i == index) {
        c.play();
      } else {
        c.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: widget.height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return InkWell(
                  onTap: item.onTap,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.videoUrl != null && item.videoUrl!.isNotEmpty)
                        Builder(
                          builder: (_) {
                            final controller = _videoControllers[index];
                            if (controller == null) {
                              return Container(
                                color: AppColors.secondary.withOpacity(0.08),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textMuted,
                                ),
                              );
                            }

                            if (!_videoInitialized[index] && !_videoFailed[index]) {
                              return Container(
                                color: AppColors.secondary.withOpacity(0.08),
                                alignment: Alignment.center,
                                child: const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }

                            if (!_videoInitialized[index] && _videoFailed[index]) {
                              return Container(
                                color: AppColors.secondary.withOpacity(0.08),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textMuted,
                                ),
                              );
                            }
                            return FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox.expand(
                                child: VideoPlayer(controller),
                              ),
                            );
                          },
                        )
                      else
                        Image.network(
                          item.imageUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.secondary.withOpacity(0.08),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.05),
                              Colors.black.withOpacity(0.45),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTextStyles.h2(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.subtitle,
                              style: AppTextStyles.body(context).copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(widget.items.length, (index) {
            final active = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

