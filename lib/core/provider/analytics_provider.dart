import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repository/model/analytics_models.dart';
import '../../repository/services/analytics/analytics_calculator.dart';
import 'workout_provider.dart';

export '../../repository/model/analytics_models.dart';

class AnalyticsTimeFilterNotifier extends Notifier<AnalyticsTimeFilter> {
  @override
  AnalyticsTimeFilter build() => AnalyticsTimeFilter.sevenDays;

  void setFilter(AnalyticsTimeFilter filter) {
    state = filter;
  }
}

final analyticsFilterProvider =
    NotifierProvider<AnalyticsTimeFilterNotifier, AnalyticsTimeFilter>(
  AnalyticsTimeFilterNotifier.new,
);

final analyticsDataProvider = Provider<AnalyticsData>((ref) {
  final allWorkouts = ref.watch(workoutProvider);
  final filter = ref.watch(analyticsFilterProvider);

  return AnalyticsCalculator.compute(
    allWorkouts: allWorkouts,
    filter: filter,
  );
});
