import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failures.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/body_factory_mark.dart';
import '../../../core/widgets/brand_backdrop.dart';
import '../../../data/models/models.dart';
import '../../auth/controllers/auth_session_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/capacity_card.dart';
import '../widgets/home_events_sliver.dart';

/// The Home tab: how busy the gym is, then what is on.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  /// True while this tab is the one on screen.
  ///
  /// Read from [TickerMode], which the tab shell already switches off for the
  /// branches it is keeping alive in the background. That makes it the honest
  /// answer to "is anyone looking at this?" without a second source of truth
  /// to keep in sync.
  bool _isVisible = true;

  bool _isForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isVisible = TickerMode.valuesOf(context).enabled;
    _syncPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    _syncPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The timer runs only when the tab is on screen *and* the app is in front.
  /// Either one being false means nobody can see the bar, so refreshing it
  /// only burns battery and, later, real requests.
  void _syncPolling() {
    ref
        .read(capacityControllerProvider.notifier)
        .setPolling(_isVisible && _isForeground);
  }

  Future<void> _refresh() async {
    ref.invalidate(homeEventsProvider);
    await Future.wait<void>(<Future<void>>[
      ref.read(capacityControllerProvider.notifier).refresh(),
      // Waits for the fresh fetch, so the spinner stays until both are in.
      ref.read(homeEventsProvider.future),
    ]);
  }

  Future<void> _cycleDebugLevel() async {
    final OccupancyLevel? level = await ref
        .read(capacityControllerProvider.notifier)
        .cycleForcedLevel();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: Text(
          level == null ? 'Occupancy: live data' : 'Occupancy: ${level.label}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<GymCapacity> capacity = ref.watch(
      capacityControllerProvider,
    );
    final AsyncValue<List<GymEvent>> events = ref.watch(homeEventsProvider);
    final Member? member = ref.watch(authSessionProvider).valueOrNull?.member;

    return BrandBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.accent,
            backgroundColor: AppColors.brandSurface,
            child: CustomScrollView(
              // Without this a short list cannot be dragged, and
              // pull-to-refresh stops working exactly when the gym has
              // nothing on.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    AppSpacing.lg,
                    AppSpacing.screenH,
                    AppSpacing.xl,
                  ),
                  sliver: SliverList.list(
                    children: <Widget>[
                      _HomeHeader(member: member),
                      const SizedBox(height: AppSpacing.xl),
                      _capacitySection(capacity),
                      const SizedBox(height: AppSpacing.section),
                      const _SectionHeading(
                        title: "What's on",
                        subtitle: 'Events and offers at Body Factory',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
                SliverPadding(
                  // Clears the bottom navigation bar, which the scroll view
                  // runs underneath.
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenH,
                    0,
                    AppSpacing.screenH,
                    AppSpacing.xxxl,
                  ),
                  sliver: HomeEventsSliver(
                    events: events,
                    onRetry: () => ref.invalidate(homeEventsProvider),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _capacitySection(AsyncValue<GymCapacity> capacity) {
    return capacity.when(
      // A refresh keeps the last reading on screen instead of collapsing back
      // to the skeleton — the number is still true until the new one lands.
      skipLoadingOnRefresh: true,
      loading: () => const CapacityCardSkeleton(),
      error: (Object error, StackTrace _) => CapacityCardError(
        message: error is Failure
            ? error.message
            : "We couldn't check how busy the gym is.",
        onRetry: () => ref.invalidate(capacityControllerProvider),
      ),
      data: (GymCapacity value) => CapacityCard(
        capacity: value,
        onLongPress: AppConfig.enableDevTools ? _cycleDebugLevel : null,
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.member});

  final Member? member;

  /// Egypt runs late — the gym's peak is 6–9 PM — so "evening" starts at 5
  /// rather than the usual 6.
  String get _greeting {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final String? name = member?.username;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _greeting,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.brandMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                name ?? 'Welcome back',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.cream,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        const BodyFactoryMark(size: 40),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            // A short orange rule instead of an icon: it marks the section
            // without adding another shape to the screen.
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.cream),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.lg - 1),
          child: Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.brandMuted),
          ),
        ),
      ],
    );
  }
}
