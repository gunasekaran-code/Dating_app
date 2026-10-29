import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/match_text.dart';
import 'match_engine.dart';
import 'mock.dart';

/// A suggested opening line and the shared ground it comes from, e.g.
/// "You both love Hiking" → "What’s the best trek you’ve done near Bengaluru?".
class Icebreaker {
  final IconData icon; final String label, text;
  const Icebreaker(this.icon, this.label, this.text);
}

/// Opening lines in one language. `{city}` is the match’s city, `{language}` a language you share.
class _Openers {
  /// Keyed by [MatchEngine.interestKey].
  final Map<String, List<String>> interests, lifestyle;
  final List<String> goals, city, languages, voice;
  const _Openers({required this.interests, required this.lifestyle, required this.goals, required this.city,
      required this.languages, required this.voice});
}

const _en = _Openers(
  interests: {
    'hiking': ['What’s the best trek you’ve done near {city}?', 'Sunrise trek or sunset trail — which one are you?',
      'Which trek is still on your bucket list?'],
    'coffee': ['Where’s your go-to coffee spot in {city}?', 'Filter coffee or a fancy pour-over — be honest.',
      'How many cups before you’re a functioning human?'],
    'travel': ['What’s the next trip on your list?', 'Best place you’ve been that nobody talks about?',
      'Beaches or mountains for a long weekend?'],
    'design': ['What’s a piece of design you secretly love?', 'What are you designing at the moment?'],
    'jazz': ['Who’s the one jazz artist I have to listen to?', 'Any good live jazz in {city}?'],
    'books': ['What are you reading right now?', 'Which book would you make everyone read?'],
    'cooking': ['What’s the dish you’re proudest of?', 'If you cooked me dinner, what would be on the menu?'],
    'yoga': ['Morning yoga person or evening wind-down?', 'Which pose are you still working on?'],
    'dogs': ['Do you have a dog? I need photos.', 'Dream dog breed — go.'],
    'cats': ['Do you have a cat? I need photos.', 'What’s the most chaotic thing a cat has done to you?'],
    'film': ['What’s the last film that really stayed with you?', 'Comfort movie you can rewatch forever?'],
    'photography': ['What’s the last photo you took that you’re proud of?', 'Best spot for golden hour around {city}?'],
    'gaming': ['What are you playing at the moment?', 'Co-op or competitive?'],
    'fitness': ['What does your perfect workout look like?', 'Gym, run or sport — what keeps you going?'],
    'live music': ['Best gig you’ve ever been to?', 'Who would you travel to see live?'],
    'wine': ['Red, white or “whatever’s open”?', 'Best wine you’ve had and where?'],
    'plants': ['How many plants are we talking?', 'Which plant are you most proud of keeping alive?'],
    'cricket': ['Playing or watching — and who’s your team?', 'Test match or T20?'],
    'dancing': ['What’s your dance-floor song?', 'Salsa, Bollywood or freestyle?'],
    'cycling': ['Favourite ride around {city}?', 'Road bike or anything with pedals?'],
    'street food': ['Where do I get the best street food in {city}?', 'What’s your non-negotiable street food order?'],
    'theatre': ['Best play you’ve seen recently?', 'Ever been on stage yourself?'],
    'beaches': ['Favourite beach near {city}?', 'Sunrise swim or sunset walk?'],
    'board games': ['What’s your board game of choice?', 'Are you a gracious winner or a sore loser?'],
    'music': ['What’s on repeat for you this week?', 'Which song would you play me first?'],
    'architecture': ['Which building in {city} do you love most?', 'Old buildings or modern ones?'],
  },
  goals: ['What does a great first date look like to you?',
    'What’s something you’re really looking forward to this year?', 'What made you join Amour?'],
  lifestyle: {
    'Sport': ['Which sport do you play? I might need a partner.', 'Morning workout or evening game?'],
    'Smoking': ['Chai or coffee — what’s your go-to?'],
    'Drinking': ['Chai, coffee or fresh juice — what’s your go-to?', 'What’s your idea of a perfect evening out?'],
    'Food habits': ['What’s one dish you’d cross {city} for?', 'Best meal you’ve had this month?'],
  },
  city: ['What’s one place in {city} everyone should try?', 'Best hidden gem in {city}?',
    'Where would you take someone new to {city}?'],
  languages: ['What’s your favourite {language} film or song?', 'Which {language} word should everyone learn?'],
  voice: ['Just listened to your voice prompt — now I need the full story!',
    'Your voice prompt made me smile. Tell me more?'],
);

const _ta = _Openers(
  interests: {
    'hiking': ['{city} அருகே நீங்க போன சிறந்த ட்ரெக் எது?'],
    'coffee': ['ஃபில்டர் காபியா, டீயா — உங்க சாய்ஸ் என்ன?'],
    'travel': ['அடுத்து எந்த ஊருக்குப் பயணம் போக ஆசை?'],
    'design': ['இப்போ என்ன டிசைன் பண்ணிட்டு இருக்கீங்க?'],
    'jazz': ['நான் கண்டிப்பா கேட்க வேண்டிய ஒரு ஜாஸ் கலைஞர் யார்?'],
    'books': ['இப்போ என்ன புத்தகம் படிச்சிட்டு இருக்கீங்க?'],
    'cooking': ['நீங்க சமைக்கிறதுல உங்க ஸ்பெஷல் டிஷ் எது?'],
    'yoga': ['காலை யோகாவா, மாலை யோகாவா?'],
    'dogs': ['உங்ககிட்ட நாய் இருக்கா? போட்டோ வேணும்!'],
    'cats': ['உங்ககிட்ட பூனை இருக்கா? போட்டோ வேணும்!'],
    'film': ['சமீபத்துல உங்க மனசைத் தொட்ட படம் எது?'],
    'photography': ['சமீபத்துல நீங்க எடுத்ததுல ரொம்பப் பிடிச்ச போட்டோ எது?'],
    'gaming': ['இப்போ என்ன கேம் விளையாடுறீங்க?'],
    'fitness': ['உங்களுக்குப் பிடிச்ச உடற்பயிற்சி எது?'],
    'live music': ['நீங்க பார்த்ததுலேயே சிறந்த கச்சேரி எது?'],
    'wine': ['ரெட் ஒயினா, ஒயிட் ஒயினா?'],
    'plants': ['உங்ககிட்ட எத்தனை செடிகள் இருக்கு?'],
    'cricket': ['விளையாடுவீங்களா, பார்ப்பீங்களா — உங்க டீம் எது?'],
    'dancing': ['உங்களை ஆட வைக்கும் பாட்டு எது?'],
    'cycling': ['{city}-ல உங்களுக்குப் பிடிச்ச சைக்கிள் ரூட் எது?'],
    'street food': ['{city}-ல சிறந்த ஸ்ட்ரீட் ஃபுட் எங்கே கிடைக்கும்?'],
    'theatre': ['சமீபத்துல பார்த்த நல்ல நாடகம் எது?'],
    'beaches': ['{city} பக்கத்துல உங்களுக்குப் பிடிச்ச பீச் எது?'],
    'board games': ['உங்களுக்குப் பிடிச்ச போர்டு கேம் எது?'],
    'music': ['இந்த வாரம் திரும்பத் திரும்பக் கேட்கும் பாட்டு எது?'],
    'architecture': ['{city}-ல உங்களுக்கு ரொம்பப் பிடிச்ச கட்டிடம் எது?'],
  },
  goals: ['உங்களைப் பொறுத்தவரை ஒரு சிறந்த முதல் டேட் எப்படி இருக்கும்?',
    'இந்த வருஷம் நீங்க ஆவலா எதிர்பார்க்கும் விஷயம் என்ன?'],
  lifestyle: {
    'Sport': ['நீங்க என்ன விளையாட்டு விளையாடுவீங்க? எனக்கு ஒரு பார்ட்னர் வேணும்.'],
    'Smoking': ['டீயா, காபியா — உங்க சாய்ஸ் என்ன?'],
    'Drinking': ['உங்களுக்கு ஒரு சிறந்த மாலைப் பொழுது எப்படி இருக்கும்?'],
    'Food habits': ['{city}-ல நீங்க தேடிப் போய் சாப்பிடும் உணவு எது?'],
  },
  city: ['{city}-ல எல்லாரும் கண்டிப்பா போக வேண்டிய இடம் எது?', '{city}-ல பலருக்குத் தெரியாத ஒரு சூப்பர் இடம் சொல்லுங்க?'],
  languages: ['உங்களுக்கு ரொம்பப் பிடிச்ச {language} படம் அல்லது பாட்டு எது?'],
  voice: ['உங்க குரல் பதிவைக் கேட்டேன் — முழுக் கதையும் சொல்லுங்க!'],
);

const _ml = _Openers(
  interests: {
    'hiking': ['{city}-ന് അടുത്ത് നിങ്ങൾ പോയതിൽ ഏറ്റവും നല്ല ട്രെക്ക് ഏതാണ്?'],
    'coffee': ['ഫിൽറ്റർ കാപ്പിയോ ചായയോ — നിങ്ങളുടെ ചോയ്സ് ഏതാ?'],
    'travel': ['അടുത്ത യാത്ര എങ്ങോട്ടാണ്?'],
    'design': ['ഇപ്പോൾ എന്താണ് ഡിസൈൻ ചെയ്യുന്നത്?'],
    'jazz': ['ഞാൻ നിർബന്ധമായും കേൾക്കേണ്ട ഒരു ജാസ് ആർട്ടിസ്റ്റ് ആരാണ്?'],
    'books': ['ഇപ്പോൾ ഏത് പുസ്തകമാണ് വായിക്കുന്നത്?'],
    'cooking': ['നിങ്ങളുടെ സ്പെഷ്യൽ ഡിഷ് ഏതാണ്?'],
    'yoga': ['രാവിലെ യോഗയോ വൈകുന്നേരമോ?'],
    'dogs': ['നിങ്ങൾക്ക് നായയുണ്ടോ? ഫോട്ടോ വേണം!'],
    'cats': ['നിങ്ങൾക്ക് പൂച്ചയുണ്ടോ? ഫോട്ടോ വേണം!'],
    'film': ['അടുത്തിടെ മനസ്സിൽ തട്ടിയ സിനിമ ഏതാണ്?'],
    'photography': ['അടുത്തിടെ എടുത്തതിൽ ഏറ്റവും ഇഷ്ടപ്പെട്ട ഫോട്ടോ ഏതാണ്?'],
    'gaming': ['ഇപ്പോൾ ഏത് ഗെയിമാണ് കളിക്കുന്നത്?'],
    'fitness': ['നിങ്ങളുടെ പെർഫെക്റ്റ് വർക്കൗട്ട് എങ്ങനെയാണ്?'],
    'live music': ['ഇതുവരെ കണ്ടതിൽ ഏറ്റവും നല്ല ലൈവ് പരിപാടി ഏതാണ്?'],
    'wine': ['റെഡ് വൈനോ വൈറ്റോ?'],
    'plants': ['എത്ര ചെടികളുണ്ട്?'],
    'cricket': ['കളിക്കാറുണ്ടോ അതോ കാണാറേയുള്ളോ — ഏതാണ് നിങ്ങളുടെ ടീം?'],
    'dancing': ['ഏത് പാട്ട് കേട്ടാലാണ് ഡാൻസ് ചെയ്യാൻ തോന്നുന്നത്?'],
    'cycling': ['{city}-ൽ നിങ്ങളുടെ ഇഷ്ട സൈക്കിൾ റൂട്ട് ഏതാണ്?'],
    'street food': ['{city}-ൽ ഏറ്റവും നല്ല സ്ട്രീറ്റ് ഫുഡ് എവിടെ കിട്ടും?'],
    'theatre': ['അടുത്തിടെ കണ്ട നല്ല നാടകം ഏതാണ്?'],
    'beaches': ['{city}-ന് അടുത്ത് നിങ്ങളുടെ ഇഷ്ട ബീച്ച് ഏതാണ്?'],
    'board games': ['നിങ്ങളുടെ ഇഷ്ട ബോർഡ് ഗെയിം ഏതാണ്?'],
    'music': ['ഈ ആഴ്ച വീണ്ടും വീണ്ടും കേൾക്കുന്ന പാട്ട് ഏതാണ്?'],
    'architecture': ['{city}-ൽ നിങ്ങൾക്ക് ഏറ്റവും ഇഷ്ടമുള്ള കെട്ടിടം ഏതാണ്?'],
  },
  goals: ['നിങ്ങളുടെ കാഴ്ചപ്പാടിൽ ഒരു നല്ല ആദ്യ ഡേറ്റ് എങ്ങനെയായിരിക്കും?',
    'ഈ വർഷം നിങ്ങൾ ഏറ്റവും കാത്തിരിക്കുന്നത് എന്താണ്?'],
  lifestyle: {
    'Sport': ['ഏത് കളിയാണ് കളിക്കുന്നത്? എനിക്കൊരു പാർട്ണറെ വേണം.'],
    'Smoking': ['ചായയോ കാപ്പിയോ — ഏതാ ഇഷ്ടം?'],
    'Drinking': ['നിങ്ങൾക്ക് ഒരു പെർഫെക്റ്റ് സായാഹ്നം എങ്ങനെയാണ്?'],
    'Food habits': ['{city}-ൽ ഏത് വിഭവത്തിനായി നിങ്ങൾ എത്ര ദൂരവും പോകും?'],
  },
  city: ['{city}-ൽ എല്ലാവരും പോകേണ്ട ഒരു സ്ഥലം ഏതാണ്?', '{city}-ലെ അധികമാർക്കും അറിയാത്ത ഒരു നല്ല സ്ഥലം പറയാമോ?'],
  languages: ['നിങ്ങളുടെ ഇഷ്ട {language} സിനിമ അല്ലെങ്കിൽ പാട്ട് ഏതാണ്?'],
  voice: ['നിങ്ങളുടെ വോയ്സ് പ്രോംപ്റ്റ് കേട്ടു — ഇനി മുഴുവൻ കഥയും കേൾക്കണം!'],
);

const _hi = _Openers(
  interests: {
    'hiking': ['{city} के पास आपका सबसे अच्छा ट्रेक कौन-सा रहा?'],
    'coffee': ['फ़िल्टर कॉफ़ी या चाय — आपकी पसंद क्या है?'],
    'travel': ['आपकी अगली ट्रिप कहाँ की है?'],
    'design': ['आजकल आप क्या डिज़ाइन कर रहे हैं?'],
    'jazz': ['कोई एक जैज़ कलाकार बताइए जिसे मुझे ज़रूर सुनना चाहिए।'],
    'books': ['आजकल आप कौन-सी किताब पढ़ रहे हैं?'],
    'cooking': ['आपकी सबसे ख़ास डिश कौन-सी है?'],
    'yoga': ['सुबह योग या शाम को?'],
    'dogs': ['आपके पास डॉगी है? फ़ोटो चाहिए!'],
    'cats': ['आपके पास बिल्ली है? फ़ोटो चाहिए!'],
    'film': ['हाल में कौन-सी फ़िल्म दिल को छू गई?'],
    'photography': ['हाल में खींची कौन-सी फ़ोटो आपकी सबसे पसंदीदा है?'],
    'gaming': ['आजकल कौन-सा गेम खेल रहे हैं?'],
    'fitness': ['आपका परफ़ेक्ट वर्कआउट कैसा होता है?'],
    'live music': ['अब तक का सबसे अच्छा कॉन्सर्ट कौन-सा था?'],
    'wine': ['रेड वाइन या व्हाइट?'],
    'plants': ['आपके पास कितने पौधे हैं?'],
    'cricket': ['खेलते हैं या देखते हैं — और आपकी टीम कौन-सी है?'],
    'dancing': ['कौन-सा गाना आपको डांस फ़्लोर पर ले आता है?'],
    'cycling': ['{city} में आपका पसंदीदा साइकिल रूट कौन-सा है?'],
    'street food': ['{city} में सबसे अच्छा स्ट्रीट फ़ूड कहाँ मिलता है?'],
    'theatre': ['हाल में कोई अच्छा नाटक देखा?'],
    'beaches': ['{city} के पास आपका पसंदीदा बीच कौन-सा है?'],
    'board games': ['आपका पसंदीदा बोर्ड गेम कौन-सा है?'],
    'music': ['इस हफ़्ते आप कौन-सा गाना बार-बार सुन रहे हैं?'],
    'architecture': ['{city} की कौन-सी इमारत आपको सबसे ज़्यादा पसंद है?'],
  },
  goals: ['आपके हिसाब से एक बढ़िया पहली डेट कैसी होती है?',
    'इस साल आप किस चीज़ का सबसे ज़्यादा इंतज़ार कर रहे हैं?'],
  lifestyle: {
    'Sport': ['आप कौन-सा खेल खेलते हैं? मुझे एक पार्टनर चाहिए।'],
    'Smoking': ['चाय या कॉफ़ी — आपकी पसंद?'],
    'Drinking': ['आपके लिए एक परफ़ेक्ट शाम कैसी होती है?'],
    'Food habits': ['{city} में किस डिश के लिए आप कितनी भी दूर चले जाएँ?'],
  },
  city: ['{city} में ऐसी कौन-सी जगह है जहाँ हर किसी को जाना चाहिए?', '{city} की कोई छुपी हुई बढ़िया जगह बताइए?'],
  languages: ['आपकी पसंदीदा {language} फ़िल्म या गाना कौन-सा है?'],
  voice: ['आपका वॉइस प्रॉम्प्ट सुना — अब पूरी कहानी सुननी है!'],
);

const _openers = {'en': _en, 'ta': _ta, 'ml': _ml, 'hi': _hi};

/// Opening lines for a chat with [p] in [l]'s language, built from why the two of you match —
/// strongest reason first. [variant] rotates to different lines for "More ideas".
List<Icebreaker> icebreakersFor(Profile p, AppLocalizations l, {MatchEngine? engine, int variant = 0,
    int limit = 4}) {
  final m = (engine ?? matchEngine).insight(p);
  final o = _openers[l.localeName] ?? _en;
  final english = l.localeName == 'en';
  final out = <Icebreaker>[];
  var salt = 0;
  String pick(List<String> lines, {String language = ''}) =>
      lines[(variant + salt++) % lines.length].replaceAll('{city}', p.city).replaceAll('{language}', language);
  void add(IconData icon, String label, String text) {
    if (!out.any((b) => b.text == text)) out.add(Icebreaker(icon, label, text));
  }
  String plain(String interest) => interest.replaceFirst(RegExp(r'^[^A-Za-z]+'), '').trim();
  String inSentence(String s) => english ? s.toLowerCase() : s;
  String interestLine(String i) => pick(o.interests[MatchEngine.interestKey(i)] ?? [
    l.icebreakerInterestFallback1(inSentence(plain(i))), l.icebreakerInterestFallback2(inSentence(plain(i)))]);

  for (final r in m.reasons) {
    switch (r.kind) {
      case MatchReasonKind.interests:
        for (final i in r.subjects) { add(r.icon, l.reasonInterestsFew(plain(i)), interestLine(i)); }
      case MatchReasonKind.taste:
        for (final i in r.subjects) { add(r.icon, l.icebreakerTaste(p.name, plain(i)), interestLine(i)); }
      case MatchReasonKind.goals:
        add(r.icon, l.reasonTitle(r), pick(o.goals));
      case MatchReasonKind.languages:
        for (final lang in r.subjects) {
          add(r.icon, l.reasonLanguages(l.languageName(lang)), pick(o.languages, language: l.languageName(lang)));
        }
      case MatchReasonKind.lifestyle:
        for (final k in r.subjects) {
          final lines = o.lifestyle[k];
          if (lines != null) add(r.icon, l.reasonTitle(r), pick(lines));
        }
      case MatchReasonKind.sameCity || MatchReasonKind.nearby:
        add(r.icon, l.reasonTitle(r), pick(o.city));
      case MatchReasonKind.voice:
        add(r.icon, l.icebreakerVoice(p.name), pick(o.voice));
      case MatchReasonKind.preferences || MatchReasonKind.verified:
        break;
    }
  }

  // Thin common ground: fall back to what's on their profile.
  for (final i in p.interests) {
    if (out.length >= limit) break;
    add(Icons.interests_rounded, l.icebreakerTheirInterest(p.name, plain(i)), interestLine(i));
  }
  if (out.length < limit && p.job.isNotEmpty) {
    add(Icons.work_outline_rounded, l.icebreakerJob(p.name, p.job), l.icebreakerJobLine(inSentence(p.job)));
  }
  // Rotate so "More ideas" also surfaces different topics, not just different wording.
  if (out.length > limit) {
    final shift = (variant * limit) % out.length;
    return [...out.skip(shift), ...out.take(shift)].take(limit).toList();
  }
  return out;
}
