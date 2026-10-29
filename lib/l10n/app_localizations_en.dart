// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App language';

  @override
  String get appLanguageSubtitle =>
      'Amour is available in English, Tamil, Malayalam and Hindi.';

  @override
  String get deviceLanguage => 'Phone’s language';

  @override
  String get deviceLanguageSubtitle => 'Follow your phone’s settings';

  @override
  String addedSpokenLanguage(String language) {
    return 'Added $language to Languages I speak';
  }

  @override
  String get languagesISpeak => 'Languages I speak';

  @override
  String get languagesEditTitle => 'Which languages do you speak?';

  @override
  String get languagesEditSubtitle =>
      'We’ll show you more people you can really talk to.';

  @override
  String speaks(String languages) {
    return 'Speaks $languages';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get appTagline => 'Meaningful connections, thoughtfully made.';

  @override
  String get welcomeTitle => 'Find your person';

  @override
  String get welcomeSubtitle => 'Join a community that dates with intention.';

  @override
  String get createAccount => 'Create account';

  @override
  String get signIn => 'Sign in';

  @override
  String get termsNotice =>
      'By continuing you agree to our Terms and Privacy Policy.';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in with your email to continue.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 8 characters';

  @override
  String get errEmail => 'Enter a valid email address';

  @override
  String get errPassword => 'Password must be at least 8 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetComingSoon => 'Password reset is coming soon';

  @override
  String get newToAmour => 'New to Amour?';

  @override
  String get createTitle => 'Create your account';

  @override
  String get createSubtitle => 'A few details and you’re in.';

  @override
  String get fullName => 'Full name';

  @override
  String get nameHint => 'Your name';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Re-enter password';

  @override
  String get errName => 'Enter your name';

  @override
  String get errPasswordMismatch => 'Passwords don’t match';

  @override
  String agreeTerms(String terms, String privacy) {
    return 'I agree to the $terms and $privacy';
  }

  @override
  String get terms => 'Terms';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get accountCreated => 'Account created — let’s set up your profile';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get tabDiscover => 'Discover';

  @override
  String get tabMatches => 'Matches';

  @override
  String get tabChats => 'Chats';

  @override
  String get tabProfile => 'Profile';

  @override
  String get saved => 'Saved';

  @override
  String get preferences => 'Preferences';

  @override
  String get caughtUpTitle => 'You\'re all caught up';

  @override
  String get caughtUpMessage =>
      'Check back soon for new people nearby, or widen your preferences.';

  @override
  String get editPreferences => 'Edit preferences';

  @override
  String superCrushSent(String name, int count) {
    return 'SuperCrush sent to $name · $count left';
  }

  @override
  String get rewind => 'Rewind';

  @override
  String get pass => 'Pass';

  @override
  String get like => 'Like';

  @override
  String kmAway(int km) {
    return '$km km away';
  }

  @override
  String get stampLike => 'LIKE';

  @override
  String get stampNope => 'NOPE';

  @override
  String percentMatch(int percent) {
    return '$percent% match';
  }

  @override
  String get ringMatch => 'match';

  @override
  String get verify => 'Verify';

  @override
  String get whyYouMatch => 'Why you match';

  @override
  String matchLabelWith(String label, String name) {
    return '$label with $name';
  }

  @override
  String get matchExceptional => 'Exceptional match';

  @override
  String get matchGreat => 'Great match';

  @override
  String get matchGood => 'Good match';

  @override
  String get matchWorthALook => 'Worth a look';

  @override
  String get matchNoReasons =>
      'Add interests, languages, relationship goals and lifestyle to your profile for sharper picks.';

  @override
  String get picksGetSmarter => 'Picks get smarter as you like, skip and save.';

  @override
  String youAndName(String name) {
    return 'You & $name';
  }

  @override
  String get saveProfile => 'Save profile';

  @override
  String get removeFromSaved => 'Remove from saved';

  @override
  String savedToast(String name) {
    return 'Saved $name · you’ll see more people like them';
  }

  @override
  String removedToast(String name) {
    return 'Removed $name from saved';
  }

  @override
  String listAnd(String first, String last) {
    return '$first and $last';
  }

  @override
  String reasonInterestsFew(String list) {
    return 'You both love $list';
  }

  @override
  String get reasonInterestsFewDetail => 'An easy first conversation starter.';

  @override
  String reasonInterestsMany(int count) {
    return '$count interests in common';
  }

  @override
  String reasonInterestsManyDetail(String list) {
    return '$list are on both your profiles.';
  }

  @override
  String get reasonGoalsSame => 'Same relationship goals';

  @override
  String reasonGoalsSameDetail(String goal) {
    return 'You’re both looking for: $goal.';
  }

  @override
  String get reasonGoalsSimilar => 'Similar relationship goals';

  @override
  String reasonGoalsSimilarDetail(String mine, String name, String theirs) {
    return 'You: $mine · $name: $theirs.';
  }

  @override
  String reasonLanguages(String languages) {
    return 'You both speak $languages';
  }

  @override
  String get reasonLanguagesDetail =>
      'Chat in the language you’re most comfortable in.';

  @override
  String get reasonLifestyle => 'Similar lifestyle';

  @override
  String reasonLifestyleDetail(String topics) {
    return 'Same answers on $topics.';
  }

  @override
  String get reasonPreferences => 'Fits your preferences';

  @override
  String reasonPreferencesDetail(String topics) {
    return 'Matches what you picked for $topics.';
  }

  @override
  String reasonSameCity(String city) {
    return 'Also in $city';
  }

  @override
  String reasonSameCityDetail(int km) {
    return '$km km away — easy to meet up.';
  }

  @override
  String get reasonNearby => 'Lives nearby';

  @override
  String reasonNearbyDetail(int km, String city) {
    return '$km km away in $city.';
  }

  @override
  String get reasonTaste => 'Your type';

  @override
  String reasonTasteDetail(String list) {
    return 'Similar to people you’ve liked who are into $list.';
  }

  @override
  String get reasonVerified => 'Verified profile';

  @override
  String get reasonVerifiedDetail =>
      'Photo-verified, so they are who they say they are.';

  @override
  String get topicKids => 'kids';

  @override
  String get topicSmoking => 'smoking';

  @override
  String get topicSport => 'sport';

  @override
  String get topicDrinking => 'drinking';

  @override
  String get topicFood => 'food habits';

  @override
  String get itsAMatch => 'It\'s a match';

  @override
  String likeEachOther(String name) {
    return 'You and $name like each other.';
  }

  @override
  String get sendMessage => 'Send a message';

  @override
  String get keepDiscovering => 'Keep discovering';

  @override
  String get newMatches => 'New matches';

  @override
  String get conversations => 'Conversations';

  @override
  String get online => 'Online';

  @override
  String get recentlyActive => 'Recently active';

  @override
  String get message => 'Message';

  @override
  String get betterThanHey => 'Say something better than “hey”';

  @override
  String get send => 'Send';

  @override
  String matchedWith(String name) {
    return 'You matched with $name';
  }

  @override
  String get icebreakers => 'Icebreakers';

  @override
  String get icebreakersSubtitle =>
      'Start with what you share. Tap one to edit it before sending.';

  @override
  String get moreIdeas => 'More ideas';

  @override
  String useIcebreaker(String text) {
    return 'Use icebreaker: $text';
  }

  @override
  String icebreakerTaste(String name, String interest) {
    return '$name is into $interest';
  }

  @override
  String icebreakerTheirInterest(String name, String interest) {
    return '$name loves $interest';
  }

  @override
  String icebreakerJob(String name, String job) {
    return '$name is a $job';
  }

  @override
  String icebreakerJobLine(String job) {
    return 'What’s the best part of being a $job?';
  }

  @override
  String icebreakerInterestFallback1(String interest) {
    return 'How did you get into $interest?';
  }

  @override
  String icebreakerInterestFallback2(String interest) {
    return 'What do you love most about $interest?';
  }

  @override
  String get resetPicksTitle => 'Reset your picks?';

  @override
  String get resetPicksMessage =>
      'Amour will forget your likes, skips and SuperCrushes. Saved profiles stay.';

  @override
  String get reset => 'Reset';

  @override
  String get picksReset => 'Your picks have been reset';

  @override
  String get savedProfiles => 'Saved profiles';

  @override
  String get nothingSaved => 'Nothing saved yet';

  @override
  String get nothingSavedMessage =>
      'Tap the bookmark on a profile to keep it here. Saving also tells Amour who to show you more of.';

  @override
  String get yourPicks => 'Your picks';

  @override
  String get yourPicksBody =>
      'Discover is ranked by your profile, your preferences and who you like, skip and save.';

  @override
  String get liked => 'Liked';

  @override
  String get skipped => 'Skipped';

  @override
  String get drawnTo => 'You’re drawn to';

  @override
  String get resetPicks => 'Reset picks';

  @override
  String get settings => 'Settings';

  @override
  String get sectionAccount => 'Account';

  @override
  String get sectionDiscovery => 'Discovery';

  @override
  String get sectionPrivacy => 'Privacy & safety';

  @override
  String get sectionNotifications => 'Notifications';

  @override
  String get sectionGeneral => 'General';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get sectionSupport => 'Support';

  @override
  String get personalDetails => 'Personal details';

  @override
  String get emailAndPhone => 'Email & phone';

  @override
  String get blockedProfiles => 'Blocked profiles';

  @override
  String blockedCount(int count) {
    return '$count blocked';
  }

  @override
  String get safetyCentre => 'Safety centre';

  @override
  String get help => 'Help';

  @override
  String get termsAndPrivacy => 'Terms & privacy';

  @override
  String get showMeInDiscover => 'Show me in Discover';

  @override
  String get showOnlineStatus => 'Show online status';

  @override
  String get messages => 'Messages';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutTitle => 'Sign out?';

  @override
  String get signOutMessage => 'You can sign back in any time.';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get back => 'Back';

  @override
  String get more => 'More';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get profileStrength => 'Profile strength';

  @override
  String get myPhotos => 'My photos';

  @override
  String get manage => 'Manage';

  @override
  String get managePhotos => 'Manage photos';

  @override
  String get aboutMe => 'About me';

  @override
  String get addBioHint => 'Add a short bio to tell people about yourself.';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get editPhotos => 'Edit photos';

  @override
  String get about => 'About';

  @override
  String get interests => 'Interests';

  @override
  String lookingFor(String goal) {
    return 'Looking for: $goal';
  }

  @override
  String reportName(String name) {
    return 'Report $name';
  }

  @override
  String blockName(String name) {
    return 'Block $name';
  }

  @override
  String blockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get blockMessage =>
      'They won\'t be able to see your profile or message you.';

  @override
  String get block => 'Block';

  @override
  String blockedToast(String name) {
    return '$name has been blocked';
  }

  @override
  String get voicePromptTitle => 'Answer with your voice';

  @override
  String voicePromptSubtitle(int seconds) {
    return 'Up to $seconds seconds. Hearing you is the quickest way for someone to feel they know you.';
  }

  @override
  String get tapToRecord => 'Tap to record';

  @override
  String get recordingNow => 'Recording…';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get reRecord => 'Re-record';

  @override
  String get deleteVoice => 'Delete voice note';

  @override
  String get voiceTooShort => 'Too short — say a little more';

  @override
  String get micNeeded =>
      'Microphone access is needed to record a voice prompt.';

  @override
  String get micBlockedTitle => 'Microphone access is off';

  @override
  String get micBlockedMessage =>
      'Turn on microphone access for Amour in Settings to record voice prompts.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get recordFailed => 'Couldn’t record. Please try again.';

  @override
  String get playVoice => 'Play voice prompt';

  @override
  String get pauseVoice => 'Pause voice prompt';

  @override
  String get playFailed => 'This voice note couldn’t be played.';

  @override
  String get voiceBadge => 'Voice';

  @override
  String get teaserSubtitle => 'Keep it short, honest and a little playful.';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get captionHint => 'Add a written answer (optional)';

  @override
  String get save => 'Save';

  @override
  String get changePrompt => 'Change prompt';

  @override
  String get teaserSaved => 'Teaser saved';

  @override
  String get reasonVoice => 'Recorded a voice prompt';

  @override
  String get reasonVoiceDetail =>
      'Hear them before you match — a voice is much harder to fake than a photo.';

  @override
  String icebreakerVoice(String name) {
    return '$name’s voice prompt';
  }
}
