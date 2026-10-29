import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // The clip's background is baked to exactly AppColors.background, so on a
  // flat background of that colour the logo reads as transparent on every
  // platform (mobile textures and the web <video> element alike).
  static const _videoAsset = 'assets/videos/amour_splash.mp4';

  late AnimationController _textController;
  late final VideoPlayerController _video;
  bool _videoReady = false;
  bool _videoFailed = false;
  bool _started = false;

  // Bottom Text 1 Animations ("Searching for love?")
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  // Bottom Text 2 Animations ("Just Amour.")
  late Animation<double> _catchphraseFadeAnimation;
  late Animation<double> _catchphraseScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Text animations (synced with the 4-second logo video)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    // Subtitle animates in around 3.0s - 4.2s
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeIn),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Catchphrase animates in around 3.75s - 5.0s
    _catchphraseFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
    );

    _catchphraseScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _video = VideoPlayerController.asset(
      _videoAsset,
      // Don't pause the user's music just to show a splash.
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      await _video.initialize().timeout(const Duration(seconds: 3));
      // Browsers only allow autoplay for muted media.
      await _video.setVolume(0);
      if (!mounted) return;
      setState(() => _videoReady = true);
      await _video.play();
    } catch (_) {
      if (mounted) setState(() => _videoFailed = true);
    }
    _start();
  }

  // Timings start once the video is actually playing (or has failed), so a
  // slow first load on web doesn't cut the logo animation short.
  void _start() {
    if (_started || !mounted) return;
    _started = true;
    _textController.forward();
    _navigateToNext();
  }

  void _navigateToNext() async {
    // Wait for the logo video and text animations to finish
    await Future.delayed(const Duration(milliseconds: 6500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        // WelcomeScreen paints its own full-bleed background and centres its content.
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _video.dispose();
    super.dispose();
  }

  Widget _buildLogo(double side) {
    if (_videoFailed) {
      return Image.asset(
        'assets/images/amour_intro.webp',
        width: side * 0.7,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        gaplessPlayback: true,
      );
    }
    // Before the first frame the box is just background colour, which is
    // what the video's first frame shows anyway.
    return SizedBox.square(
      dimension: side,
      child: _videoReady ? VideoPlayer(_video) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          // Square clip: ~80% of the short side on phones, capped so it stays
          // a focal mark on tablets/desktop and leaves room for the taglines
          // in landscape.
          final side = (constraints.biggest.shortestSide * 0.8)
              .clamp(0.0, constraints.maxHeight * 0.55)
              .clamp(160.0, 440.0);
          // Scaffold hands the body loose constraints; force full width so the
          // column (and the video) centre horizontally instead of hugging the left.
          return SizedBox(
            width: double.infinity,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              _buildLogo(side),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _subtitleFadeAnimation,
                      child: SlideTransition(
                        position: _subtitleSlideAnimation,
                        child: Text(
                          'Searching for love?',
                          style: AppText.bodyMedium.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FadeTransition(
                      opacity: _catchphraseFadeAnimation,
                      child: ScaleTransition(
                        scale: _catchphraseScaleAnimation,
                        child: Text(
                          'Just Amour.',
                          style: AppText.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          );
        }),
      ),
    );
  }
}
