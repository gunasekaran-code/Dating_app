// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get language => 'மொழி';

  @override
  String get appLanguage => 'ஆப் மொழி';

  @override
  String get appLanguageSubtitle =>
      'Amour ஆங்கிலம், தமிழ், மலையாளம் மற்றும் இந்தியில் கிடைக்கிறது.';

  @override
  String get deviceLanguage => 'போனின் மொழி';

  @override
  String get deviceLanguageSubtitle => 'உங்கள் போன் அமைப்புகளைப் பின்பற்றும்';

  @override
  String addedSpokenLanguage(String language) {
    return 'நான் பேசும் மொழிகளில் $language சேர்க்கப்பட்டது';
  }

  @override
  String get languagesISpeak => 'நான் பேசும் மொழிகள்';

  @override
  String get languagesEditTitle => 'நீங்கள் எந்தெந்த மொழிகள் பேசுவீர்கள்?';

  @override
  String get languagesEditSubtitle =>
      'உங்களுடன் மனம்விட்டுப் பேசக்கூடியவர்களை அதிகம் காட்டுவோம்.';

  @override
  String speaks(String languages) {
    return 'பேசும் மொழிகள்: $languages';
  }

  @override
  String selectedCount(int count) {
    return '$count தேர்ந்தெடுக்கப்பட்டது';
  }

  @override
  String get appTagline => 'அர்த்தமுள்ள உறவுகள், அக்கறையுடன் உருவாக்கப்பட்டவை.';

  @override
  String get welcomeTitle => 'உங்களுக்கான துணையைக் கண்டறியுங்கள்';

  @override
  String get welcomeSubtitle =>
      'நோக்கத்துடன் டேட்டிங் செய்யும் சமூகத்தில் இணையுங்கள்.';

  @override
  String get createAccount => 'கணக்கை உருவாக்கு';

  @override
  String get signIn => 'உள்நுழை';

  @override
  String get termsNotice =>
      'தொடர்வதன் மூலம் எங்கள் விதிமுறைகள் மற்றும் தனியுரிமைக் கொள்கையை ஏற்கிறீர்கள்.';

  @override
  String get signInTitle => 'மீண்டும் வருக';

  @override
  String get signInSubtitle => 'தொடர உங்கள் மின்னஞ்சலுடன் உள்நுழையுங்கள்.';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get passwordHint => 'குறைந்தது 8 எழுத்துகள்';

  @override
  String get errEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடுங்கள்';

  @override
  String get errPassword => 'கடவுச்சொல் குறைந்தது 8 எழுத்துகள் இருக்க வேண்டும்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get resetComingSoon => 'கடவுச்சொல் மீட்டமைப்பு விரைவில் வரும்';

  @override
  String get newToAmour => 'Amour-க்குப் புதியவரா?';

  @override
  String get createTitle => 'உங்கள் கணக்கை உருவாக்குங்கள்';

  @override
  String get createSubtitle => 'சில விவரங்கள் போதும், நீங்கள் தயார்.';

  @override
  String get fullName => 'முழுப் பெயர்';

  @override
  String get nameHint => 'உங்கள் பெயர்';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிசெய்';

  @override
  String get confirmPasswordHint => 'கடவுச்சொல்லை மீண்டும் உள்ளிடுங்கள்';

  @override
  String get errName => 'உங்கள் பெயரை உள்ளிடுங்கள்';

  @override
  String get errPasswordMismatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String agreeTerms(String terms, String privacy) {
    return '$terms மற்றும் $privacy-ஐ ஏற்கிறேன்';
  }

  @override
  String get terms => 'விதிமுறைகள்';

  @override
  String get privacyPolicy => 'தனியுரிமைக் கொள்கை';

  @override
  String get accountCreated =>
      'கணக்கு உருவாக்கப்பட்டது — உங்கள் சுயவிவரத்தை அமைப்போம்';

  @override
  String get haveAccount => 'ஏற்கனவே கணக்கு உள்ளதா?';

  @override
  String get tabDiscover => 'கண்டறி';

  @override
  String get tabMatches => 'பொருத்தங்கள்';

  @override
  String get tabChats => 'அரட்டைகள்';

  @override
  String get tabProfile => 'சுயவிவரம்';

  @override
  String get saved => 'சேமித்தவை';

  @override
  String get preferences => 'விருப்பங்கள்';

  @override
  String get caughtUpTitle => 'இப்போதைக்கு அவ்வளவுதான்';

  @override
  String get caughtUpMessage =>
      'அருகிலுள்ள புதியவர்களுக்கு விரைவில் மீண்டும் பாருங்கள், அல்லது உங்கள் விருப்பங்களை விரிவுபடுத்துங்கள்.';

  @override
  String get editPreferences => 'விருப்பங்களைத் திருத்து';

  @override
  String superCrushSent(String name, int count) {
    return '$name-க்கு SuperCrush அனுப்பப்பட்டது · $count மீதம்';
  }

  @override
  String get rewind => 'திரும்பு';

  @override
  String get pass => 'தவிர்';

  @override
  String get like => 'பிடித்தது';

  @override
  String kmAway(int km) {
    return '$km கி.மீ. தொலைவில்';
  }

  @override
  String get stampLike => 'பிடித்தது';

  @override
  String get stampNope => 'வேண்டாம்';

  @override
  String percentMatch(int percent) {
    return '$percent% பொருத்தம்';
  }

  @override
  String get ringMatch => 'பொருத்தம்';

  @override
  String get verify => 'சரிபார்';

  @override
  String get whyYouMatch => 'ஏன் பொருந்துகிறீர்கள்';

  @override
  String matchLabelWith(String label, String name) {
    return '$name உடன் $label';
  }

  @override
  String get matchExceptional => 'அபாரமான பொருத்தம்';

  @override
  String get matchGreat => 'சிறந்த பொருத்தம்';

  @override
  String get matchGood => 'நல்ல பொருத்தம்';

  @override
  String get matchWorthALook => 'பார்க்கத் தகுந்தவர்';

  @override
  String get matchNoReasons =>
      'சிறந்த பரிந்துரைகளுக்கு உங்கள் சுயவிவரத்தில் ஆர்வங்கள், மொழிகள், உறவு இலக்குகள், வாழ்க்கை முறையைச் சேருங்கள்.';

  @override
  String get picksGetSmarter =>
      'நீங்கள் விரும்ப, தவிர்க்க, சேமிக்க பரிந்துரைகள் மேம்படும்.';

  @override
  String youAndName(String name) {
    return 'நீங்களும் $name-உம்';
  }

  @override
  String get saveProfile => 'சுயவிவரத்தைச் சேமி';

  @override
  String get removeFromSaved => 'சேமித்தவற்றிலிருந்து நீக்கு';

  @override
  String savedToast(String name) {
    return '$name சேமிக்கப்பட்டார் · இவரைப் போன்றவர்களை அதிகம் காண்பீர்கள்';
  }

  @override
  String removedToast(String name) {
    return '$name சேமித்தவற்றிலிருந்து நீக்கப்பட்டார்';
  }

  @override
  String listAnd(String first, String last) {
    return '$first மற்றும் $last';
  }

  @override
  String reasonInterestsFew(String list) {
    return 'நீங்கள் இருவரும் விரும்புவது $list';
  }

  @override
  String get reasonInterestsFewDetail => 'முதல் உரையாடலைத் தொடங்க எளிதான வழி.';

  @override
  String reasonInterestsMany(int count) {
    return '$count பொதுவான ஆர்வங்கள்';
  }

  @override
  String reasonInterestsManyDetail(String list) {
    return '$list — இவை இருவரின் சுயவிவரத்திலும் உள்ளன.';
  }

  @override
  String get reasonGoalsSame => 'ஒரே உறவு இலக்குகள்';

  @override
  String reasonGoalsSameDetail(String goal) {
    return 'நீங்கள் இருவரும் தேடுவது: $goal.';
  }

  @override
  String get reasonGoalsSimilar => 'ஒத்த உறவு இலக்குகள்';

  @override
  String reasonGoalsSimilarDetail(String mine, String name, String theirs) {
    return 'நீங்கள்: $mine · $name: $theirs.';
  }

  @override
  String reasonLanguages(String languages) {
    return 'நீங்கள் இருவரும் $languages பேசுவீர்கள்';
  }

  @override
  String get reasonLanguagesDetail =>
      'உங்களுக்கு மிகவும் வசதியான மொழியில் அரட்டையடியுங்கள்.';

  @override
  String get reasonLifestyle => 'ஒத்த வாழ்க்கை முறை';

  @override
  String reasonLifestyleDetail(String topics) {
    return '$topics பற்றி ஒரே பதில்கள்.';
  }

  @override
  String get reasonPreferences => 'உங்கள் விருப்பங்களுக்குப் பொருந்துகிறார்';

  @override
  String reasonPreferencesDetail(String topics) {
    return '$topics குறித்த உங்கள் தேர்வுகளுக்குப் பொருந்துகிறது.';
  }

  @override
  String reasonSameCity(String city) {
    return 'இவரும் $city-இல்';
  }

  @override
  String reasonSameCityDetail(int km) {
    return '$km கி.மீ. தொலைவில் — சந்திப்பது எளிது.';
  }

  @override
  String get reasonNearby => 'அருகில் வசிக்கிறார்';

  @override
  String reasonNearbyDetail(int km, String city) {
    return '$city-இல், $km கி.மீ. தொலைவில்.';
  }

  @override
  String get reasonTaste => 'உங்கள் ரசனைக்கேற்றவர்';

  @override
  String reasonTasteDetail(String list) {
    return '$list விரும்பும், நீங்கள் லைக் செய்தவர்களைப் போன்றவர்.';
  }

  @override
  String get reasonVerified => 'சரிபார்க்கப்பட்ட சுயவிவரம்';

  @override
  String get reasonVerifiedDetail =>
      'புகைப்படம் சரிபார்க்கப்பட்டது — சொல்லும் நபர் இவரேதான்.';

  @override
  String get topicKids => 'குழந்தைகள்';

  @override
  String get topicSmoking => 'புகைபிடித்தல்';

  @override
  String get topicSport => 'விளையாட்டு';

  @override
  String get topicDrinking => 'மது அருந்துதல்';

  @override
  String get topicFood => 'உணவுப் பழக்கம்';

  @override
  String get itsAMatch => 'பொருத்தம் கிடைத்தது!';

  @override
  String likeEachOther(String name) {
    return 'நீங்களும் $name-உம் ஒருவரையொருவர் விரும்புகிறீர்கள்.';
  }

  @override
  String get sendMessage => 'செய்தி அனுப்பு';

  @override
  String get keepDiscovering => 'தொடர்ந்து கண்டறி';

  @override
  String get newMatches => 'புதிய பொருத்தங்கள்';

  @override
  String get conversations => 'உரையாடல்கள்';

  @override
  String get online => 'ஆன்லைனில்';

  @override
  String get recentlyActive => 'சமீபத்தில் செயலில்';

  @override
  String get message => 'செய்தி';

  @override
  String get betterThanHey => '“ஹாய்”-ஐ விடச் சிறப்பாக ஏதாவது சொல்லுங்கள்';

  @override
  String get send => 'அனுப்பு';

  @override
  String matchedWith(String name) {
    return '$name உடன் பொருத்தம் கிடைத்தது';
  }

  @override
  String get icebreakers => 'பேச்சைத் தொடங்க';

  @override
  String get icebreakersSubtitle =>
      'பொதுவான விஷயத்திலிருந்து தொடங்குங்கள். அனுப்பும் முன் திருத்த ஒன்றைத் தட்டுங்கள்.';

  @override
  String get moreIdeas => 'மேலும் யோசனைகள்';

  @override
  String useIcebreaker(String text) {
    return 'இதைப் பயன்படுத்து: $text';
  }

  @override
  String icebreakerTaste(String name, String interest) {
    return '$name-க்கு $interest பிடிக்கும்';
  }

  @override
  String icebreakerTheirInterest(String name, String interest) {
    return '$name $interest விரும்புகிறார்';
  }

  @override
  String icebreakerJob(String name, String job) {
    return '$name ஒரு $job';
  }

  @override
  String icebreakerJobLine(String job) {
    return '$job ஆக இருப்பதில் உங்களுக்குப் பிடித்தது என்ன?';
  }

  @override
  String icebreakerInterestFallback1(String interest) {
    return '$interest மீது ஆர்வம் எப்படி வந்தது?';
  }

  @override
  String icebreakerInterestFallback2(String interest) {
    return '$interest-இல் உங்களுக்கு மிகவும் பிடித்தது என்ன?';
  }

  @override
  String get resetPicksTitle => 'பரிந்துரைகளை மீட்டமைக்கவா?';

  @override
  String get resetPicksMessage =>
      'உங்கள் லைக்குகள், தவிர்த்தவை, SuperCrush-களை Amour மறந்துவிடும். சேமித்த சுயவிவரங்கள் அப்படியே இருக்கும்.';

  @override
  String get reset => 'மீட்டமை';

  @override
  String get picksReset => 'உங்கள் பரிந்துரைகள் மீட்டமைக்கப்பட்டன';

  @override
  String get savedProfiles => 'சேமித்த சுயவிவரங்கள்';

  @override
  String get nothingSaved => 'இன்னும் எதுவும் சேமிக்கவில்லை';

  @override
  String get nothingSavedMessage =>
      'ஒரு சுயவிவரத்தை இங்கே வைத்திருக்க புக்மார்க்கைத் தட்டுங்கள். யாரை அதிகம் காட்ட வேண்டும் என்பதையும் இது Amour-க்குச் சொல்லும்.';

  @override
  String get yourPicks => 'உங்கள் பரிந்துரைகள்';

  @override
  String get yourPicksBody =>
      'உங்கள் சுயவிவரம், விருப்பங்கள், நீங்கள் லைக் செய்பவர்கள், தவிர்ப்பவர்கள், சேமிப்பவர்களைக் கொண்டு கண்டறி பக்கம் வரிசைப்படுத்தப்படுகிறது.';

  @override
  String get liked => 'பிடித்தவை';

  @override
  String get skipped => 'தவிர்த்தவை';

  @override
  String get drawnTo => 'உங்களை ஈர்ப்பவை';

  @override
  String get resetPicks => 'பரிந்துரைகளை மீட்டமை';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get sectionAccount => 'கணக்கு';

  @override
  String get sectionDiscovery => 'கண்டறிதல்';

  @override
  String get sectionPrivacy => 'தனியுரிமை & பாதுகாப்பு';

  @override
  String get sectionNotifications => 'அறிவிப்புகள்';

  @override
  String get sectionGeneral => 'பொது';

  @override
  String get hapticFeedback => 'தொடு அதிர்வு';

  @override
  String get sectionSupport => 'உதவி மையம்';

  @override
  String get personalDetails => 'தனிப்பட்ட விவரங்கள்';

  @override
  String get emailAndPhone => 'மின்னஞ்சல் & தொலைபேசி';

  @override
  String get blockedProfiles => 'தடுக்கப்பட்ட சுயவிவரங்கள்';

  @override
  String blockedCount(int count) {
    return '$count தடுக்கப்பட்டது';
  }

  @override
  String get safetyCentre => 'பாதுகாப்பு மையம்';

  @override
  String get help => 'உதவி';

  @override
  String get termsAndPrivacy => 'விதிமுறைகள் & தனியுரிமை';

  @override
  String get showMeInDiscover => 'கண்டறி பக்கத்தில் என்னைக் காட்டு';

  @override
  String get showOnlineStatus => 'ஆன்லைன் நிலையைக் காட்டு';

  @override
  String get messages => 'செய்திகள்';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get signOutTitle => 'வெளியேறவா?';

  @override
  String get signOutMessage => 'எப்போது வேண்டுமானாலும் மீண்டும் உள்நுழையலாம்.';

  @override
  String get deleteAccount => 'கணக்கை நீக்கு';

  @override
  String version(String version) {
    return 'பதிப்பு $version';
  }

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get back => 'பின்செல்';

  @override
  String get more => 'மேலும்';

  @override
  String get add => 'சேர்';

  @override
  String get edit => 'திருத்து';

  @override
  String get profileStrength => 'சுயவிவர வலிமை';

  @override
  String get myPhotos => 'என் புகைப்படங்கள்';

  @override
  String get manage => 'நிர்வகி';

  @override
  String get managePhotos => 'புகைப்படங்களை நிர்வகி';

  @override
  String get aboutMe => 'என்னைப் பற்றி';

  @override
  String get addBioHint =>
      'உங்களைப் பற்றிச் சொல்ல ஒரு சிறு அறிமுகம் சேருங்கள்.';

  @override
  String get editProfile => 'சுயவிவரத்தைத் திருத்து';

  @override
  String get editPhotos => 'புகைப்படங்களைத் திருத்து';

  @override
  String get about => 'அறிமுகம்';

  @override
  String get interests => 'ஆர்வங்கள்';

  @override
  String lookingFor(String goal) {
    return 'தேடுவது: $goal';
  }

  @override
  String reportName(String name) {
    return '$name-ஐப் புகாரளி';
  }

  @override
  String blockName(String name) {
    return '$name-ஐத் தடு';
  }

  @override
  String blockTitle(String name) {
    return '$name-ஐத் தடுக்கவா?';
  }

  @override
  String get blockMessage =>
      'அவர்களால் உங்கள் சுயவிவரத்தைப் பார்க்கவோ உங்களுக்குச் செய்தி அனுப்பவோ முடியாது.';

  @override
  String get block => 'தடு';

  @override
  String blockedToast(String name) {
    return '$name தடுக்கப்பட்டார்';
  }

  @override
  String get voicePromptTitle => 'உங்கள் குரலில் பதில் சொல்லுங்கள்';

  @override
  String voicePromptSubtitle(int seconds) {
    return 'அதிகபட்சம் $seconds வினாடிகள். உங்கள் குரலைக் கேட்பதுதான் உங்களைத் தெரிந்துகொள்ள வேகமான வழி.';
  }

  @override
  String get tapToRecord => 'பதிவு செய்ய தட்டுங்கள்';

  @override
  String get recordingNow => 'பதிவாகிறது…';

  @override
  String get stopRecording => 'பதிவை நிறுத்து';

  @override
  String get reRecord => 'மீண்டும் பதிவு செய்';

  @override
  String get deleteVoice => 'குரல் பதிவை நீக்கு';

  @override
  String get voiceTooShort => 'மிகவும் சுருக்கம் — இன்னும் கொஞ்சம் பேசுங்கள்';

  @override
  String get micNeeded => 'குரல் பதிவு செய்ய மைக்ரோஃபோன் அனுமதி தேவை.';

  @override
  String get micBlockedTitle => 'மைக்ரோஃபோன் அனுமதி முடக்கப்பட்டுள்ளது';

  @override
  String get micBlockedMessage =>
      'குரல் பதிவுகளுக்கு, அமைப்புகளில் Amour-க்கு மைக்ரோஃபோன் அனுமதியை இயக்குங்கள்.';

  @override
  String get openSettings => 'அமைப்புகளைத் திற';

  @override
  String get recordFailed => 'பதிவு செய்ய முடியவில்லை. மீண்டும் முயலுங்கள்.';

  @override
  String get playVoice => 'குரல் பதிவை இயக்கு';

  @override
  String get pauseVoice => 'குரல் பதிவை இடைநிறுத்து';

  @override
  String get playFailed => 'இந்தக் குரல் பதிவை இயக்க முடியவில்லை.';

  @override
  String get voiceBadge => 'குரல்';

  @override
  String get teaserSubtitle => 'சுருக்கமாக, உண்மையாக, கொஞ்சம் கலகலப்பாக.';

  @override
  String get yourAnswer => 'உங்கள் பதில்';

  @override
  String get captionHint => 'எழுத்தில் பதில் (விருப்பத்தேர்வு)';

  @override
  String get save => 'சேமி';

  @override
  String get changePrompt => 'கேள்வியை மாற்று';

  @override
  String get teaserSaved => 'சேமிக்கப்பட்டது';

  @override
  String get reasonVoice => 'குரல் பதிவு உள்ளது';

  @override
  String get reasonVoiceDetail =>
      'பொருந்தும் முன் இவர் குரலைக் கேளுங்கள் — புகைப்படத்தை விட குரலைப் போலியாக்குவது கடினம்.';

  @override
  String icebreakerVoice(String name) {
    return '$name-இன் குரல் பதிவு';
  }
}
