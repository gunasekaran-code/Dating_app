import 'teaser.dart';

class Profile {
  final String id, name, city, job, bio;
  /// A [lookingForOptions] label, e.g. 'Long-term partner'.
  final String lookingFor;
  final int age, distanceKm;
  final bool verified, online;
  final List<String> photos, interests;
  /// Lifestyle answers keyed by [LifestyleQuestion.key] (Kids, Smoking, Sport, …).
  final Map<String, String> lifestyle;
  /// English names from [spokenLanguages], e.g. ['Tamil', 'English'].
  final List<String> languages;
  final List<Teaser> teasers;
  const Profile({required this.id, required this.name, required this.age, required this.city,
      required this.job, required this.bio, required this.distanceKm, required this.lookingFor,
      required this.verified, required this.online, required this.photos, required this.interests,
      this.lifestyle = const {}, this.languages = const [], this.teasers = const []});

  bool get hasVoicePrompt => teasers.any((t) => t.voice != null);
}

class Message {
  final String text; final bool mine; final String time;
  const Message(this.text, this.mine, this.time);
}

String _p(String id) => 'https://images.unsplash.com/photo-$id?w=900&q=80&auto=format&fit=crop';

final profiles = <Profile>[
  Profile(id: '1', name: 'Ananya', age: 27, city: 'Bengaluru', job: 'Product Designer', distanceKm: 3,
      lookingFor: 'Long-term, open to short', verified: true, online: true,
      lifestyle: {'Smoking': 'Never', 'Sport': 'Regularly', 'Drinking': 'Sometimes'},
      bio: 'Weekend hiker, weekday coffee snob. Looking for someone who reads the whole menu.',
      photos: [_p('1494790108377-be9c29b29330'), _p('1517841905240-472988babdf9')],
      interests: ['Hiking', 'Coffee', 'Design', 'Travel', 'Jazz'],
      languages: ['Kannada', 'Tamil', 'English'],
      teasers: const [Teaser('My ideal first date…', 'Sunrise trek at Nandi Hills, then the slowest filter coffee breakfast in town.',
          voice: VoiceNote.asset('assets/voice/ananya.m4a', duration: Duration(milliseconds: 9297), waveform: [
            .72, .94, .72, .63, .52, .84, .67, .53, .08, .47, .93, .94, .61, .62, .77, .5, .5, .64, .47, .62,
            .4, .63, .67, .61, .08, .96, 1, .82, .53, .74, .8, .54, .67, .57, .61, .58, .78, .38, .65, .55]))]),
  Profile(id: '2', name: 'Rohan', age: 30, city: 'Mumbai', job: 'Architect', distanceKm: 6,
      lookingFor: 'Short-term, open to long', verified: true, online: false,
      lifestyle: {'Smoking': 'Never', 'Sport': 'Sometimes', 'Food habits': 'A bit of everything'},
      bio: 'I sketch buildings and cook too much pasta. Tell me your favourite city.',
      photos: [_p('1507003211169-0a1dd7228f2d'), _p('1500648767791-00dcc994a43e')],
      interests: ['Cooking', 'Architecture', 'Cycling', 'Film'],
      languages: ['Marathi', 'Hindi', 'English']),
  Profile(id: '3', name: 'Meera', age: 25, city: 'Pune', job: 'Doctor', distanceKm: 9,
      lookingFor: 'Long-term partner', verified: false, online: true,
      lifestyle: {'Smoking': 'Never', 'Drinking': 'Never', 'Food habits': 'Vegetarian'},
      bio: 'Long shifts, longer playlists. Dogs over cats, sorry.',
      photos: [_p('1534528741775-53994a69daeb')],
      interests: ['Music', 'Dogs', 'Yoga', 'Books'],
      languages: ['Marathi', 'Hindi', 'English'],
      teasers: const [Teaser('Two truths and a lie…', 'मैं डॉक्टर हूँ, मेरे पास तीन कुत्ते हैं, और मुझे खाना बनाना बहुत पसंद है।',
          voice: VoiceNote.asset('assets/voice/meera.m4a', duration: Duration(milliseconds: 7228), waveform: [
            1, .83, .45, .4, .21, .56, .91, .62, .79, .58, .69, .48, .4, .41, .08, .88, .92, .49, .64, .74,
            .79, .85, .57, .46, .48, .67, .43, .22, .08, .72, .53, .73, .42, .08, 1, .45, .64, .77, .23, .32]))]),
  Profile(id: '4', name: 'Arjun', age: 29, city: 'Delhi', job: 'Photographer', distanceKm: 12,
      lookingFor: 'Short-term fun', verified: true, online: false,
      lifestyle: {'Smoking': 'On a regular basis', 'Sport': 'Never'},
      bio: 'Golden hour chaser. Will take your photo, badly on purpose.',
      photos: [_p('1506794778202-cad84cf45f1d')],
      interests: ['Photography', 'Travel', 'Street food'],
      languages: ['Hindi', 'Punjabi', 'English']),
  Profile(id: '5', name: 'Kavya', age: 26, city: 'Chennai', job: 'Data Scientist', distanceKm: 4,
      lookingFor: 'Long-term, open to short', verified: true, online: true,
      lifestyle: {'Smoking': 'Never', 'Sport': 'Sometimes', 'Drinking': 'Sometimes'},
      bio: 'I run numbers by day and board-game nights by weekend. Beat me at Catan and I’ll buy filter coffee.',
      photos: [_p('1544005313-94ddf0286df2')],
      interests: ['Coffee', 'Books', 'Travel', 'Board games', 'Cricket'],
      languages: ['Tamil', 'English'],
      teasers: const [Teaser('On a Sunday you’ll find me…',
          'மெரினா பீச்ல காலை நடை, ஒரு நல்ல ஃபில்டர் காபி, சாயங்காலம் நண்பர்களோட போர்டு கேம்ஸ்.',
          voice: VoiceNote.asset('assets/voice/kavya.m4a', duration: Duration(milliseconds: 7091), waveform: [
            .99, .75, .53, .66, .92, .65, .64, .85, .88, .94, .84, .62, .63, .75, .96, .86, .79, .52, .81, .97,
            .96, .9, .67, .71, .6, .56, .67, .55, .79, .81, .81, 1, .85, .68, .9, .78, .86, .48, .89, .08]))]),
  Profile(id: '6', name: 'Vikram', age: 31, city: 'Coimbatore', job: 'Chef', distanceKm: 15,
      lookingFor: 'Short-term, open to long', verified: true, online: false,
      lifestyle: {'Smoking': 'Never', 'Sport': 'Regularly', 'Drinking': 'Regularly'},
      bio: 'Professional cook, amateur cyclist. I will judge your biryani order, lovingly.',
      photos: [_p('1519085360753-af0119f7cbe7')],
      interests: ['Cooking', 'Street food', 'Wine', 'Travel', 'Cycling'],
      languages: ['Tamil', 'Malayalam', 'English']),
  Profile(id: '7', name: 'Ishita', age: 24, city: 'Madurai', job: 'Illustrator', distanceKm: 7,
      lookingFor: 'Still figuring it out', verified: false, online: true,
      lifestyle: {'Smoking': "It doesn't bother me", 'Sport': 'Never'},
      bio: 'Drawing cats, watching old films, collecting theatre stubs. Tell me the last film that made you cry.',
      photos: [_p('1524504388940-b1c1722653e1')],
      interests: ['Design', 'Film', 'Cats', 'Theatre'],
      languages: ['Tamil', 'English']),
  Profile(id: '8', name: 'Nikhil', age: 28, city: 'Thoothukudi', job: 'Marine Engineer', distanceKm: 2,
      lookingFor: 'Short-term, open to long', verified: true, online: true,
      lifestyle: {'Smoking': 'Never', 'Sport': 'Regularly'},
      bio: 'Half my life is at sea, the other half is at the beach. Sunrise cricket, anyone?',
      photos: [_p('1492562080023-ab3db95bfbce')],
      interests: ['Beaches', 'Photography', 'Fitness', 'Cricket'],
      languages: ['Tamil', 'English'],
      teasers: const [Teaser('The way to win me over is…', 'Sunrise cricket on the beach. Don’t complain about the sand.',
          voice: VoiceNote.asset('assets/voice/nikhil.m4a', duration: Duration(milliseconds: 6676), waveform: [
            .87, .72, .61, .83, .95, .59, 1, .5, .88, .88, .58, .57, .53, .76, .44, .77, .83, .79, .37, .08,
            .34, .69, .93, .62, .65, .66, .93, .68, .89, .67, .52, .69, .31, .08, .74, .72, .9, .82, .61, .4]))]),
  Profile(id: '9', name: 'Sana', age: 27, city: 'Tirunelveli', job: 'Teacher', distanceKm: 5,
      lookingFor: 'Long-term partner', verified: true, online: false,
      lifestyle: {'Smoking': 'Never', 'Drinking': 'Never', 'Kids': 'I want kids one day'},
      bio: 'Plant mum of 23. Will recommend you a book whether you asked or not.',
      photos: [_p('1531746020798-e6953c6e8e04')],
      interests: ['Books', 'Plants', 'Yoga', 'Coffee', 'Live music'],
      languages: ['Tamil', 'Urdu', 'English'],
      teasers: const [Teaser('A green flag I look for…', 'Someone who returns the books they borrow. And texts back.')]),
  Profile(id: '10', name: 'Dev', age: 26, city: 'Kochi', job: 'Musician', distanceKm: 20,
      lookingFor: 'Short-term fun', verified: false, online: true,
      lifestyle: {'Smoking': 'On a regular basis', 'Sport': 'Sometimes'},
      bio: 'Keys player in a jazz trio. I know every good late-night food stall in Fort Kochi.',
      photos: [_p('1463453091185-61582044d556')],
      interests: ['Live music', 'Jazz', 'Travel', 'Street food', 'Photography'],
      languages: ['Malayalam', 'English', 'Hindi'],
      teasers: const [Teaser('My go-to karaoke song…', 'Anything by A. R. Rahman — I will ruin the high notes.',
          voice: VoiceNote.asset('assets/voice/dev.m4a', duration: Duration(milliseconds: 4844), waveform: [
            .89, .77, .64, .68, 1, .61, .62, .48, .09, .08, .08, .08, .76, .58, .82, .98, .64, .54, .53, .84,
            .31, .8, .61, .93, .58, .61, .72, .65, .68, .47, .08, .3, .93, .38, .72, .57, .23, .92, .34, .11]))]),
];

final chatHistory = <Message>[
  const Message('Hi! Your trek photos are amazing — where was that?', false, '10:02'),
  const Message('Thank you! That was Kudremukh last monsoon 🌿', true, '10:05'),
  const Message('Adding it to my list. Coffee this weekend?', false, '10:06'),
];
