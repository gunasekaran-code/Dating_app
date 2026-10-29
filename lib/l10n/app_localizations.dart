import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
    Locale('ta')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Amour is available in English, Tamil, Malayalam and Hindi.'**
  String get appLanguageSubtitle;

  /// No description provided for @deviceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Phone’s language'**
  String get deviceLanguage;

  /// No description provided for @deviceLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your phone’s settings'**
  String get deviceLanguageSubtitle;

  /// No description provided for @addedSpokenLanguage.
  ///
  /// In en, this message translates to:
  /// **'Added {language} to Languages I speak'**
  String addedSpokenLanguage(String language);

  /// No description provided for @languagesISpeak.
  ///
  /// In en, this message translates to:
  /// **'Languages I speak'**
  String get languagesISpeak;

  /// No description provided for @languagesEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Which languages do you speak?'**
  String get languagesEditTitle;

  /// No description provided for @languagesEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We’ll show you more people you can really talk to.'**
  String get languagesEditSubtitle;

  /// No description provided for @speaks.
  ///
  /// In en, this message translates to:
  /// **'Speaks {languages}'**
  String speaks(String languages);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Meaningful connections, thoughtfully made.'**
  String get appTagline;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Find your person'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join a community that dates with intention.'**
  String get welcomeSubtitle;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @termsNotice.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms and Privacy Policy.'**
  String get termsNotice;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your email to continue.'**
  String get signInSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordHint;

  /// No description provided for @errEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errEmail;

  /// No description provided for @errPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get errPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset is coming soon'**
  String get resetComingSoon;

  /// No description provided for @newToAmour.
  ///
  /// In en, this message translates to:
  /// **'New to Amour?'**
  String get newToAmour;

  /// No description provided for @createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createTitle;

  /// No description provided for @createSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few details and you’re in.'**
  String get createSubtitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter password'**
  String get confirmPasswordHint;

  /// No description provided for @errName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get errName;

  /// No description provided for @errPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don’t match'**
  String get errPasswordMismatch;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the {terms} and {privacy}'**
  String agreeTerms(String terms, String privacy);

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created — let’s set up your profile'**
  String get accountCreated;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @tabDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get tabDiscover;

  /// No description provided for @tabMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get tabMatches;

  /// No description provided for @tabChats.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get tabChats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @caughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get caughtUpTitle;

  /// No description provided for @caughtUpMessage.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new people nearby, or widen your preferences.'**
  String get caughtUpMessage;

  /// No description provided for @editPreferences.
  ///
  /// In en, this message translates to:
  /// **'Edit preferences'**
  String get editPreferences;

  /// No description provided for @superCrushSent.
  ///
  /// In en, this message translates to:
  /// **'SuperCrush sent to {name} · {count} left'**
  String superCrushSent(String name, int count);

  /// No description provided for @rewind.
  ///
  /// In en, this message translates to:
  /// **'Rewind'**
  String get rewind;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @kmAway.
  ///
  /// In en, this message translates to:
  /// **'{km} km away'**
  String kmAway(int km);

  /// No description provided for @stampLike.
  ///
  /// In en, this message translates to:
  /// **'LIKE'**
  String get stampLike;

  /// No description provided for @stampNope.
  ///
  /// In en, this message translates to:
  /// **'NOPE'**
  String get stampNope;

  /// No description provided for @percentMatch.
  ///
  /// In en, this message translates to:
  /// **'{percent}% match'**
  String percentMatch(int percent);

  /// No description provided for @ringMatch.
  ///
  /// In en, this message translates to:
  /// **'match'**
  String get ringMatch;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @whyYouMatch.
  ///
  /// In en, this message translates to:
  /// **'Why you match'**
  String get whyYouMatch;

  /// No description provided for @matchLabelWith.
  ///
  /// In en, this message translates to:
  /// **'{label} with {name}'**
  String matchLabelWith(String label, String name);

  /// No description provided for @matchExceptional.
  ///
  /// In en, this message translates to:
  /// **'Exceptional match'**
  String get matchExceptional;

  /// No description provided for @matchGreat.
  ///
  /// In en, this message translates to:
  /// **'Great match'**
  String get matchGreat;

  /// No description provided for @matchGood.
  ///
  /// In en, this message translates to:
  /// **'Good match'**
  String get matchGood;

  /// No description provided for @matchWorthALook.
  ///
  /// In en, this message translates to:
  /// **'Worth a look'**
  String get matchWorthALook;

  /// No description provided for @matchNoReasons.
  ///
  /// In en, this message translates to:
  /// **'Add interests, languages, relationship goals and lifestyle to your profile for sharper picks.'**
  String get matchNoReasons;

  /// No description provided for @picksGetSmarter.
  ///
  /// In en, this message translates to:
  /// **'Picks get smarter as you like, skip and save.'**
  String get picksGetSmarter;

  /// No description provided for @youAndName.
  ///
  /// In en, this message translates to:
  /// **'You & {name}'**
  String youAndName(String name);

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get saveProfile;

  /// No description provided for @removeFromSaved.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get removeFromSaved;

  /// No description provided for @savedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved {name} · you’ll see more people like them'**
  String savedToast(String name);

  /// No description provided for @removedToast.
  ///
  /// In en, this message translates to:
  /// **'Removed {name} from saved'**
  String removedToast(String name);

  /// No description provided for @listAnd.
  ///
  /// In en, this message translates to:
  /// **'{first} and {last}'**
  String listAnd(String first, String last);

  /// No description provided for @reasonInterestsFew.
  ///
  /// In en, this message translates to:
  /// **'You both love {list}'**
  String reasonInterestsFew(String list);

  /// No description provided for @reasonInterestsFewDetail.
  ///
  /// In en, this message translates to:
  /// **'An easy first conversation starter.'**
  String get reasonInterestsFewDetail;

  /// No description provided for @reasonInterestsMany.
  ///
  /// In en, this message translates to:
  /// **'{count} interests in common'**
  String reasonInterestsMany(int count);

  /// No description provided for @reasonInterestsManyDetail.
  ///
  /// In en, this message translates to:
  /// **'{list} are on both your profiles.'**
  String reasonInterestsManyDetail(String list);

  /// No description provided for @reasonGoalsSame.
  ///
  /// In en, this message translates to:
  /// **'Same relationship goals'**
  String get reasonGoalsSame;

  /// No description provided for @reasonGoalsSameDetail.
  ///
  /// In en, this message translates to:
  /// **'You’re both looking for: {goal}.'**
  String reasonGoalsSameDetail(String goal);

  /// No description provided for @reasonGoalsSimilar.
  ///
  /// In en, this message translates to:
  /// **'Similar relationship goals'**
  String get reasonGoalsSimilar;

  /// No description provided for @reasonGoalsSimilarDetail.
  ///
  /// In en, this message translates to:
  /// **'You: {mine} · {name}: {theirs}.'**
  String reasonGoalsSimilarDetail(String mine, String name, String theirs);

  /// No description provided for @reasonLanguages.
  ///
  /// In en, this message translates to:
  /// **'You both speak {languages}'**
  String reasonLanguages(String languages);

  /// No description provided for @reasonLanguagesDetail.
  ///
  /// In en, this message translates to:
  /// **'Chat in the language you’re most comfortable in.'**
  String get reasonLanguagesDetail;

  /// No description provided for @reasonLifestyle.
  ///
  /// In en, this message translates to:
  /// **'Similar lifestyle'**
  String get reasonLifestyle;

  /// No description provided for @reasonLifestyleDetail.
  ///
  /// In en, this message translates to:
  /// **'Same answers on {topics}.'**
  String reasonLifestyleDetail(String topics);

  /// No description provided for @reasonPreferences.
  ///
  /// In en, this message translates to:
  /// **'Fits your preferences'**
  String get reasonPreferences;

  /// No description provided for @reasonPreferencesDetail.
  ///
  /// In en, this message translates to:
  /// **'Matches what you picked for {topics}.'**
  String reasonPreferencesDetail(String topics);

  /// No description provided for @reasonSameCity.
  ///
  /// In en, this message translates to:
  /// **'Also in {city}'**
  String reasonSameCity(String city);

  /// No description provided for @reasonSameCityDetail.
  ///
  /// In en, this message translates to:
  /// **'{km} km away — easy to meet up.'**
  String reasonSameCityDetail(int km);

  /// No description provided for @reasonNearby.
  ///
  /// In en, this message translates to:
  /// **'Lives nearby'**
  String get reasonNearby;

  /// No description provided for @reasonNearbyDetail.
  ///
  /// In en, this message translates to:
  /// **'{km} km away in {city}.'**
  String reasonNearbyDetail(int km, String city);

  /// No description provided for @reasonTaste.
  ///
  /// In en, this message translates to:
  /// **'Your type'**
  String get reasonTaste;

  /// No description provided for @reasonTasteDetail.
  ///
  /// In en, this message translates to:
  /// **'Similar to people you’ve liked who are into {list}.'**
  String reasonTasteDetail(String list);

  /// No description provided for @reasonVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified profile'**
  String get reasonVerified;

  /// No description provided for @reasonVerifiedDetail.
  ///
  /// In en, this message translates to:
  /// **'Photo-verified, so they are who they say they are.'**
  String get reasonVerifiedDetail;

  /// No description provided for @topicKids.
  ///
  /// In en, this message translates to:
  /// **'kids'**
  String get topicKids;

  /// No description provided for @topicSmoking.
  ///
  /// In en, this message translates to:
  /// **'smoking'**
  String get topicSmoking;

  /// No description provided for @topicSport.
  ///
  /// In en, this message translates to:
  /// **'sport'**
  String get topicSport;

  /// No description provided for @topicDrinking.
  ///
  /// In en, this message translates to:
  /// **'drinking'**
  String get topicDrinking;

  /// No description provided for @topicFood.
  ///
  /// In en, this message translates to:
  /// **'food habits'**
  String get topicFood;

  /// No description provided for @itsAMatch.
  ///
  /// In en, this message translates to:
  /// **'It\'s a match'**
  String get itsAMatch;

  /// No description provided for @likeEachOther.
  ///
  /// In en, this message translates to:
  /// **'You and {name} like each other.'**
  String likeEachOther(String name);

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send a message'**
  String get sendMessage;

  /// No description provided for @keepDiscovering.
  ///
  /// In en, this message translates to:
  /// **'Keep discovering'**
  String get keepDiscovering;

  /// No description provided for @newMatches.
  ///
  /// In en, this message translates to:
  /// **'New matches'**
  String get newMatches;

  /// No description provided for @conversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @recentlyActive.
  ///
  /// In en, this message translates to:
  /// **'Recently active'**
  String get recentlyActive;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @betterThanHey.
  ///
  /// In en, this message translates to:
  /// **'Say something better than “hey”'**
  String get betterThanHey;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @matchedWith.
  ///
  /// In en, this message translates to:
  /// **'You matched with {name}'**
  String matchedWith(String name);

  /// No description provided for @icebreakers.
  ///
  /// In en, this message translates to:
  /// **'Icebreakers'**
  String get icebreakers;

  /// No description provided for @icebreakersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with what you share. Tap one to edit it before sending.'**
  String get icebreakersSubtitle;

  /// No description provided for @moreIdeas.
  ///
  /// In en, this message translates to:
  /// **'More ideas'**
  String get moreIdeas;

  /// No description provided for @useIcebreaker.
  ///
  /// In en, this message translates to:
  /// **'Use icebreaker: {text}'**
  String useIcebreaker(String text);

  /// No description provided for @icebreakerTaste.
  ///
  /// In en, this message translates to:
  /// **'{name} is into {interest}'**
  String icebreakerTaste(String name, String interest);

  /// No description provided for @icebreakerTheirInterest.
  ///
  /// In en, this message translates to:
  /// **'{name} loves {interest}'**
  String icebreakerTheirInterest(String name, String interest);

  /// No description provided for @icebreakerJob.
  ///
  /// In en, this message translates to:
  /// **'{name} is a {job}'**
  String icebreakerJob(String name, String job);

  /// No description provided for @icebreakerJobLine.
  ///
  /// In en, this message translates to:
  /// **'What’s the best part of being a {job}?'**
  String icebreakerJobLine(String job);

  /// No description provided for @icebreakerInterestFallback1.
  ///
  /// In en, this message translates to:
  /// **'How did you get into {interest}?'**
  String icebreakerInterestFallback1(String interest);

  /// No description provided for @icebreakerInterestFallback2.
  ///
  /// In en, this message translates to:
  /// **'What do you love most about {interest}?'**
  String icebreakerInterestFallback2(String interest);

  /// No description provided for @resetPicksTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your picks?'**
  String get resetPicksTitle;

  /// No description provided for @resetPicksMessage.
  ///
  /// In en, this message translates to:
  /// **'Amour will forget your likes, skips and SuperCrushes. Saved profiles stay.'**
  String get resetPicksMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @picksReset.
  ///
  /// In en, this message translates to:
  /// **'Your picks have been reset'**
  String get picksReset;

  /// No description provided for @savedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Saved profiles'**
  String get savedProfiles;

  /// No description provided for @nothingSaved.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get nothingSaved;

  /// No description provided for @nothingSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on a profile to keep it here. Saving also tells Amour who to show you more of.'**
  String get nothingSavedMessage;

  /// No description provided for @yourPicks.
  ///
  /// In en, this message translates to:
  /// **'Your picks'**
  String get yourPicks;

  /// No description provided for @yourPicksBody.
  ///
  /// In en, this message translates to:
  /// **'Discover is ranked by your profile, your preferences and who you like, skip and save.'**
  String get yourPicksBody;

  /// No description provided for @liked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get liked;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @drawnTo.
  ///
  /// In en, this message translates to:
  /// **'You’re drawn to'**
  String get drawnTo;

  /// No description provided for @resetPicks.
  ///
  /// In en, this message translates to:
  /// **'Reset picks'**
  String get resetPicks;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @sectionDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get sectionDiscovery;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & safety'**
  String get sectionPrivacy;

  /// No description provided for @sectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get sectionNotifications;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get sectionSupport;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalDetails;

  /// No description provided for @emailAndPhone.
  ///
  /// In en, this message translates to:
  /// **'Email & phone'**
  String get emailAndPhone;

  /// No description provided for @blockedProfiles.
  ///
  /// In en, this message translates to:
  /// **'Blocked profiles'**
  String get blockedProfiles;

  /// No description provided for @blockedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} blocked'**
  String blockedCount(int count);

  /// No description provided for @safetyCentre.
  ///
  /// In en, this message translates to:
  /// **'Safety centre'**
  String get safetyCentre;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & privacy'**
  String get termsAndPrivacy;

  /// No description provided for @showMeInDiscover.
  ///
  /// In en, this message translates to:
  /// **'Show me in Discover'**
  String get showMeInDiscover;

  /// No description provided for @showOnlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Show online status'**
  String get showOnlineStatus;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutTitle;

  /// No description provided for @signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You can sign back in any time.'**
  String get signOutMessage;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @profileStrength.
  ///
  /// In en, this message translates to:
  /// **'Profile strength'**
  String get profileStrength;

  /// No description provided for @myPhotos.
  ///
  /// In en, this message translates to:
  /// **'My photos'**
  String get myPhotos;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @managePhotos.
  ///
  /// In en, this message translates to:
  /// **'Manage photos'**
  String get managePhotos;

  /// No description provided for @aboutMe.
  ///
  /// In en, this message translates to:
  /// **'About me'**
  String get aboutMe;

  /// No description provided for @addBioHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short bio to tell people about yourself.'**
  String get addBioHint;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @editPhotos.
  ///
  /// In en, this message translates to:
  /// **'Edit photos'**
  String get editPhotos;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @interests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// No description provided for @lookingFor.
  ///
  /// In en, this message translates to:
  /// **'Looking for: {goal}'**
  String lookingFor(String goal);

  /// No description provided for @reportName.
  ///
  /// In en, this message translates to:
  /// **'Report {name}'**
  String reportName(String name);

  /// No description provided for @blockName.
  ///
  /// In en, this message translates to:
  /// **'Block {name}'**
  String blockName(String name);

  /// No description provided for @blockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockTitle(String name);

  /// No description provided for @blockMessage.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to see your profile or message you.'**
  String get blockMessage;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @blockedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked'**
  String blockedToast(String name);

  /// No description provided for @voicePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Answer with your voice'**
  String get voicePromptTitle;

  /// No description provided for @voicePromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Up to {seconds} seconds. Hearing you is the quickest way for someone to feel they know you.'**
  String voicePromptSubtitle(int seconds);

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get tapToRecord;

  /// No description provided for @recordingNow.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recordingNow;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @reRecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get reRecord;

  /// No description provided for @deleteVoice.
  ///
  /// In en, this message translates to:
  /// **'Delete voice note'**
  String get deleteVoice;

  /// No description provided for @voiceTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short — say a little more'**
  String get voiceTooShort;

  /// No description provided for @micNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is needed to record a voice prompt.'**
  String get micNeeded;

  /// No description provided for @micBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access is off'**
  String get micBlockedTitle;

  /// No description provided for @micBlockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Turn on microphone access for Amour in Settings to record voice prompts.'**
  String get micBlockedMessage;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @recordFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t record. Please try again.'**
  String get recordFailed;

  /// No description provided for @playVoice.
  ///
  /// In en, this message translates to:
  /// **'Play voice prompt'**
  String get playVoice;

  /// No description provided for @pauseVoice.
  ///
  /// In en, this message translates to:
  /// **'Pause voice prompt'**
  String get pauseVoice;

  /// No description provided for @playFailed.
  ///
  /// In en, this message translates to:
  /// **'This voice note couldn’t be played.'**
  String get playFailed;

  /// No description provided for @voiceBadge.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceBadge;

  /// No description provided for @teaserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep it short, honest and a little playful.'**
  String get teaserSubtitle;

  /// No description provided for @yourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a written answer (optional)'**
  String get captionHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changePrompt.
  ///
  /// In en, this message translates to:
  /// **'Change prompt'**
  String get changePrompt;

  /// No description provided for @teaserSaved.
  ///
  /// In en, this message translates to:
  /// **'Teaser saved'**
  String get teaserSaved;

  /// No description provided for @reasonVoice.
  ///
  /// In en, this message translates to:
  /// **'Recorded a voice prompt'**
  String get reasonVoice;

  /// No description provided for @reasonVoiceDetail.
  ///
  /// In en, this message translates to:
  /// **'Hear them before you match — a voice is much harder to fake than a photo.'**
  String get reasonVoiceDetail;

  /// No description provided for @icebreakerVoice.
  ///
  /// In en, this message translates to:
  /// **'{name}’s voice prompt'**
  String icebreakerVoice(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ml', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
