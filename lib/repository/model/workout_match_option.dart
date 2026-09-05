class WorkoutMatchOption {
  const WorkoutMatchOption({required this.reps, required this.minutes, required this.unit});

  final int reps;
  final double minutes;
  final String unit;

  String get label {
    final left = unit.toLowerCase() == 'sec' ? '$reps sec' : '$reps ${reps == 1 ? 'rep' : 'reps'}';
    return '$left = ${formatMinutes(minutes)} min';
  }
}

String formatMinutes(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1).replaceFirst('.0', '');
}
