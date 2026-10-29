import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/states.dart';

/// Lets the user choose gallery or camera, then returns the picked images as bytes
/// (resized so uploads stay light). Returns an empty list when cancelled or denied.
class PhotoPickerService {
  static final _picker = ImagePicker();
  static const _maxSide = 1440.0, _quality = 85;

  static Future<List<Uint8List>> pick(BuildContext context, {required int limit, String title = 'Add photos'}) async {
    if (limit <= 0) return [];
    final canUseCamera = _picker.supportsImageSource(ImageSource.camera);
    final source = canUseCamera
        ? await showModalBottomSheet<ImageSource>(context: context,
            builder: (_) => _SourceSheet(title: title, limit: limit))
        : ImageSource.gallery;
    if (source == null) return [];
    try {
      final List<XFile> files;
      if (source == ImageSource.gallery && limit > 1) {
        files = await _picker.pickMultiImage(limit: limit, maxWidth: _maxSide, maxHeight: _maxSide, imageQuality: _quality);
      } else {
        final f = await _picker.pickImage(source: source, maxWidth: _maxSide, maxHeight: _maxSide,
            imageQuality: _quality, preferredCameraDevice: CameraDevice.front);
        files = [if (f != null) f];
      }
      return await Future.wait(files.take(limit).map((f) => f.readAsBytes()));
    } on PlatformException catch (e) {
      if (context.mounted) {
        final denied = e.code.contains('access_denied') || e.code.contains('permission');
        showToast(context, denied
            ? 'Allow ${source == ImageSource.camera ? 'camera' : 'photo'} access in Settings to add photos.'
            : 'Couldn’t open your ${source == ImageSource.camera ? 'camera' : 'photos'}. Please try again.',
            type: ToastType.error);
      }
      return [];
    }
  }
}

class _SourceSheet extends StatelessWidget {
  final String title; final int limit;
  const _SourceSheet({required this.title, required this.limit});
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(
    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppText.h3),
      const SizedBox(height: AppSpacing.xs),
      Text(limit == 1 ? 'Choose one photo.' : 'You can add up to $limit more.', style: AppText.bodySmall),
      const SizedBox(height: AppSpacing.xl),
      Row(children: [
        Expanded(child: _SourceTile(icon: Icons.photo_library_outlined, label: 'Gallery',
            caption: limit > 1 ? 'Select several' : 'Pick a photo',
            onTap: () => Navigator.pop(context, ImageSource.gallery))),
        const SizedBox(width: AppSpacing.mdSm),
        Expanded(child: _SourceTile(icon: Icons.photo_camera_outlined, label: 'Camera', caption: 'Take a selfie',
            onTap: () => Navigator.pop(context, ImageSource.camera))),
      ]),
    ])));
}

class _SourceTile extends StatelessWidget {
  final IconData icon; final String label, caption; final VoidCallback onTap;
  const _SourceTile({required this.icon, required this.label, required this.caption, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: AppColors.glass,
    borderRadius: BorderRadius.circular(AppRadius.card),
    child: InkWell(borderRadius: BorderRadius.circular(AppRadius.card), onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(children: [
        Container(width: 52, height: 52, decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary)),
        const SizedBox(height: AppSpacing.mdSm),
        Text(label, style: AppText.labelLarge.copyWith(color: AppColors.primary)),
        Text(caption, style: AppText.bodySmall),
      ]))));
}
