import 'package:flutter/material.dart';

class FilterGroup {
  final String title; final List<String> options;
  const FilterGroup(this.title, this.options);
}

const lookingForGenderOptions = ['Women', 'Men', 'Everyone'];

const relationshipFilters = [
  FilterGroup('Relationships', ['Long-term relationship', 'Short-term relationship',
    "We'll see (if the feeling is right)", 'Friendship', 'Hangout', 'Friends with benefits',
    'Open relationship', 'One-night stand']),
  FilterGroup('Kids', ["I've got kids", "I don't want any", 'I have some, but want more', 'I want kids one day']),
  FilterGroup('Smoking', ['On a regular basis', "It doesn't bother me", 'Never']),
];

const lifestyleFilters = [
  FilterGroup('Sport', ['Never', 'Sometimes', 'Regularly']),
  FilterGroup('Drinking', ['Never', 'Sometimes', 'Regularly']),
  FilterGroup('Level of education', ['Autodidact', 'Secondary education', 'College', 'Bachelor', 'Master', 'Ph.D.']),
  FilterGroup('Food habits', ['A bit of everything', 'Flexitarian', 'Vegetarian', 'Vegan', 'Halal', 'Kosher',
    'Junk food 4eva']),
];

/// Who the user wants to see in Discover.
class DiscoveryPreferences extends ChangeNotifier {
  static const minAge = 18.0, maxAge = 99.0, minHeightCm = 120.0, maxHeightCm = 220.0;
  static const defaultAge = RangeValues(18, 45), defaultHeight = RangeValues(minHeightCm, maxHeightCm);

  String showMe = 'Everyone';
  RangeValues ageRange = defaultAge;
  RangeValues heightRange = defaultHeight;
  /// Selected options keyed by [FilterGroup.title]; empty means no preference.
  Map<String, Set<String>> filters = {};

  void save({required String showMe, required RangeValues ageRange, required RangeValues heightRange,
      required Map<String, Set<String>> filters}) {
    this.showMe = showMe;
    this.ageRange = ageRange;
    this.heightRange = heightRange;
    this.filters = {for (final e in filters.entries) if (e.value.isNotEmpty) e.key: {...e.value}};
    notifyListeners();
  }
}

final discoveryPrefs = DiscoveryPreferences();
