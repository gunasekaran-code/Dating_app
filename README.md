# Amour — Flutter dating app

Built from the "Production Dating App — Global UI/UX Design System" spec.

## Run
1. Install Flutter 3.22+ (https://docs.flutter.dev/get-started/install)
2. In this folder run: `flutter create .` (generates android/ios/web platform folders, keeps lib/)
3. `flutter pub get`
4. `flutter run`

## Structure
- lib/theme/ — design tokens: colors, typography, spacing, radius, shadows, ThemeData
- lib/widgets/ — reusable components: buttons, inputs, chips, badges, profile card, action buttons, empty states, skeleton, toast
- lib/screens/ — welcome, sign in, discover, profile detail, match, matches, chat, my profile, settings
- lib/data/ — mock profiles and messages
All screens use only tokens from lib/theme — no one-off styles.
# Dating_app
# Dating_app
