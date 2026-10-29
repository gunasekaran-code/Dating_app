// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malayalam (`ml`).
class AppLocalizationsMl extends AppLocalizations {
  AppLocalizationsMl([String locale = 'ml']) : super(locale);

  @override
  String get language => 'ഭാഷ';

  @override
  String get appLanguage => 'ആപ്പ് ഭാഷ';

  @override
  String get appLanguageSubtitle =>
      'Amour ഇംഗ്ലീഷ്, തമിഴ്, മലയാളം, ഹിന്ദി എന്നീ ഭാഷകളിൽ ലഭ്യമാണ്.';

  @override
  String get deviceLanguage => 'ഫോണിന്റെ ഭാഷ';

  @override
  String get deviceLanguageSubtitle => 'ഫോണിന്റെ ക്രമീകരണം പിന്തുടരുക';

  @override
  String addedSpokenLanguage(String language) {
    return 'ഞാൻ സംസാരിക്കുന്ന ഭാഷകളിൽ $language ചേർത്തു';
  }

  @override
  String get languagesISpeak => 'ഞാൻ സംസാരിക്കുന്ന ഭാഷകൾ';

  @override
  String get languagesEditTitle => 'നിങ്ങൾ ഏതൊക്കെ ഭാഷകൾ സംസാരിക്കും?';

  @override
  String get languagesEditSubtitle =>
      'നിങ്ങൾക്ക് മനസ്സുതുറന്ന് സംസാരിക്കാൻ കഴിയുന്നവരെ കൂടുതൽ കാണിക്കാം.';

  @override
  String speaks(String languages) {
    return 'ഭാഷകൾ: $languages';
  }

  @override
  String selectedCount(int count) {
    return '$count തിരഞ്ഞെടുത്തു';
  }

  @override
  String get appTagline => 'അർത്ഥവത്തായ ബന്ധങ്ങൾ, കരുതലോടെ ഒരുക്കിയത്.';

  @override
  String get welcomeTitle => 'നിങ്ങളുടെ പങ്കാളിയെ കണ്ടെത്തൂ';

  @override
  String get welcomeSubtitle =>
      'ലക്ഷ്യബോധത്തോടെ ഡേറ്റ് ചെയ്യുന്ന ഒരു കൂട്ടായ്മയിൽ ചേരൂ.';

  @override
  String get createAccount => 'അക്കൗണ്ട് സൃഷ്ടിക്കുക';

  @override
  String get signIn => 'സൈൻ ഇൻ ചെയ്യുക';

  @override
  String get termsNotice =>
      'തുടരുന്നതിലൂടെ ഞങ്ങളുടെ നിബന്ധനകളും സ്വകാര്യതാ നയവും നിങ്ങൾ അംഗീകരിക്കുന്നു.';

  @override
  String get signInTitle => 'വീണ്ടും സ്വാഗതം';

  @override
  String get signInSubtitle =>
      'തുടരാൻ നിങ്ങളുടെ ഇമെയിൽ ഉപയോഗിച്ച് സൈൻ ഇൻ ചെയ്യുക.';

  @override
  String get email => 'ഇമെയിൽ';

  @override
  String get password => 'പാസ്‌വേഡ്';

  @override
  String get passwordHint => 'കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ';

  @override
  String get errEmail => 'സാധുവായ ഒരു ഇമെയിൽ വിലാസം നൽകുക';

  @override
  String get errPassword => 'പാസ്‌വേഡിന് കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ വേണം';

  @override
  String get forgotPassword => 'പാസ്‌വേഡ് മറന്നോ?';

  @override
  String get resetComingSoon => 'പാസ്‌വേഡ് റീസെറ്റ് ഉടൻ വരുന്നു';

  @override
  String get newToAmour => 'Amour-ൽ പുതിയതാണോ?';

  @override
  String get createTitle => 'നിങ്ങളുടെ അക്കൗണ്ട് സൃഷ്ടിക്കൂ';

  @override
  String get createSubtitle => 'കുറച്ച് വിവരങ്ങൾ മതി, നിങ്ങൾ റെഡി.';

  @override
  String get fullName => 'മുഴുവൻ പേര്';

  @override
  String get nameHint => 'നിങ്ങളുടെ പേര്';

  @override
  String get confirmPassword => 'പാസ്‌വേഡ് സ്ഥിരീകരിക്കുക';

  @override
  String get confirmPasswordHint => 'പാസ്‌വേഡ് വീണ്ടും നൽകുക';

  @override
  String get errName => 'നിങ്ങളുടെ പേര് നൽകുക';

  @override
  String get errPasswordMismatch => 'പാസ്‌വേഡുകൾ ഒത്തുപോകുന്നില്ല';

  @override
  String agreeTerms(String terms, String privacy) {
    return '$terms, $privacy എന്നിവ ഞാൻ അംഗീകരിക്കുന്നു';
  }

  @override
  String get terms => 'നിബന്ധനകൾ';

  @override
  String get privacyPolicy => 'സ്വകാര്യതാ നയം';

  @override
  String get accountCreated =>
      'അക്കൗണ്ട് സൃഷ്ടിച്ചു — നമുക്ക് പ്രൊഫൈൽ ഒരുക്കാം';

  @override
  String get haveAccount => 'ഇതിനകം അക്കൗണ്ട് ഉണ്ടോ?';

  @override
  String get tabDiscover => 'കണ്ടെത്തുക';

  @override
  String get tabMatches => 'മാച്ചുകൾ';

  @override
  String get tabChats => 'ചാറ്റുകൾ';

  @override
  String get tabProfile => 'പ്രൊഫൈൽ';

  @override
  String get saved => 'സേവ് ചെയ്തവ';

  @override
  String get preferences => 'മുൻഗണനകൾ';

  @override
  String get caughtUpTitle => 'ഇപ്പോഴത്തേക്ക് ഇത്രമാത്രം';

  @override
  String get caughtUpMessage =>
      'സമീപത്തുള്ള പുതിയ ആളുകൾക്കായി ഉടൻ വീണ്ടും നോക്കൂ, അല്ലെങ്കിൽ നിങ്ങളുടെ മുൻഗണനകൾ വിപുലമാക്കൂ.';

  @override
  String get editPreferences => 'മുൻഗണനകൾ മാറ്റുക';

  @override
  String superCrushSent(String name, int count) {
    return '$name-ന് SuperCrush അയച്ചു · $count ബാക്കി';
  }

  @override
  String get rewind => 'തിരികെ';

  @override
  String get pass => 'ഒഴിവാക്കുക';

  @override
  String get like => 'ഇഷ്ടം';

  @override
  String kmAway(int km) {
    return '$km കി.മീ. അകലെ';
  }

  @override
  String get stampLike => 'ഇഷ്ടം';

  @override
  String get stampNope => 'വേണ്ട';

  @override
  String percentMatch(int percent) {
    return '$percent% മാച്ച്';
  }

  @override
  String get ringMatch => 'മാച്ച്';

  @override
  String get verify => 'പരിശോധിക്കുക';

  @override
  String get whyYouMatch => 'നിങ്ങൾ എന്തുകൊണ്ട് ചേരുന്നു';

  @override
  String matchLabelWith(String label, String name) {
    return '$name-മായി $label';
  }

  @override
  String get matchExceptional => 'അസാധാരണ മാച്ച്';

  @override
  String get matchGreat => 'മികച്ച മാച്ച്';

  @override
  String get matchGood => 'നല്ല മാച്ച്';

  @override
  String get matchWorthALook => 'ഒന്ന് നോക്കാവുന്നത്';

  @override
  String get matchNoReasons =>
      'മികച്ച നിർദ്ദേശങ്ങൾക്കായി പ്രൊഫൈലിൽ താൽപ്പര്യങ്ങൾ, ഭാഷകൾ, ബന്ധ ലക്ഷ്യങ്ങൾ, ജീവിതശൈലി എന്നിവ ചേർക്കുക.';

  @override
  String get picksGetSmarter =>
      'നിങ്ങൾ ഇഷ്ടപ്പെടുകയും ഒഴിവാക്കുകയും സേവ് ചെയ്യുകയും ചെയ്യുന്തോറും നിർദ്ദേശങ്ങൾ മെച്ചപ്പെടും.';

  @override
  String youAndName(String name) {
    return 'നിങ്ങളും $name-ഉം';
  }

  @override
  String get saveProfile => 'പ്രൊഫൈൽ സേവ് ചെയ്യുക';

  @override
  String get removeFromSaved => 'സേവ് ചെയ്തവയിൽ നിന്ന് നീക്കുക';

  @override
  String savedToast(String name) {
    return '$name-നെ സേവ് ചെയ്തു · ഇതുപോലുള്ളവരെ കൂടുതൽ കാണാം';
  }

  @override
  String removedToast(String name) {
    return '$name-നെ സേവ് ചെയ്തവയിൽ നിന്ന് നീക്കി';
  }

  @override
  String listAnd(String first, String last) {
    return '$first, $last';
  }

  @override
  String reasonInterestsFew(String list) {
    return 'നിങ്ങൾ രണ്ടുപേർക്കും $list ഇഷ്ടമാണ്';
  }

  @override
  String get reasonInterestsFewDetail => 'ആദ്യ സംഭാഷണം തുടങ്ങാൻ എളുപ്പവഴി.';

  @override
  String reasonInterestsMany(int count) {
    return '$count പൊതു താൽപ്പര്യങ്ങൾ';
  }

  @override
  String reasonInterestsManyDetail(String list) {
    return '$list — ഇവ രണ്ടുപേരുടെയും പ്രൊഫൈലിലുണ്ട്.';
  }

  @override
  String get reasonGoalsSame => 'ഒരേ ബന്ധ ലക്ഷ്യങ്ങൾ';

  @override
  String reasonGoalsSameDetail(String goal) {
    return 'നിങ്ങൾ രണ്ടുപേരും തേടുന്നത്: $goal.';
  }

  @override
  String get reasonGoalsSimilar => 'സമാനമായ ബന്ധ ലക്ഷ്യങ്ങൾ';

  @override
  String reasonGoalsSimilarDetail(String mine, String name, String theirs) {
    return 'നിങ്ങൾ: $mine · $name: $theirs.';
  }

  @override
  String reasonLanguages(String languages) {
    return 'നിങ്ങൾ രണ്ടുപേരും $languages സംസാരിക്കും';
  }

  @override
  String get reasonLanguagesDetail =>
      'നിങ്ങൾക്ക് ഏറ്റവും സൗകര്യമുള്ള ഭാഷയിൽ ചാറ്റ് ചെയ്യൂ.';

  @override
  String get reasonLifestyle => 'സമാനമായ ജീവിതശൈലി';

  @override
  String reasonLifestyleDetail(String topics) {
    return '$topics എന്നിവയിൽ ഒരേ ഉത്തരങ്ങൾ.';
  }

  @override
  String get reasonPreferences => 'നിങ്ങളുടെ മുൻഗണനകൾക്ക് ചേരുന്നു';

  @override
  String reasonPreferencesDetail(String topics) {
    return '$topics എന്നിവയ്ക്ക് നിങ്ങൾ തിരഞ്ഞെടുത്തതുമായി ചേരുന്നു.';
  }

  @override
  String reasonSameCity(String city) {
    return 'ഇവരും $city-ൽ';
  }

  @override
  String reasonSameCityDetail(int km) {
    return '$km കി.മീ. അകലെ — കണ്ടുമുട്ടാൻ എളുപ്പം.';
  }

  @override
  String get reasonNearby => 'സമീപത്ത് താമസിക്കുന്നു';

  @override
  String reasonNearbyDetail(int km, String city) {
    return '$city-ൽ, $km കി.മീ. അകലെ.';
  }

  @override
  String get reasonTaste => 'നിങ്ങളുടെ ടൈപ്പ്';

  @override
  String reasonTasteDetail(String list) {
    return '$list ഇഷ്ടപ്പെടുന്ന, നിങ്ങൾ ലൈക്ക് ചെയ്തവരെപ്പോലെ.';
  }

  @override
  String get reasonVerified => 'പരിശോധിച്ച പ്രൊഫൈൽ';

  @override
  String get reasonVerifiedDetail =>
      'ഫോട്ടോ പരിശോധിച്ചതാണ് — പറയുന്ന ആൾ തന്നെ.';

  @override
  String get topicKids => 'കുട്ടികൾ';

  @override
  String get topicSmoking => 'പുകവലി';

  @override
  String get topicSport => 'കായികം';

  @override
  String get topicDrinking => 'മദ്യപാനം';

  @override
  String get topicFood => 'ഭക്ഷണശീലം';

  @override
  String get itsAMatch => 'മാച്ചായി!';

  @override
  String likeEachOther(String name) {
    return 'നിങ്ങളും $name-ഉം പരസ്പരം ഇഷ്ടപ്പെടുന്നു.';
  }

  @override
  String get sendMessage => 'മെസേജ് അയയ്ക്കുക';

  @override
  String get keepDiscovering => 'കണ്ടെത്തൽ തുടരുക';

  @override
  String get newMatches => 'പുതിയ മാച്ചുകൾ';

  @override
  String get conversations => 'സംഭാഷണങ്ങൾ';

  @override
  String get online => 'ഓൺലൈനിൽ';

  @override
  String get recentlyActive => 'അടുത്തിടെ സജീവം';

  @override
  String get message => 'മെസേജ്';

  @override
  String get betterThanHey => '“ഹായ്”-നേക്കാൾ നല്ലതെന്തെങ്കിലും പറയൂ';

  @override
  String get send => 'അയയ്ക്കുക';

  @override
  String matchedWith(String name) {
    return '$name-മായി മാച്ചായി';
  }

  @override
  String get icebreakers => 'സംസാരം തുടങ്ങാൻ';

  @override
  String get icebreakersSubtitle =>
      'പൊതുവായ കാര്യത്തിൽ നിന്ന് തുടങ്ങൂ. അയയ്ക്കും മുൻപ് മാറ്റാൻ ഒന്നിൽ ടാപ്പ് ചെയ്യൂ.';

  @override
  String get moreIdeas => 'കൂടുതൽ ആശയങ്ങൾ';

  @override
  String useIcebreaker(String text) {
    return 'ഇത് ഉപയോഗിക്കുക: $text';
  }

  @override
  String icebreakerTaste(String name, String interest) {
    return '$name-ന് $interest ഇഷ്ടമാണ്';
  }

  @override
  String icebreakerTheirInterest(String name, String interest) {
    return '$name-ന് $interest വളരെ ഇഷ്ടമാണ്';
  }

  @override
  String icebreakerJob(String name, String job) {
    return '$name ഒരു $job ആണ്';
  }

  @override
  String icebreakerJobLine(String job) {
    return 'ഒരു $job ആയിരിക്കുന്നതിൽ ഏറ്റവും ഇഷ്ടം എന്താണ്?';
  }

  @override
  String icebreakerInterestFallback1(String interest) {
    return '$interest-ൽ താൽപ്പര്യം എങ്ങനെ വന്നു?';
  }

  @override
  String icebreakerInterestFallback2(String interest) {
    return '$interest-ൽ ഏറ്റവും ഇഷ്ടം എന്താണ്?';
  }

  @override
  String get resetPicksTitle => 'നിർദ്ദേശങ്ങൾ റീസെറ്റ് ചെയ്യണോ?';

  @override
  String get resetPicksMessage =>
      'നിങ്ങളുടെ ലൈക്കുകളും ഒഴിവാക്കലുകളും SuperCrush-കളും Amour മറക്കും. സേവ് ചെയ്ത പ്രൊഫൈലുകൾ നിലനിൽക്കും.';

  @override
  String get reset => 'റീസെറ്റ്';

  @override
  String get picksReset => 'നിങ്ങളുടെ നിർദ്ദേശങ്ങൾ റീസെറ്റ് ചെയ്തു';

  @override
  String get savedProfiles => 'സേവ് ചെയ്ത പ്രൊഫൈലുകൾ';

  @override
  String get nothingSaved => 'ഇതുവരെ ഒന്നും സേവ് ചെയ്തിട്ടില്ല';

  @override
  String get nothingSavedMessage =>
      'ഒരു പ്രൊഫൈൽ ഇവിടെ സൂക്ഷിക്കാൻ ബുക്ക്മാർക്കിൽ ടാപ്പ് ചെയ്യൂ. ആരെയാണ് കൂടുതൽ കാണിക്കേണ്ടതെന്ന് ഇത് Amour-നെ അറിയിക്കും.';

  @override
  String get yourPicks => 'നിങ്ങൾക്കുള്ള നിർദ്ദേശങ്ങൾ';

  @override
  String get yourPicksBody =>
      'നിങ്ങളുടെ പ്രൊഫൈൽ, മുൻഗണനകൾ, നിങ്ങൾ ലൈക്ക് ചെയ്യുന്നവർ, ഒഴിവാക്കുന്നവർ, സേവ് ചെയ്യുന്നവർ എന്നിവ അനുസരിച്ചാണ് കണ്ടെത്തുക ക്രമീകരിക്കുന്നത്.';

  @override
  String get liked => 'ഇഷ്ടപ്പെട്ടവ';

  @override
  String get skipped => 'ഒഴിവാക്കിയവ';

  @override
  String get drawnTo => 'നിങ്ങളെ ആകർഷിക്കുന്നത്';

  @override
  String get resetPicks => 'നിർദ്ദേശങ്ങൾ റീസെറ്റ് ചെയ്യുക';

  @override
  String get settings => 'ക്രമീകരണങ്ങൾ';

  @override
  String get sectionAccount => 'അക്കൗണ്ട്';

  @override
  String get sectionDiscovery => 'കണ്ടെത്തൽ';

  @override
  String get sectionPrivacy => 'സ്വകാര്യതയും സുരക്ഷയും';

  @override
  String get sectionNotifications => 'അറിയിപ്പുകൾ';

  @override
  String get sectionGeneral => 'പൊതുവായവ';

  @override
  String get hapticFeedback => 'ഹാപ്റ്റിക് ഫീഡ്ബാക്ക്';

  @override
  String get sectionSupport => 'പിന്തുണ';

  @override
  String get personalDetails => 'വ്യക്തിഗത വിവരങ്ങൾ';

  @override
  String get emailAndPhone => 'ഇമെയിലും ഫോണും';

  @override
  String get blockedProfiles => 'ബ്ലോക്ക് ചെയ്ത പ്രൊഫൈലുകൾ';

  @override
  String blockedCount(int count) {
    return '$count ബ്ലോക്ക് ചെയ്തു';
  }

  @override
  String get safetyCentre => 'സുരക്ഷാ കേന്ദ്രം';

  @override
  String get help => 'സഹായം';

  @override
  String get termsAndPrivacy => 'നിബന്ധനകളും സ്വകാര്യതയും';

  @override
  String get showMeInDiscover => 'കണ്ടെത്തുകയിൽ എന്നെ കാണിക്കുക';

  @override
  String get showOnlineStatus => 'ഓൺലൈൻ സ്റ്റാറ്റസ് കാണിക്കുക';

  @override
  String get messages => 'മെസേജുകൾ';

  @override
  String get signOut => 'സൈൻ ഔട്ട് ചെയ്യുക';

  @override
  String get signOutTitle => 'സൈൻ ഔട്ട് ചെയ്യണോ?';

  @override
  String get signOutMessage => 'എപ്പോൾ വേണമെങ്കിലും വീണ്ടും സൈൻ ഇൻ ചെയ്യാം.';

  @override
  String get deleteAccount => 'അക്കൗണ്ട് ഇല്ലാതാക്കുക';

  @override
  String version(String version) {
    return 'പതിപ്പ് $version';
  }

  @override
  String get cancel => 'റദ്ദാക്കുക';

  @override
  String get back => 'തിരികെ';

  @override
  String get more => 'കൂടുതൽ';

  @override
  String get add => 'ചേർക്കുക';

  @override
  String get edit => 'മാറ്റുക';

  @override
  String get profileStrength => 'പ്രൊഫൈൽ കരുത്ത്';

  @override
  String get myPhotos => 'എന്റെ ഫോട്ടോകൾ';

  @override
  String get manage => 'നിയന്ത്രിക്കുക';

  @override
  String get managePhotos => 'ഫോട്ടോകൾ നിയന്ത്രിക്കുക';

  @override
  String get aboutMe => 'എന്നെക്കുറിച്ച്';

  @override
  String get addBioHint => 'നിങ്ങളെക്കുറിച്ച് പറയാൻ ഒരു ചെറിയ ബയോ ചേർക്കൂ.';

  @override
  String get editProfile => 'പ്രൊഫൈൽ മാറ്റുക';

  @override
  String get editPhotos => 'ഫോട്ടോകൾ മാറ്റുക';

  @override
  String get about => 'ആമുഖം';

  @override
  String get interests => 'താൽപ്പര്യങ്ങൾ';

  @override
  String lookingFor(String goal) {
    return 'തേടുന്നത്: $goal';
  }

  @override
  String reportName(String name) {
    return '$name-നെ റിപ്പോർട്ട് ചെയ്യുക';
  }

  @override
  String blockName(String name) {
    return '$name-നെ ബ്ലോക്ക് ചെയ്യുക';
  }

  @override
  String blockTitle(String name) {
    return '$name-നെ ബ്ലോക്ക് ചെയ്യണോ?';
  }

  @override
  String get blockMessage =>
      'അവർക്ക് നിങ്ങളുടെ പ്രൊഫൈൽ കാണാനോ മെസേജ് അയയ്ക്കാനോ കഴിയില്ല.';

  @override
  String get block => 'ബ്ലോക്ക് ചെയ്യുക';

  @override
  String blockedToast(String name) {
    return '$name-നെ ബ്ലോക്ക് ചെയ്തു';
  }

  @override
  String get voicePromptTitle => 'നിങ്ങളുടെ ശബ്ദത്തിൽ മറുപടി നൽകൂ';

  @override
  String voicePromptSubtitle(int seconds) {
    return 'പരമാവധി $seconds സെക്കൻഡ്. നിങ്ങളുടെ ശബ്ദം കേൾക്കുന്നതാണ് നിങ്ങളെ അറിയാനുള്ള എളുപ്പവഴി.';
  }

  @override
  String get tapToRecord => 'റെക്കോർഡ് ചെയ്യാൻ ടാപ്പ് ചെയ്യൂ';

  @override
  String get recordingNow => 'റെക്കോർഡ് ചെയ്യുന്നു…';

  @override
  String get stopRecording => 'റെക്കോർഡിംഗ് നിർത്തുക';

  @override
  String get reRecord => 'വീണ്ടും റെക്കോർഡ് ചെയ്യുക';

  @override
  String get deleteVoice => 'വോയ്സ് നോട്ട് ഇല്ലാതാക്കുക';

  @override
  String get voiceTooShort => 'വളരെ ചെറുതാണ് — കുറച്ചുകൂടി പറയൂ';

  @override
  String get micNeeded =>
      'വോയ്സ് പ്രോംപ്റ്റ് റെക്കോർഡ് ചെയ്യാൻ മൈക്രോഫോൺ അനുമതി വേണം.';

  @override
  String get micBlockedTitle => 'മൈക്രോഫോൺ അനുമതി ഓഫാണ്';

  @override
  String get micBlockedMessage =>
      'വോയ്സ് പ്രോംപ്റ്റുകൾ റെക്കോർഡ് ചെയ്യാൻ ക്രമീകരണങ്ങളിൽ Amour-ന് മൈക്രോഫോൺ അനുമതി ഓണാക്കൂ.';

  @override
  String get openSettings => 'ക്രമീകരണങ്ങൾ തുറക്കുക';

  @override
  String get recordFailed => 'റെക്കോർഡ് ചെയ്യാനായില്ല. വീണ്ടും ശ്രമിക്കൂ.';

  @override
  String get playVoice => 'വോയ്സ് പ്രോംപ്റ്റ് പ്ലേ ചെയ്യുക';

  @override
  String get pauseVoice => 'വോയ്സ് പ്രോംപ്റ്റ് നിർത്തുക';

  @override
  String get playFailed => 'ഈ വോയ്സ് നോട്ട് പ്ലേ ചെയ്യാനായില്ല.';

  @override
  String get voiceBadge => 'ശബ്ദം';

  @override
  String get teaserSubtitle => 'ചുരുക്കി, സത്യസന്ധമായി, അൽപ്പം രസകരമായി.';

  @override
  String get yourAnswer => 'നിങ്ങളുടെ മറുപടി';

  @override
  String get captionHint => 'എഴുതിയ മറുപടി (ഓപ്ഷണൽ)';

  @override
  String get save => 'സേവ് ചെയ്യുക';

  @override
  String get changePrompt => 'ചോദ്യം മാറ്റുക';

  @override
  String get teaserSaved => 'സേവ് ചെയ്തു';

  @override
  String get reasonVoice => 'വോയ്സ് പ്രോംപ്റ്റ് ഉണ്ട്';

  @override
  String get reasonVoiceDetail =>
      'മാച്ച് ചെയ്യും മുൻപ് ശബ്ദം കേൾക്കൂ — ഫോട്ടോയേക്കാൾ ശബ്ദം വ്യാജമാക്കാൻ പ്രയാസമാണ്.';

  @override
  String icebreakerVoice(String name) {
    return '$name-ന്റെ വോയ്സ് പ്രോംപ്റ്റ്';
  }
}
