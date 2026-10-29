import 'package:flutter/material.dart';
import '../data/profile_store.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/photo_grid.dart';
import '../widgets/profile_bits.dart';

/// Add, reorder, replace, remove and pick the main photo for the signed-in user.
class ManagePhotosScreen extends StatelessWidget {
  const ManagePhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = currentUser.photos;
    return Scaffold(
      appBar: AppBar(title: const Text('Photos'), actions: [
        ListenableBuilder(listenable: photos, builder: (_, __) => Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: InterestChip('${photos.count}/${PhotoManager.maxPhotos}', selected: photos.isFull))),
      ]),
      body: ListView(padding: const EdgeInsets.all(AppSpacing.page), children: [
        Text('Drag to reorder · tap a photo for more options', style: AppText.bodySmall),
        const SizedBox(height: AppSpacing.md),
        PhotoGrid(manager: photos, enforceMinimum: true, onAdd: () => addPhotos(context, photos),
            onPhotoTap: (p) => showPhotoOptions(context, photos, p, enforceMinimum: true)),
        const SizedBox(height: AppSpacing.xl),
        ListenableBuilder(listenable: photos, builder: (_, __) {
          final main = photos.main;
          return AppCard(child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(AppRadius.standardCard), child: main == null
                ? Container(width: 48, height: 64, color: AppColors.secondary)
                : PhotoImage(main, width: 48, height: 64)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.star_rounded, size: 16, color: AppColors.accent), const SizedBox(width: AppSpacing.xs),
                Text('Main photo', style: AppText.labelLarge),
              ]),
              Text('It’s the first thing people see in Discover and your chats. '
                  'Drag any photo into the big slot to change it.', style: AppText.bodySmall),
            ])),
          ]));
        }),
        const SizedBox(height: AppSpacing.md),
        AppCard(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.verified_user_outlined, color: AppColors.info, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text('Profiles with ${PhotoManager.maxPhotos} clear photos get noticeably more matches. '
              'Keep at least ${PhotoManager.minPhotos} photos on your profile.', style: AppText.bodySmall)),
        ])),
        const SizedBox(height: AppSpacing.xl),
        ListenableBuilder(listenable: photos, builder: (_, __) => AppButton(
          photos.isFull ? 'All ${PhotoManager.maxPhotos} slots filled' : 'Add photos',
          icon: Icons.add_photo_alternate_outlined, variant: AppButtonVariant.secondary,
          onPressed: photos.isFull ? null : () => addPhotos(context, photos))),
      ]));
  }
}
