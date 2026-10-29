// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get language => 'भाषा';

  @override
  String get appLanguage => 'ऐप की भाषा';

  @override
  String get appLanguageSubtitle =>
      'Amour अंग्रेज़ी, तमिल, मलयालम और हिन्दी में उपलब्ध है।';

  @override
  String get deviceLanguage => 'फ़ोन की भाषा';

  @override
  String get deviceLanguageSubtitle => 'अपने फ़ोन की सेटिंग के अनुसार';

  @override
  String addedSpokenLanguage(String language) {
    return '$language को ‘मेरी भाषाएँ’ में जोड़ा गया';
  }

  @override
  String get languagesISpeak => 'मेरी भाषाएँ';

  @override
  String get languagesEditTitle => 'आप कौन-कौन सी भाषाएँ बोलते हैं?';

  @override
  String get languagesEditSubtitle =>
      'हम आपको ऐसे और लोग दिखाएँगे जिनसे आप दिल खोलकर बात कर सकें।';

  @override
  String speaks(String languages) {
    return 'भाषाएँ: $languages';
  }

  @override
  String selectedCount(int count) {
    return '$count चुनी गईं';
  }

  @override
  String get appTagline => 'सार्थक रिश्ते, सोच-समझकर बनाए गए।';

  @override
  String get welcomeTitle => 'अपना हमसफ़र खोजें';

  @override
  String get welcomeSubtitle =>
      'उस समुदाय से जुड़ें जो इरादे के साथ डेट करता है।';

  @override
  String get createAccount => 'खाता बनाएँ';

  @override
  String get signIn => 'साइन इन करें';

  @override
  String get termsNotice =>
      'आगे बढ़कर आप हमारी शर्तों और गोपनीयता नीति से सहमत होते हैं।';

  @override
  String get signInTitle => 'फिर से स्वागत है';

  @override
  String get signInSubtitle => 'जारी रखने के लिए अपने ईमेल से साइन इन करें।';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordHint => 'कम से कम 8 अक्षर';

  @override
  String get errEmail => 'सही ईमेल पता दर्ज करें';

  @override
  String get errPassword => 'पासवर्ड कम से कम 8 अक्षरों का होना चाहिए';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get resetComingSoon => 'पासवर्ड रीसेट जल्द आ रहा है';

  @override
  String get newToAmour => 'Amour पर नए हैं?';

  @override
  String get createTitle => 'अपना खाता बनाएँ';

  @override
  String get createSubtitle => 'बस कुछ जानकारी और आप तैयार हैं।';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get nameHint => 'आपका नाम';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get confirmPasswordHint => 'पासवर्ड दोबारा दर्ज करें';

  @override
  String get errName => 'अपना नाम दर्ज करें';

  @override
  String get errPasswordMismatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String agreeTerms(String terms, String privacy) {
    return 'मैं $terms और $privacy से सहमत हूँ';
  }

  @override
  String get terms => 'शर्तों';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get accountCreated => 'खाता बन गया — चलिए आपकी प्रोफ़ाइल सेट करें';

  @override
  String get haveAccount => 'पहले से खाता है?';

  @override
  String get tabDiscover => 'खोजें';

  @override
  String get tabMatches => 'मैच';

  @override
  String get tabChats => 'चैट';

  @override
  String get tabProfile => 'प्रोफ़ाइल';

  @override
  String get saved => 'सेव किए गए';

  @override
  String get preferences => 'पसंद';

  @override
  String get caughtUpTitle => 'अभी के लिए बस इतना ही';

  @override
  String get caughtUpMessage =>
      'आस-पास के नए लोगों के लिए जल्द फिर देखें, या अपनी पसंद का दायरा बढ़ाएँ।';

  @override
  String get editPreferences => 'पसंद बदलें';

  @override
  String superCrushSent(String name, int count) {
    return '$name को SuperCrush भेजा गया · $count बचे';
  }

  @override
  String get rewind => 'वापस लें';

  @override
  String get pass => 'छोड़ें';

  @override
  String get like => 'पसंद';

  @override
  String kmAway(int km) {
    return '$km कि.मी. दूर';
  }

  @override
  String get stampLike => 'पसंद';

  @override
  String get stampNope => 'नहीं';

  @override
  String percentMatch(int percent) {
    return '$percent% मैच';
  }

  @override
  String get ringMatch => 'मैच';

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get whyYouMatch => 'आपका मैच क्यों है';

  @override
  String matchLabelWith(String label, String name) {
    return '$name के साथ $label';
  }

  @override
  String get matchExceptional => 'बेहतरीन मैच';

  @override
  String get matchGreat => 'शानदार मैच';

  @override
  String get matchGood => 'अच्छा मैच';

  @override
  String get matchWorthALook => 'एक नज़र डालें';

  @override
  String get matchNoReasons =>
      'बेहतर सुझावों के लिए अपनी प्रोफ़ाइल में रुचियाँ, भाषाएँ, रिश्ते के लक्ष्य और जीवनशैली जोड़ें।';

  @override
  String get picksGetSmarter =>
      'आप जितना पसंद करेंगे, छोड़ेंगे और सेव करेंगे, सुझाव उतने बेहतर होंगे।';

  @override
  String youAndName(String name) {
    return 'आप और $name';
  }

  @override
  String get saveProfile => 'प्रोफ़ाइल सेव करें';

  @override
  String get removeFromSaved => 'सेव से हटाएँ';

  @override
  String savedToast(String name) {
    return '$name को सेव किया · आपको ऐसे और लोग दिखेंगे';
  }

  @override
  String removedToast(String name) {
    return '$name को सेव से हटाया गया';
  }

  @override
  String listAnd(String first, String last) {
    return '$first और $last';
  }

  @override
  String reasonInterestsFew(String list) {
    return 'आप दोनों को $list पसंद है';
  }

  @override
  String get reasonInterestsFewDetail => 'पहली बातचीत शुरू करने का आसान तरीका।';

  @override
  String reasonInterestsMany(int count) {
    return '$count रुचियाँ एक जैसी';
  }

  @override
  String reasonInterestsManyDetail(String list) {
    return '$list आप दोनों की प्रोफ़ाइल पर हैं।';
  }

  @override
  String get reasonGoalsSame => 'रिश्ते के लक्ष्य एक जैसे';

  @override
  String reasonGoalsSameDetail(String goal) {
    return 'आप दोनों ढूँढ रहे हैं: $goal।';
  }

  @override
  String get reasonGoalsSimilar => 'मिलते-जुलते रिश्ते के लक्ष्य';

  @override
  String reasonGoalsSimilarDetail(String mine, String name, String theirs) {
    return 'आप: $mine · $name: $theirs।';
  }

  @override
  String reasonLanguages(String languages) {
    return 'आप दोनों $languages बोलते हैं';
  }

  @override
  String get reasonLanguagesDetail =>
      'उस भाषा में बात करें जिसमें आप सबसे सहज हैं।';

  @override
  String get reasonLifestyle => 'मिलती-जुलती जीवनशैली';

  @override
  String reasonLifestyleDetail(String topics) {
    return '$topics पर एक जैसे जवाब।';
  }

  @override
  String get reasonPreferences => 'आपकी पसंद के अनुसार';

  @override
  String reasonPreferencesDetail(String topics) {
    return '$topics के लिए आपकी पसंद से मेल खाता है।';
  }

  @override
  String reasonSameCity(String city) {
    return '$city में ही';
  }

  @override
  String reasonSameCityDetail(int km) {
    return '$km कि.मी. दूर — मिलना आसान।';
  }

  @override
  String get reasonNearby => 'पास में रहते हैं';

  @override
  String reasonNearbyDetail(int km, String city) {
    return '$city में, $km कि.मी. दूर।';
  }

  @override
  String get reasonTaste => 'आपके टाइप के';

  @override
  String reasonTasteDetail(String list) {
    return 'उन लोगों जैसे जिन्हें आपने पसंद किया और जिन्हें $list पसंद है।';
  }

  @override
  String get reasonVerified => 'सत्यापित प्रोफ़ाइल';

  @override
  String get reasonVerifiedDetail =>
      'फ़ोटो सत्यापित है — वे वही हैं जो वे कहते हैं।';

  @override
  String get topicKids => 'बच्चे';

  @override
  String get topicSmoking => 'धूम्रपान';

  @override
  String get topicSport => 'खेल';

  @override
  String get topicDrinking => 'शराब';

  @override
  String get topicFood => 'खान-पान';

  @override
  String get itsAMatch => 'मैच हो गया!';

  @override
  String likeEachOther(String name) {
    return 'आप और $name एक-दूसरे को पसंद करते हैं।';
  }

  @override
  String get sendMessage => 'मैसेज भेजें';

  @override
  String get keepDiscovering => 'खोजते रहें';

  @override
  String get newMatches => 'नए मैच';

  @override
  String get conversations => 'बातचीत';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get recentlyActive => 'हाल ही में सक्रिय';

  @override
  String get message => 'मैसेज';

  @override
  String get betterThanHey => '“हाय” से बेहतर कुछ कहें';

  @override
  String get send => 'भेजें';

  @override
  String matchedWith(String name) {
    return '$name के साथ आपका मैच हुआ';
  }

  @override
  String get icebreakers => 'बातचीत शुरू करें';

  @override
  String get icebreakersSubtitle =>
      'जो आपमें एक जैसा है, वहीं से शुरू करें। भेजने से पहले बदलने के लिए किसी पर टैप करें।';

  @override
  String get moreIdeas => 'और सुझाव';

  @override
  String useIcebreaker(String text) {
    return 'यह इस्तेमाल करें: $text';
  }

  @override
  String icebreakerTaste(String name, String interest) {
    return '$name को $interest पसंद है';
  }

  @override
  String icebreakerTheirInterest(String name, String interest) {
    return '$name को $interest बहुत पसंद है';
  }

  @override
  String icebreakerJob(String name, String job) {
    return '$name $job हैं';
  }

  @override
  String icebreakerJobLine(String job) {
    return '$job होने में सबसे अच्छी बात क्या है?';
  }

  @override
  String icebreakerInterestFallback1(String interest) {
    return '$interest में आपकी दिलचस्पी कैसे हुई?';
  }

  @override
  String icebreakerInterestFallback2(String interest) {
    return '$interest में आपको सबसे ज़्यादा क्या पसंद है?';
  }

  @override
  String get resetPicksTitle => 'सुझाव रीसेट करें?';

  @override
  String get resetPicksMessage =>
      'Amour आपकी पसंद, छोड़े गए लोग और SuperCrush भूल जाएगा। सेव की गई प्रोफ़ाइल बनी रहेंगी।';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get picksReset => 'आपके सुझाव रीसेट हो गए';

  @override
  String get savedProfiles => 'सेव की गई प्रोफ़ाइल';

  @override
  String get nothingSaved => 'अभी कुछ सेव नहीं किया';

  @override
  String get nothingSavedMessage =>
      'किसी प्रोफ़ाइल को यहाँ रखने के लिए बुकमार्क पर टैप करें। सेव करने से Amour को पता चलता है कि आपको किस तरह के लोग ज़्यादा दिखाने हैं।';

  @override
  String get yourPicks => 'आपके सुझाव';

  @override
  String get yourPicksBody =>
      'खोजें पेज आपकी प्रोफ़ाइल, आपकी पसंद और आप किसे पसंद करते, छोड़ते और सेव करते हैं, इसके आधार पर क्रम में लगता है।';

  @override
  String get liked => 'पसंद किए';

  @override
  String get skipped => 'छोड़े';

  @override
  String get drawnTo => 'आपको ये पसंद आते हैं';

  @override
  String get resetPicks => 'सुझाव रीसेट करें';

  @override
  String get settings => 'सेटिंग';

  @override
  String get sectionAccount => 'खाता';

  @override
  String get sectionDiscovery => 'खोज';

  @override
  String get sectionPrivacy => 'गोपनीयता और सुरक्षा';

  @override
  String get sectionNotifications => 'सूचनाएँ';

  @override
  String get sectionGeneral => 'सामान्य';

  @override
  String get hapticFeedback => 'हैप्टिक फ़ीडबैक';

  @override
  String get sectionSupport => 'सहायता';

  @override
  String get personalDetails => 'निजी जानकारी';

  @override
  String get emailAndPhone => 'ईमेल और फ़ोन';

  @override
  String get blockedProfiles => 'ब्लॉक की गई प्रोफ़ाइल';

  @override
  String blockedCount(int count) {
    return '$count ब्लॉक';
  }

  @override
  String get safetyCentre => 'सुरक्षा केंद्र';

  @override
  String get help => 'मदद';

  @override
  String get termsAndPrivacy => 'शर्तें और गोपनीयता';

  @override
  String get showMeInDiscover => 'खोजें में मुझे दिखाएँ';

  @override
  String get showOnlineStatus => 'ऑनलाइन स्टेटस दिखाएँ';

  @override
  String get messages => 'मैसेज';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get signOutTitle => 'साइन आउट करें?';

  @override
  String get signOutMessage => 'आप कभी भी फिर से साइन इन कर सकते हैं।';

  @override
  String get deleteAccount => 'खाता हटाएँ';

  @override
  String version(String version) {
    return 'वर्ज़न $version';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get back => 'वापस';

  @override
  String get more => 'और';

  @override
  String get add => 'जोड़ें';

  @override
  String get edit => 'बदलें';

  @override
  String get profileStrength => 'प्रोफ़ाइल की मज़बूती';

  @override
  String get myPhotos => 'मेरी फ़ोटो';

  @override
  String get manage => 'प्रबंधित करें';

  @override
  String get managePhotos => 'फ़ोटो प्रबंधित करें';

  @override
  String get aboutMe => 'मेरे बारे में';

  @override
  String get addBioHint => 'अपने बारे में बताने के लिए एक छोटा परिचय जोड़ें।';

  @override
  String get editProfile => 'प्रोफ़ाइल बदलें';

  @override
  String get editPhotos => 'फ़ोटो बदलें';

  @override
  String get about => 'परिचय';

  @override
  String get interests => 'रुचियाँ';

  @override
  String lookingFor(String goal) {
    return 'तलाश: $goal';
  }

  @override
  String reportName(String name) {
    return '$name की शिकायत करें';
  }

  @override
  String blockName(String name) {
    return '$name को ब्लॉक करें';
  }

  @override
  String blockTitle(String name) {
    return '$name को ब्लॉक करें?';
  }

  @override
  String get blockMessage =>
      'वे आपकी प्रोफ़ाइल नहीं देख पाएँगे और न ही आपको मैसेज कर पाएँगे।';

  @override
  String get block => 'ब्लॉक करें';

  @override
  String blockedToast(String name) {
    return '$name को ब्लॉक कर दिया गया';
  }

  @override
  String get voicePromptTitle => 'अपनी आवाज़ में जवाब दें';

  @override
  String voicePromptSubtitle(int seconds) {
    return 'ज़्यादा से ज़्यादा $seconds सेकंड। आपकी आवाज़ सुनना आपको जानने का सबसे तेज़ तरीका है।';
  }

  @override
  String get tapToRecord => 'रिकॉर्ड करने के लिए टैप करें';

  @override
  String get recordingNow => 'रिकॉर्ड हो रहा है…';

  @override
  String get stopRecording => 'रिकॉर्डिंग रोकें';

  @override
  String get reRecord => 'फिर से रिकॉर्ड करें';

  @override
  String get deleteVoice => 'वॉइस नोट हटाएँ';

  @override
  String get voiceTooShort => 'बहुत छोटा है — थोड़ा और बोलिए';

  @override
  String get micNeeded =>
      'वॉइस प्रॉम्प्ट रिकॉर्ड करने के लिए माइक्रोफ़ोन की अनुमति चाहिए।';

  @override
  String get micBlockedTitle => 'माइक्रोफ़ोन की अनुमति बंद है';

  @override
  String get micBlockedMessage =>
      'वॉइस प्रॉम्प्ट रिकॉर्ड करने के लिए सेटिंग में Amour को माइक्रोफ़ोन की अनुमति दें।';

  @override
  String get openSettings => 'सेटिंग खोलें';

  @override
  String get recordFailed => 'रिकॉर्ड नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get playVoice => 'वॉइस प्रॉम्प्ट चलाएँ';

  @override
  String get pauseVoice => 'वॉइस प्रॉम्प्ट रोकें';

  @override
  String get playFailed => 'यह वॉइस नोट नहीं चल सका।';

  @override
  String get voiceBadge => 'आवाज़';

  @override
  String get teaserSubtitle => 'छोटा, सच्चा और थोड़ा मज़ेदार रखें।';

  @override
  String get yourAnswer => 'आपका जवाब';

  @override
  String get captionHint => 'लिखित जवाब (वैकल्पिक)';

  @override
  String get save => 'सेव करें';

  @override
  String get changePrompt => 'सवाल बदलें';

  @override
  String get teaserSaved => 'सेव हो गया';

  @override
  String get reasonVoice => 'वॉइस प्रॉम्प्ट रिकॉर्ड किया है';

  @override
  String get reasonVoiceDetail =>
      'मैच करने से पहले उनकी आवाज़ सुनें — फ़ोटो के मुकाबले आवाज़ की नकल करना कहीं मुश्किल है।';

  @override
  String icebreakerVoice(String name) {
    return '$name का वॉइस प्रॉम्प्ट';
  }
}
