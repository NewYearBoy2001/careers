import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:careers/bloc/bottom_ads/bottom_ads_bloc.dart';
import 'package:careers/bloc/bottom_ads/bottom_ads_event.dart';
import 'package:careers/bloc/bottom_ads/bottom_ads_state.dart';
import 'package:careers/data/models/bottom_ad_model.dart';
import 'package:careers/constants/app_colors.dart';

class BottomAdBanner extends StatefulWidget {
  const BottomAdBanner({super.key});

  @override
  State<BottomAdBanner> createState() => _BottomAdBannerState();
}

class _BottomAdBannerState extends State<BottomAdBanner> {
  bool _showAd = true;
  Timer? _adTimer;

  @override
  void dispose() {
    _adTimer?.cancel();
    super.dispose();
  }

  void _hideAd() {
    setState(() => _showAd = false);
    _adTimer?.cancel();
    _adTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted) return;
      context.read<BottomAdsBloc>().add(FetchBottomAds());
      setState(() => _showAd = true);
    });
  }

  Future<void> _showPoster(BottomAdModel ad) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => _AdPosterDialog(ad: ad),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_showAd) return const SizedBox.shrink();

    return BlocBuilder<BottomAdsBloc, BottomAdsState>(
      builder: (context, state) {
        if (state is BottomAdsLoading) {
          return Container(
            height: 100,
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
        }

        if (state is! BottomAdsLoaded || state.ads.isEmpty) {
          return const SizedBox.shrink();
        }

        return _AdCarousel(
          ads: state.ads,
          onClose: _hideAd,
          onTapAd: _showPoster,
        );
      },
    );
  }
}

class _AdCarousel extends StatefulWidget {
  final List<BottomAdModel> ads;
  final VoidCallback onClose;
  final void Function(BottomAdModel) onTapAd;

  const _AdCarousel({
    required this.ads,
    required this.onClose,
    required this.onTapAd,
  });

  @override
  State<_AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<_AdCarousel> {
  int _currentPage = 0;
  late final PageController _pageController;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.ads.length > 1) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!_pageController.hasClients) return;
        final next = (_currentPage + 1) % widget.ads.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ads = widget.ads;

    return Container(
      height: 100,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: ads.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => _buildAdItem(ads[index]),
            ),
            if (ads.length > 1)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    ads.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentPage == index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.white
                            : Colors.white54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: widget.onClose,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdItem(BottomAdModel ad) {
    return GestureDetector(
      onTap: () => widget.onTapAd(ad),
      child: Image.network(
        ad.image,
        fit: BoxFit.fill,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: AppColors.background,
            alignment: Alignment.center,
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stack) => Container(
          color: AppColors.background,
          alignment: Alignment.center,
          child: Icon(
            Icons.image_not_supported_rounded,
            color: AppColors.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _AdPosterDialog extends StatelessWidget {
  final BottomAdModel ad;
  const _AdPosterDialog({required this.ad});

  Future<void> _openLink(BuildContext context) async {
    final uri = Uri.tryParse(ad.link!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxWidth = size.width * 0.88;
    final maxImageHeight = size.height * 0.32;
    final hasLink = ad.link != null && ad.link!.isNotEmpty;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _ResponsiveNetworkImage(
                    url: ad.poster,
                    maxWidth: maxWidth,
                    maxHeight: maxImageHeight,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.pop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (hasLink) ...[
              const SizedBox(height: 18),
              const Text(
                'Open this link?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You will be redirected to an external website.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => _openLink(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 13),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Open link',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.open_in_new_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

/// Sizes itself to the network image's real aspect ratio, capped to
/// [maxWidth] x [maxHeight], so any poster ratio (square, portrait,
/// landscape, panoramic) renders with no letterboxing or distortion.
class _ResponsiveNetworkImage extends StatefulWidget {
  final String url;
  final double maxWidth;
  final double maxHeight;

  const _ResponsiveNetworkImage({
    required this.url,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  State<_ResponsiveNetworkImage> createState() => _ResponsiveNetworkImageState();
}

class _ResponsiveNetworkImageState extends State<_ResponsiveNetworkImage> {
  double? _aspectRatio;
  bool _errored = false;
  late final ImageStream _stream;
  late final ImageStreamListener _listener;

  @override
  void initState() {
    super.initState();
    _stream = Image.network(widget.url).image.resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
          (info, _) {
        if (!mounted) return;
        setState(() => _aspectRatio = info.image.width / info.image.height);
      },
      onError: (error, stackTrace) {
        if (!mounted) return;
        setState(() => _errored = true);
      },
    );
    _stream.addListener(_listener);
  }

  @override
  void dispose() {
    _stream.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errored) {
      return Container(
        width: widget.maxWidth,
        height: 220,
        color: AppColors.background,
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_rounded,
            color: AppColors.textSecondary, size: 32),
      );
    }

    if (_aspectRatio == null) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: widget.maxWidth,
          height: 120,
          color: Colors.white,
        ),
      );
    }

    double width = widget.maxWidth;
    double height = width / _aspectRatio!;
    if (height > widget.maxHeight) {
      height = widget.maxHeight;
      width = height * _aspectRatio!;
    }

    return Image.network(
      widget.url,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }
}