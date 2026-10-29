import 'package:flutter/material.dart';
import '../services/haptics.dart';
import '../data/profile_store.dart';
import '../services/photo_picker.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'profile_bits.dart';
import 'states.dart';

/// Renders a [ProfilePhoto] from local bytes (while uploading) or its hosted URL.
class PhotoImage extends StatelessWidget {
  final ProfilePhoto photo; final double? width, height;
  const PhotoImage(this.photo, {super.key, this.width, this.height});
  @override
  Widget build(BuildContext context) {
    final bytes = photo.bytes;
    if (bytes != null) {
      return Image.memory(bytes, width: width, height: height, fit: BoxFit.cover, gaplessPlayback: true,
        errorBuilder: (c, e, s) => Container(width: width, height: height, color: AppColors.secondary,
            child: const Icon(Icons.broken_image_outlined, color: AppColors.accent)));
    }
    return AppImage(photo.url ?? '', width: width, height: height);
  }
}

/// Six-slot photo grid: a large main slot plus five smaller ones.
/// Long-press and drag to reorder; tap a photo for options; tap an empty slot to add.
class PhotoGrid extends StatelessWidget {
  final PhotoManager manager;
  final VoidCallback onAdd;
  final void Function(ProfilePhoto photo) onPhotoTap;
  /// When true, removing a photo is blocked once only [PhotoManager.minPhotos] remain.
  final bool enforceMinimum;
  const PhotoGrid({super.key, required this.manager, required this.onAdd, required this.onPhotoTap,
      this.enforceMinimum = false});

  static const _gap = 10.0;

  /// Slot 0 spans 2×2; slots 1–2 stack on the right; slots 3–5 fill the bottom row.
  static List<Rect> _slots(double width) {
    final w = (width - _gap * 2) / 3, h = w * 4 / 3;
    return [
      Rect.fromLTWH(0, 0, w * 2 + _gap, h * 2 + _gap),
      Rect.fromLTWH((w + _gap) * 2, 0, w, h),
      Rect.fromLTWH((w + _gap) * 2, h + _gap, w, h),
      for (var c = 0; c < 3; c++) Rect.fromLTWH((w + _gap) * c, (h + _gap) * 2, w, h),
    ];
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final slots = _slots(box.maxWidth);
    return ListenableBuilder(listenable: manager, builder: (context, _) {
      final photos = manager.photos;
      return SizedBox(height: slots.last.bottom, child: Stack(children: [
        for (var i = photos.length; i < PhotoManager.maxPhotos; i++)
          Positioned.fromRect(rect: slots[i], child: DragTarget<String>(
            onWillAcceptWithDetails: (d) { manager.move(manager.indexOf(d.data), manager.count - 1); return true; },
            builder: (_, candidates, __) => _EmptySlot(index: i, next: i == photos.length,
                highlighted: candidates.isNotEmpty, onTap: onAdd))),
        for (var i = 0; i < photos.length; i++)
          AnimatedPositioned.fromRect(key: ValueKey(photos[i].id), rect: slots[i],
            duration: AppDurations.slow, curve: Curves.easeOutCubic,
            child: _DraggablePhoto(photo: photos[i], isMain: i == 0, size: slots[i].size,
                manager: manager, enforceMinimum: enforceMinimum, onTap: () => onPhotoTap(photos[i]))),
      ]));
    });
  });
}

class _DraggablePhoto extends StatelessWidget {
  final ProfilePhoto photo; final bool isMain, enforceMinimum; final Size size; final PhotoManager manager;
  final VoidCallback onTap;
  const _DraggablePhoto({required this.photo, required this.isMain, required this.size,
      required this.manager, required this.enforceMinimum, required this.onTap});

  @override
  Widget build(BuildContext context) => DragTarget<String>(
    onWillAcceptWithDetails: (d) {
      if (d.data != photo.id) {
        manager.move(manager.indexOf(d.data), manager.indexOf(photo.id));
        Haptics.selection();
      }
      return true;
    },
    builder: (_, __, ___) => LongPressDraggable<String>(
      data: photo.id, delay: const Duration(milliseconds: 220), hapticFeedbackOnStart: false, onDragStarted: Haptics.medium,
      feedback: Material(color: Colors.transparent, child: Transform.scale(scale: 1.05,
        child: Container(width: size.width, height: size.height,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.elevated),
          child: _PhotoTile(photo: photo, isMain: isMain, dragging: true)))),
      childWhenDragging: const _DropPlaceholder(),
      child: Semantics(button: true, label: isMain ? 'Main photo. Tap for options, long-press to reorder'
          : 'Photo ${manager.indexOf(photo.id) + 1}. Tap for options, long-press to reorder',
        child: GestureDetector(onTap: onTap, child: _PhotoTile(photo: photo, isMain: isMain,
            onRemove: () => confirmRemovePhoto(context, manager, photo, enforceMinimum: enforceMinimum),
            onRetry: () => manager.retry(photo.id)))),
    ));
}

class _PhotoTile extends StatelessWidget {
  final ProfilePhoto photo; final bool isMain, dragging; final VoidCallback? onRemove, onRetry;
  const _PhotoTile({required this.photo, required this.isMain, this.dragging = false, this.onRemove, this.onRetry});

  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(AppRadius.card),
    child: Stack(fit: StackFit.expand, children: [
      _FadeIn(child: PhotoImage(photo)),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.center,
          end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x55000000)]))),
      if (isMain) Positioned(left: AppSpacing.sm, bottom: AppSpacing.sm, child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(color: AppColors.glassStrong, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: AppSpacing.xs),
          Text('Main', style: AppText.labelSmall.copyWith(color: AppColors.primary)),
        ]))),
      if (photo.status == PhotoStatus.uploading) _UploadOverlay(progress: photo.progress, large: isMain),
      if (photo.status == PhotoStatus.failed) Material(color: const Color(0x99241C1E),
        child: InkWell(onTap: onRetry, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.refresh_rounded, color: AppColors.onPrimary, size: 28),
          const SizedBox(height: AppSpacing.xs),
          Text('Tap to retry', style: AppText.labelSmall.copyWith(color: AppColors.onPrimary)),
        ]))),
      if (!dragging && onRemove != null) Positioned(top: 6, right: 6, child: Semantics(button: true, label: 'Remove photo',
        child: GestureDetector(onTap: onRemove, child: Container(width: 28, height: 28,
          decoration: const BoxDecoration(color: AppColors.glassStrong, shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primary))))),
    ]));
}

class _UploadOverlay extends StatelessWidget {
  final double progress; final bool large;
  const _UploadOverlay({required this.progress, required this.large});
  @override
  Widget build(BuildContext context) {
    final d = large ? 56.0 : 40.0;
    return Container(color: const Color(0x80241C1E), alignment: Alignment.center,
      child: Semantics(label: 'Uploading ${(progress * 100).round()} percent', child: SizedBox(width: d, height: d,
        child: TweenAnimationBuilder<double>(tween: Tween(end: progress), duration: AppDurations.base,
          builder: (_, v, __) => Stack(alignment: Alignment.center, children: [
            SizedBox.expand(child: CircularProgressIndicator(value: v, strokeWidth: 3, strokeCap: StrokeCap.round,
                color: AppColors.onPrimary, backgroundColor: const Color(0x40FFFFFF))),
            Text('${(v * 100).round()}%', style: (large ? AppText.labelMedium : AppText.labelSmall)
                .copyWith(color: AppColors.onPrimary)),
          ])))));
  }
}

class _EmptySlot extends StatelessWidget {
  final int index; final bool next, highlighted; final VoidCallback onTap;
  const _EmptySlot({required this.index, required this.next, required this.highlighted, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final main = index == 0, required = index < PhotoManager.minPhotos;
    return Semantics(button: true, label: main ? 'Add main photo' : 'Add photo',
      child: GestureDetector(onTap: onTap, child: CustomPaint(
        foregroundPainter: _DashedBorderPainter(color: next || highlighted ? AppColors.accent : AppColors.border),
        child: AnimatedContainer(duration: AppDurations.fast,
          decoration: BoxDecoration(color: highlighted ? AppColors.secondary : AppColors.glass,
              borderRadius: BorderRadius.circular(AppRadius.card)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: main ? 56 : 34, height: main ? 56 : 34,
              decoration: BoxDecoration(color: next ? AppColors.primary : AppColors.secondary, shape: BoxShape.circle),
              child: Icon(main ? Icons.add_a_photo_outlined : Icons.add_rounded, size: main ? 26 : 20,
                  color: next ? AppColors.onPrimary : AppColors.primary)),
            if (main) ...[
              const SizedBox(height: AppSpacing.mdSm),
              Text('Add main photo', style: AppText.labelLarge.copyWith(color: AppColors.primary)),
              Text('Clear, smiling, just you', style: AppText.bodySmall),
            ] else if (required) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Required', style: AppText.labelSmall.copyWith(color: AppColors.accent)),
            ],
          ])))));
  }
}

class _DropPlaceholder extends StatelessWidget {
  const _DropPlaceholder();
  @override
  Widget build(BuildContext context) => CustomPaint(foregroundPainter: const _DashedBorderPainter(color: AppColors.accent),
    child: Container(decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(AppRadius.card)),
        child: const Icon(Icons.open_with_rounded, color: AppColors.accent)));
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  const _DashedBorderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(AppRadius.card)).deflate(.75));
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) { canvas.drawPath(m.extractPath(d, d + 6), paint); }
    }
  }
  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

class _FadeIn extends StatelessWidget {
  final Widget child;
  const _FadeIn({required this.child});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: 1),
      duration: AppDurations.slow, curve: Curves.easeOut,
      builder: (_, v, c) => Opacity(opacity: v, child: Transform.scale(scale: .96 + .04 * v, child: c)), child: child);
}

// ---------------------------------------------------------------------------
// Actions shared by onboarding and the Manage photos screen.

Future<void> addPhotos(BuildContext context, PhotoManager manager) async {
  if (manager.isFull) {
    showToast(context, 'You can have up to ${PhotoManager.maxPhotos} photos. Remove one to add another.');
    return;
  }
  final picked = await PhotoPickerService.pick(context, limit: manager.remaining);
  if (picked.isEmpty || !context.mounted) return;
  final added = manager.addAll(picked);
  if (added < picked.length) {
    showToast(context, 'Added $added — you’ve reached the ${PhotoManager.maxPhotos}-photo limit.');
  }
}

Future<void> confirmRemovePhoto(BuildContext context, PhotoManager manager, ProfilePhoto photo,
    {required bool enforceMinimum}) async {
  if (enforceMinimum && manager.count <= PhotoManager.minPhotos) {
    showToast(context, 'Your profile needs at least ${PhotoManager.minPhotos} photos. Add another before removing this one.');
    return;
  }
  final wasMain = manager.indexOf(photo.id) == 0;
  final ok = await showConfirmDialog(context, title: 'Remove this photo?',
      message: wasMain ? 'Your next photo will become your main photo.' : 'You can always add it again later.',
      confirm: 'Remove', destructive: true);
  if (!ok || !context.mounted) return;
  manager.remove(photo.id);
  showToast(context, wasMain && manager.count > 0 ? 'Photo removed · main photo updated' : 'Photo removed',
      type: ToastType.success);
}

Future<void> showPhotoOptions(BuildContext context, PhotoManager manager, ProfilePhoto photo,
    {bool enforceMinimum = false}) {
  final index = manager.indexOf(photo.id);
  Widget action(IconData icon, String label, VoidCallback onTap, {Color color = AppColors.text}) => ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      leading: Icon(icon, color: color), title: Text(label, style: AppText.bodyLarge.copyWith(color: color)),
      onTap: onTap);

  return showModalBottomSheet<void>(context: context, builder: (sheet) {
    void then(Future<void> Function() fn) { Navigator.pop(sheet); fn(); }
    return SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md), child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(AppRadius.standardCard),
            child: PhotoImage(photo, width: 54, height: 72)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(index == 0 ? 'Main photo' : 'Photo ${index + 1} of ${manager.count}', style: AppText.h4),
          Text(switch (photo.status) {
            PhotoStatus.uploading => 'Uploading…',
            PhotoStatus.failed => 'Upload failed',
            PhotoStatus.uploaded => index == 0 ? 'Shown first on your profile' : 'Drag to change its position',
          }, style: AppText.bodySmall.copyWith(color: photo.status == PhotoStatus.failed ? AppColors.error : null)),
        ])),
      ])),
      const Divider(),
      action(Icons.fullscreen_rounded, 'View photo', () => then(() async =>
          openPhotoViewer(context, manager, initialIndex: manager.indexOf(photo.id)))),
      if (index != 0 && photo.status == PhotoStatus.uploaded)
        action(Icons.star_outline_rounded, 'Set as main photo', () => then(() async {
          manager.makeMain(photo.id);
          showToast(context, 'Main photo updated', type: ToastType.success);
        })),
      if (photo.status == PhotoStatus.failed)
        action(Icons.refresh_rounded, 'Retry upload', () => then(() async => manager.retry(photo.id))),
      action(Icons.swap_horiz_rounded, 'Replace photo', () => then(() async {
        final picked = await PhotoPickerService.pick(context, limit: 1, title: 'Replace photo');
        if (picked.isNotEmpty) manager.replace(photo.id, picked.first);
      })),
      action(Icons.delete_outline_rounded, 'Remove photo', color: AppColors.error, () => then(() =>
          confirmRemovePhoto(context, manager, photo, enforceMinimum: enforceMinimum))),
      const SizedBox(height: AppSpacing.sm),
    ]));
  });
}

void openPhotoViewer(BuildContext context, PhotoManager manager, {int initialIndex = 0}) =>
    Navigator.push(context, PageRouteBuilder(opaque: false, barrierColor: Colors.black,
      transitionDuration: AppDurations.base,
      pageBuilder: (_, __, ___) => _PhotoViewer(manager: manager, initialIndex: initialIndex),
      transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child)));

class _PhotoViewer extends StatefulWidget {
  final PhotoManager manager; final int initialIndex;
  const _PhotoViewer({required this.manager, required this.initialIndex});
  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}
class _PhotoViewerState extends State<_PhotoViewer> {
  late final pc = PageController(initialPage: widget.initialIndex);
  late int page = widget.initialIndex;
  @override
  void dispose() { pc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final photos = widget.manager.photos;
    return Scaffold(backgroundColor: Colors.black, body: Stack(children: [
      PageView.builder(controller: pc, itemCount: photos.length, onPageChanged: (p) => setState(() => page = p),
        itemBuilder: (_, i) => InteractiveViewer(minScale: 1, maxScale: 4,
            child: Center(child: AspectRatio(aspectRatio: 3 / 4, child: PhotoImage(photos[i]))))),
      SafeArea(child: Padding(padding: const EdgeInsets.all(AppSpacing.sm), child: Row(children: [
        AppIconButton(Icons.close_rounded, tooltip: 'Close', color: AppColors.onPrimary,
            onPressed: () => Navigator.pop(context)),
        const Spacer(),
        if (photos.length > 1) Row(children: [
          for (var i = 0; i < photos.length; i++) AnimatedContainer(duration: AppDurations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 3), width: i == page ? 18 : 6, height: 6,
            decoration: BoxDecoration(color: i == page ? AppColors.onPrimary : const Color(0x66FFFFFF),
                borderRadius: BorderRadius.circular(AppRadius.pill))),
        ]),
        const Spacer(),
        const SizedBox(width: 44),
      ]))),
    ]));
  }
}
