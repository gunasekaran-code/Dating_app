import 'package:flutter/foundation.dart';

/// One purchasable bundle, e.g. "20 SuperCrushes for ₹310".
class PerkPack {
  final int quantity; final double price; final String tag;
  const PerkPack(this.quantity, this.price, this.tag);
  double get unitPrice => price / quantity;
}

const superCrushPacks = [
  PerkPack(50, 620, 'Best price'),
  PerkPack(20, 310, 'Popular'),
  PerkPack(5, 180, 'Standard'),
];

const boostPacks = [
  PerkPack(10, 449, 'Best price'),
  PerkPack(3, 149, 'Popular'),
  PerkPack(1, 69, 'Unit price'),
];

/// A subscription length and its total price, e.g. 3 months for ₹899.
class PlanOption {
  final int months; final double price;
  const PlanOption(this.months, this.price);
  double get monthly => price / months;
}

const premiumPlans = [PlanOption(1, 699), PlanOption(3, 899), PlanOption(6, 1299)];
const supremePlans = [PlanOption(1, 849), PlanOption(3, 1199), PlanOption(6, 1699)];

/// Index of the pack pre-selected on the purchase screens.
const popularPackIndex = 1;

/// ₹1,199.00 — Indian digit grouping, two decimals.
String formatRupees(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  var whole = parts[0];
  if (whole.length > 3) {
    final head = whole.substring(0, whole.length - 3), tail = whole.substring(whole.length - 3);
    whole = '${head.replaceAllMapped(RegExp(r'(\d)(?=(\d{2})+$)'), (m) => '${m[1]},')},$tail';
  }
  return '₹$whole.${parts[1]}';
}

/// SuperCrush and Boost balances for the signed-in user (frontend only — purchases are simulated).
class PerksStore extends ChangeNotifier {
  int superCrushes = 3, boosts = 0;

  void addSuperCrushes(int n) { superCrushes += n; notifyListeners(); }
  void addBoosts(int n) { boosts += n; notifyListeners(); }

  /// Spends one SuperCrush; false when the balance is empty.
  bool useSuperCrush() {
    if (superCrushes == 0) return false;
    superCrushes--; notifyListeners();
    return true;
  }
}

final perks = PerksStore();
