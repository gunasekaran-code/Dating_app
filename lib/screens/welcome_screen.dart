import 'package:flutter/material.dart';
import '../l10n/match_text.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/glass_card.dart';
import 'auth/create_account_screen.dart';
import 'auth/sign_in_screen.dart';
import 'language_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Narrower than AppLayout.maxContentWidth: two full-width pill buttons
  // look stretched any wider on desktop.
  static const _maxContentWidth = 480.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    // Spaced out on tall screens; scrolls when a small phone or a longer language needs more room.
    return Scaffold(
      backgroundColor: AppColors.background, 
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3), // Matches the splash screen position
            radius: 0.8,
            colors: [
              Color.fromARGB(255, 255, 223, 230), // Soft pink/rose core
              AppColors.background,   // Fades to background at the edges
            ],
            stops: [0.2, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              // The gradient stays full-bleed; content is a centred column so the
              // logo and card sit mid-screen on tablets and desktop web.
              child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: _maxContentWidth,
                  minHeight: box.maxHeight - AppSpacing.xl * 2,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, 
                    children: [
                      const Align(alignment: Alignment.centerRight, child: LanguagePill()),
                      const Spacer(),
                      Center(
                        child: Image.asset(
                          'assets/images/logo/logo_mark.png',
                          height: 40,
                          filterQuality: FilterQuality.high,
                          semanticLabel: 'Amour',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Amour', 
                        style: AppText.displayLarge.copyWith(color: AppColors.primary), 
                        textAlign: TextAlign.center
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l.appTagline,
                        style: AppText.bodySmall.copyWith(color: AppColors.muted), 
                        textAlign: TextAlign.center
                      ),
                      const Spacer(),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch, 
                          children: [
                            Text(l.welcomeTitle, style: AppText.h3, textAlign: TextAlign.center),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l.welcomeSubtitle,
                              style: AppText.bodyMedium.copyWith(color: AppColors.muted), 
                              textAlign: TextAlign.center
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppButton(
                              l.createAccount, 
                              onPressed: () => _go(context, const CreateAccountScreen())
                            ),
                            const SizedBox(height: AppSpacing.mdSm),
                            AppButton(
                              l.signIn, 
                              variant: AppButtonVariant.outline, 
                              onPressed: () => _go(context, const SignInScreen())
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              l.termsNotice,
                              style: AppText.bodySmall, 
                              textAlign: TextAlign.center
                            ),
                          ]
                        )
                      ),
                    ]
                  )
                )
              )
              )
            )
          )
        ),
      )
    );
  }

  void _go(BuildContext c, Widget w) => Navigator.push(c, MaterialPageRoute(builder: (_) => w));
}