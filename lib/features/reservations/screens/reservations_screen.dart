import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../controllers/reservations_controller.dart';
import '../widgets/classes_tab.dart';
import '../widgets/my_reservations_tab.dart';
import '../widgets/trainers_tab.dart';

/// The Reservations tab: trainers, classes, and what the member has booked.
///
/// Three tabs rather than a menu of cards that push screens — both catalogues
/// are one tap away, and each keeps its own scroll position when you switch.
class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched here so the count in the tab label is live: booking a class on
    // the middle tab updates the badge without visiting the third one.
    final int bookedCount =
        ref.watch(myReservationViewsProvider).valueOrNull?.length ?? 0;

    return BrandBackdrop(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                const _Header(),
                _Tabs(bookedCount: bookedCount),
                const Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      TrainersTab(),
                      ClassesTab(),
                      MyReservationsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.lg,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Reservations',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.cream,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Book a trainer or join a class',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.brandMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.bookedCount});

  final int bookedCount;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      // Left-aligned and scrollable so "Booked (2)" can grow a digit without
      // squeezing the other two labels.
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH - 4),
      indicatorColor: AppColors.accent,
      indicatorWeight: 2.5,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.brandLine,
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.brandHint,
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.labelLarge,
      splashBorderRadius: BorderRadius.circular(AppRadius.md),
      tabs: <Widget>[
        const Tab(text: 'Trainers'),
        const Tab(text: 'Classes'),
        Tab(text: bookedCount == 0 ? 'Booked' : 'Booked ($bookedCount)'),
      ],
    );
  }
}
