import 'dart:math';
import 'package:flutter/foundation.dart';
import 'mock.dart';
import 'teaser.dart';

export 'teaser.dart';

enum PhotoStatus { uploading, uploaded, failed }

/// A profile photo. Local picks keep their [bytes] so they render instantly while uploading;
/// seeded/remote photos only have a [url].
class ProfilePhoto {
  final String id; final Uint8List? bytes;
  String? url; PhotoStatus status; double progress;
  ProfilePhoto({required this.id, this.bytes, this.url, this.status = PhotoStatus.uploading, this.progress = 0});
}

/// Upload seam — replace [MockPhotoUploader] with a real backend (presigned S3 URL, Firebase Storage, …).
abstract class PhotoUploader {
  /// Reports progress in 0..1 through [onProgress] and completes with the hosted URL.
  Future<String> upload(Uint8List bytes, {required void Function(double) onProgress});
}

class MockPhotoUploader implements PhotoUploader {
  final double failureRate;
  const MockPhotoUploader({this.failureRate = 0});
  @override
  Future<String> upload(Uint8List bytes, {required void Function(double) onProgress}) async {
    final rnd = Random();
    for (var p = 0.0; p < 1; p += .08 + rnd.nextDouble() * .12) {
      onProgress(p);
      await Future.delayed(const Duration(milliseconds: 110));
    }
    if (rnd.nextDouble() < failureRate) throw Exception('Upload failed');
    onProgress(1);
    return 'mock://photos/${DateTime.now().microsecondsSinceEpoch}.jpg';
  }
}

/// Ordered list of the user's photos. Index 0 is the main (profile) photo.
class PhotoManager extends ChangeNotifier {
  static const maxPhotos = 6, minPhotos = 2;
  final PhotoUploader uploader;
  PhotoManager({this.uploader = const MockPhotoUploader()});

  final List<ProfilePhoto> _photos = [];
  int _seq = 0;

  List<ProfilePhoto> get photos => List.unmodifiable(_photos);
  int get count => _photos.length;
  int get remaining => maxPhotos - _photos.length;
  bool get isFull => remaining <= 0;
  ProfilePhoto? get main => _photos.isEmpty ? null : _photos.first;
  int get uploadedCount => _photos.where((p) => p.status == PhotoStatus.uploaded).length;
  bool get isUploading => _photos.any((p) => p.status == PhotoStatus.uploading);
  bool get hasFailures => _photos.any((p) => p.status == PhotoStatus.failed);
  bool get meetsMinimum => uploadedCount >= minPhotos && !isUploading;
  int indexOf(String id) => _photos.indexWhere((p) => p.id == id);

  String _nextId() => 'photo_${_seq++}';

  /// Adds picked images (up to the remaining capacity) and starts uploading each one.
  /// Returns how many were added.
  int addAll(List<Uint8List> images) {
    final added = images.take(remaining).map((b) => ProfilePhoto(id: _nextId(), bytes: b)).toList();
    _photos.addAll(added);
    notifyListeners();
    for (final p in added) { _upload(p); }
    return added.length;
  }

  /// Seeds already-hosted photos (e.g. from the server on sign in).
  void seed(List<String> urls) {
    _photos..clear()..addAll(urls.take(maxPhotos).map((u) =>
        ProfilePhoto(id: _nextId(), url: u, status: PhotoStatus.uploaded, progress: 1)));
    notifyListeners();
  }

  void replace(String id, Uint8List bytes) {
    final i = indexOf(id);
    if (i < 0) return;
    final p = ProfilePhoto(id: _nextId(), bytes: bytes);
    _photos[i] = p;
    notifyListeners();
    _upload(p);
  }

  void remove(String id) {
    _photos.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void move(int from, int to) {
    if (from < 0 || from >= _photos.length || from == to) return;
    final p = _photos.removeAt(from);
    _photos.insert(to.clamp(0, _photos.length), p);
    notifyListeners();
  }

  void makeMain(String id) => move(indexOf(id), 0);

  void retry(String id) {
    final i = indexOf(id);
    if (i >= 0 && _photos[i].status == PhotoStatus.failed) _upload(_photos[i]);
  }

  Future<void> _upload(ProfilePhoto p) async {
    final bytes = p.bytes;
    if (bytes == null) return;
    p..status = PhotoStatus.uploading..progress = 0;
    notifyListeners();
    try {
      final url = await uploader.upload(bytes, onProgress: (v) {
        if (!_photos.contains(p)) return; // removed mid-upload
        p.progress = v;
        notifyListeners();
      });
      p..url = url..status = PhotoStatus.uploaded..progress = 1;
    } catch (_) {
      p.status = PhotoStatus.failed;
    }
    if (_photos.contains(p)) notifyListeners();
  }
}

/// A favourite spot shown under "Places".
class FavouritePlace {
  final String emoji, name;
  const FavouritePlace(this.emoji, this.name);
}

/// The signed-in user's editable profile, filled by onboarding.
class UserProfileStore extends ChangeNotifier {
  static const maxTeasers = 3, maxHobbies = 10, maxPlaces = 10;
  String name = '', bio = '', job = '', city = '';
  DateTime? birthday;
  String? gender, showMe, education, lookingFor;
  bool showGender = true, metricHeight = true, verified = false;
  int? heightCm;
  /// Shown as "Hobbies" on the edit profile screen.
  final Set<String> interests = {};
  final Set<String> relationships = {};
  /// English names from [spokenLanguages] — "Languages I speak".
  final Set<String> languages = {};
  final List<Teaser> teasers = [];
  final List<FavouritePlace> places = [];
  /// Lifestyle answers keyed by [LifestyleQuestion.key] (Kids, Smoking, Sport, …).
  final Map<String, String> lifestyle = {};
  final photos = PhotoManager();

  int? get age {
    final b = birthday;
    if (b == null) return null;
    final now = DateTime.now();
    return now.year - b.year - ((now.month < b.month || (now.month == b.month && now.day < b.day)) ? 1 : 0);
  }

  void update(VoidCallback change) { change(); notifyListeners(); }

  void reset() {
    name = ''; bio = ''; job = ''; city = ''; birthday = null; gender = showMe = education = lookingFor = null;
    showGender = true; metricHeight = true; verified = false; heightCm = null;
    interests.clear(); relationships.clear(); languages.clear(); teasers.clear(); places.clear(); lifestyle.clear();
    photos.seed(const []);
    notifyListeners();
  }

  /// Fills the profile with demo data for users who sign in instead of onboarding.
  void seedDemo() {
    if (name.isNotEmpty) return;
    final p = profiles[3];
    name = 'Guna'; job = 'App Developer'; city = 'Thoothukudi';
    birthday = DateTime(DateTime.now().year - 23, 1, 1);
    gender = 'Man'; showMe = 'Women'; heightCm = 175; education = 'Master of computer science';
    lookingFor = 'Short-term, open to long';
    relationships..clear()..add('Short-term relationship');
    lifestyle..clear()..addAll({'Smoking': 'Never', 'Sport': 'Regularly'});
    languages..clear()..addAll(const ['Tamil', 'English']);
    interests..clear()..addAll(const ['☕ Coffee', '✈️ Travel', '📷 Photography', '🍜 Street food', '🏏 Cricket']);
    places..clear()..addAll(const [FavouritePlace('🍗', 'KFC'), FavouritePlace('☕', 'Café Coffee Day'),
      FavouritePlace('⭐', 'KSPS Ganapathy theatre'), FavouritePlace('👟', 'United Sports Emporium')]);
    photos.seed([...p.photos, profiles[1].photos.last]);
    notifyListeners();
  }
}

final currentUser = UserProfileStore();
