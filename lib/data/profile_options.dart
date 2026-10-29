import 'package:flutter/material.dart';
import 'preferences_store.dart';

class ChoiceOption {
  final String label; final String? description, emoji; final IconData? icon;
  const ChoiceOption(this.label, {this.description, this.emoji, this.icon});
}

const genderOptions = [
  ChoiceOption('Woman', icon: Icons.female_rounded),
  ChoiceOption('Man', icon: Icons.male_rounded),
  ChoiceOption('Non-binary', icon: Icons.all_inclusive_rounded),
];
const moreGenderOptions = ['Agender', 'Bigender', 'Genderfluid', 'Genderqueer', 'Intersex',
  'Transgender woman', 'Transgender man', 'Two-spirit', 'Questioning', 'Another identity'];

const showMeOptions = [
  ChoiceOption('Women', icon: Icons.female_rounded),
  ChoiceOption('Men', icon: Icons.male_rounded),
  ChoiceOption('Everyone', description: 'Show me all genders', icon: Icons.diversity_3_rounded),
];

const educationOptions = [
  ChoiceOption('High school', icon: Icons.backpack_outlined),
  ChoiceOption('Trade or technical school', icon: Icons.handyman_outlined),
  ChoiceOption('In college', icon: Icons.menu_book_outlined),
  ChoiceOption("Bachelor's degree", icon: Icons.school_outlined),
  ChoiceOption('In grad school', icon: Icons.auto_stories_outlined),
  ChoiceOption("Master's degree", icon: Icons.workspace_premium_outlined),
  ChoiceOption('Doctorate', icon: Icons.science_outlined),
  ChoiceOption('Prefer not to say', icon: Icons.visibility_off_outlined),
];

const lookingForOptions = [
  ChoiceOption('Long-term partner', icon: Icons.favorite_rounded, description: 'Ready for something real'),
  ChoiceOption('Long-term, open to short', icon: Icons.favorite_border_rounded, description: 'Serious, but no rush'),
  ChoiceOption('Short-term, open to long', icon: Icons.local_bar_rounded, description: 'Let’s see where it goes'),
  ChoiceOption('Short-term fun', icon: Icons.celebration_rounded, description: 'Keeping it light'),
  ChoiceOption('New friends', icon: Icons.waving_hand_rounded, description: 'Meet great people'),
  ChoiceOption('Still figuring it out', icon: Icons.search_rounded, description: 'Open to the right person'),
];


const interestOptions = ['☕ Coffee', '🥾 Hiking', '✈️ Travel', '🎨 Design', '🎷 Jazz', '📚 Books',
  '🍳 Cooking', '🧘 Yoga', '🐶 Dogs', '🐱 Cats', '🎬 Film', '📷 Photography', '🎮 Gaming', '🏋️ Fitness',
  '🎸 Live music', '🍷 Wine', '🌱 Plants', '🏏 Cricket', '💃 Dancing', '🚴 Cycling', '🍜 Street food',
  '🎭 Theatre', '🏖️ Beaches', '🧩 Board games'];

/// Relationship types the user can pick on their profile (same list as the Discover filter).
final relationshipOptions = relationshipFilters.first.options;
const relationshipEmojis = ['💞', '🔥', '🤞', '🤝', '☕', '😉', '🔓', '🌙'];

/// A lifestyle question on the profile. [key] matches the Discover filter group it answers.
class LifestyleQuestion {
  final String key, question; final IconData icon;
  const LifestyleQuestion(this.key, this.question, this.icon);
  List<String> get options => [...relationshipFilters, ...lifestyleFilters].firstWhere((g) => g.title == key).options;
}

const kidsQuestion = LifestyleQuestion('Kids', 'What about kids?', Icons.child_friendly_outlined);
const smokingQuestion = LifestyleQuestion('Smoking', 'Do you smoke?', Icons.smoking_rooms_outlined);
const sportQuestion = LifestyleQuestion('Sport', 'How often do you play sport?', Icons.sports_tennis_outlined);
const drinkingQuestion = LifestyleQuestion('Drinking', 'Do you drink?', Icons.local_bar_outlined);
const foodQuestion = LifestyleQuestion('Food habits', 'What are your food habits?', Icons.restaurant_outlined);
const lifestyleQuestions = [kidsQuestion, smokingQuestion, sportQuestion, drinkingQuestion, foodQuestion];

const teaserPrompts = ['My ideal first date…', 'Two truths and a lie…', 'I geek out on…',
  'The way to win me over is…', 'My simple pleasures…', 'A green flag I look for…',
  'The best trip I’ve taken…', 'My most irrational fear…', 'Let’s debate this topic…',
  'I’m looking for someone who…', 'On a Sunday you’ll find me…', 'My go-to karaoke song…'];

/// Emoji "categories" offered when adding a favourite place.
const placeCategories = [('🍗', 'Food'), ('☕', 'Café'), ('🎬', 'Cinema'), ('⭐', 'Favourite'),
  ('👟', 'Shopping'), ('🏋️', 'Gym'), ('🌳', 'Park'), ('🏖️', 'Beach'), ('🍸', 'Bar'), ('📚', 'Books')];

/// Languages for "Languages I speak", stored by English name and shown in their own script.
const spokenLanguages = [('Tamil', 'தமிழ்'), ('Malayalam', 'മലയാളം'), ('Hindi', 'हिन्दी'), ('English', 'English'),
  ('Telugu', 'తెలుగు'), ('Kannada', 'ಕನ್ನಡ'), ('Marathi', 'मराठी'), ('Bengali', 'বাংলা'), ('Gujarati', 'ગુજરાતી'),
  ('Punjabi', 'ਪੰਜਾਬੀ'), ('Urdu', 'اردو'), ('Odia', 'ଓଡ଼ିଆ'), ('Tulu', 'ತುಳು'), ('Konkani', 'कोंकणी')];

/// 'Tamil' → 'தமிழ்'. People read the languages they share in that language's own script.
String nativeLanguageName(String english) =>
    spokenLanguages.firstWhere((l) => l.$1 == english, orElse: () => (english, english)).$2;

const cityOptions = ['Thoothukudi', 'Tirunelveli', 'Madurai', 'Chennai', 'Coimbatore', 'Tiruchirappalli',
  'Salem', 'Puducherry', 'Bengaluru', 'Mysuru', 'Kochi', 'Thiruvananthapuram', 'Hyderabad', 'Mumbai',
  'Pune', 'Delhi', 'Kolkata', 'Ahmedabad', 'Jaipur', 'Chandigarh'];

String formatHeight(int cm, {bool metric = true}) {
  if (metric) return '$cm cm';
  final inches = (cm / 2.54).round();
  return '${inches ~/ 12}′ ${inches % 12}″';
}
