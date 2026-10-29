import 'package:flutter/foundation.dart';
import 'mock.dart';

/// Sign-in details and safety state for the signed-in account (frontend only — swap the
/// mock delays for real API calls).
class AccountStore extends ChangeNotifier {
  String email = '', phone = '';
  bool emailVerified = false, phoneVerified = false;
  final List<Profile> _blocked = [];

  List<Profile> get blocked => List.unmodifiable(_blocked);
  bool isBlocked(Profile p) => _blocked.any((b) => b.id == p.id);

  void block(Profile p) {
    if (isBlocked(p)) return;
    _blocked.insert(0, p);
    notifyListeners();
  }

  void unblock(Profile p) {
    _blocked.removeWhere((b) => b.id == p.id);
    notifyListeners();
  }

  void setEmail(String v) { email = v; emailVerified = true; notifyListeners(); }
  void setPhone(String v) { phone = v; phoneVerified = true; notifyListeners(); }

  /// Pretends to send a one-time code to [destination].
  Future<void> sendCode(String destination) => Future.delayed(const Duration(milliseconds: 700));

  /// Any 6-digit code is accepted in this mock.
  Future<bool> verifyCode(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  void signIn({required String email}) {
    this.email = email.trim();
    emailVerified = true;
    notifyListeners();
  }

  /// Demo data for users who sign in instead of signing up.
  void seedDemo() {
    if (phone.isEmpty) { phone = '+91 98765 43210'; phoneVerified = true; }
    if (_blocked.isEmpty) _blocked.add(profiles[2]);
    notifyListeners();
  }

  void reset() {
    email = ''; phone = ''; emailVerified = phoneVerified = false;
    _blocked.clear();
    notifyListeners();
  }
}

final account = AccountStore();

final emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');

/// Formats 10 Indian mobile digits as "+91 98765 43210".
String formatIndianPhone(String digits) => '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
