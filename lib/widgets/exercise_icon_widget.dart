import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../repository/model/exercise_type.dart';

class ExerciseIconWidget extends StatelessWidget {
  final ExerciseType exerciseType;
  final double? width;
  final double? height;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const ExerciseIconWidget({
    super.key,
    required this.exerciseType,
    this.width,
    this.height,
    this.size = 24,
    this.color,
    this.fit = BoxFit.contain,
  });

  factory ExerciseIconWidget.fromName(
    String name, {
    Key? key,
    double? width,
    double? height,
    double? size = 24,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return ExerciseIconWidget(
      key: key,
      exerciseType: ExerciseTypeExtension.fromString(name),
      width: width,
      height: height,
      size: size,
      color: color,
      fit: fit,
    );
  }

  double get _opticalScale {
    switch (exerciseType) {
      case ExerciseType.pushup:
        return 0.80; // Balanced optical weight for wide horizontal pushup
      case ExerciseType.squat:
        return 0.95;
      case ExerciseType.jumpingJack:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size ?? 24.0;
    final effectiveHeight = height ?? size ?? 24.0;
    final scale = _opticalScale;

    return SizedBox(
      width: effectiveWidth,
      height: effectiveHeight,
      child: Center(
        child: SvgPicture.asset(
          exerciseType.assetPath,
          width: effectiveWidth * scale,
          height: effectiveHeight * scale,
          fit: fit,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
        ),
      ),
    );
  }
}
