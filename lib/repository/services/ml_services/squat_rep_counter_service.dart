import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../exercise/base_counter_service.dart';
import 'squat_validation_service.dart';

enum _SquatPhase { standing, descending, bottom, ascending }

class SquatRepCounterService extends BaseCounterService {
  static const double _kneeStandingMin = 155.0;
  static const double _kneeDescentTrigger = 148.0;
  static const double _kneeDepthRequired = 120.0;

  static const double _kneeAscendTrigger = 130.0;
  static const double _kneeStandingRestored = 150.0;

  static const double _hipAngleAtBottomMax = 150.0;
  static const double _trunkLeanMax = 65.0;

  static const Duration _minRepDuration = Duration(milliseconds: 700);
  static const int _minBottomFrames = 2;
  static const int _smoothingWindow = 3;

  int _repCount = 0;
  _SquatPhase _phase = _SquatPhase.standing;
  DateTime? _lastRepTime;
  int _bottomFrameCount = 0;

  final List<double> _kneeAngleBuffer = [];
  final List<double> _hipAngleBuffer = [];
  final List<double> _trunkAngleBuffer = [];

  final SquatValidationService _metricsService = SquatValidationService();

  @override
  int get repCount => _repCount;

  double? get currentKneeAngle =>
      _kneeAngleBuffer.isEmpty ? null : _smoothed(_kneeAngleBuffer);

  _SquatPhase get currentPhase => _phase;

  @override
  void reset() {
    _repCount = 0;
    _phase = _SquatPhase.standing;
    _lastRepTime = null;
    _bottomFrameCount = 0;
    _kneeAngleBuffer.clear();
    _hipAngleBuffer.clear();
    _trunkAngleBuffer.clear();
  }

  @override
  bool isSetupValid(List<Pose> poses) {
    if (poses.isEmpty) return false;
    final metrics = _metricsService.getSquatMetrics(poses.first);
    if (metrics == null) return false;
    return metrics.kneeAngle >= _kneeStandingMin - 20 &&
        metrics.trunkAngle < _trunkLeanMax;
  }

  @override
  int processLandmarks(List<Pose> poses) {
    if (poses.isEmpty) return _repCount;

    final metrics = _metricsService.getSquatMetrics(poses.first);
    if (metrics == null) return _repCount;

    _pushToBuffers(metrics);

    if (metrics.trunkAngle > _trunkLeanMax) return _repCount;

    final knee = _smoothed(_kneeAngleBuffer);
    final hip = _smoothed(_hipAngleBuffer);

    _updateFSM(knee, hip);
    return _repCount;
  }

  void _pushToBuffers(SquatMetrics m) {
    _push(_kneeAngleBuffer, m.kneeAngle);
    _push(_hipAngleBuffer, m.hipAngle);
    _push(_trunkAngleBuffer, m.trunkAngle);
  }

  void _push(List<double> buffer, double value) {
    buffer.add(value);
    if (buffer.length > _smoothingWindow) buffer.removeAt(0);
  }

  double _smoothed(List<double> buffer) {
    if (buffer.isEmpty) return 0;
    return buffer.reduce((a, b) => a + b) / buffer.length;
  }

  void _updateFSM(double knee, double hip) {
    switch (_phase) {
      case _SquatPhase.standing:
        if (knee < _kneeDescentTrigger) {
          _phase = _SquatPhase.descending;
          _bottomFrameCount = 0;
        }

      case _SquatPhase.descending:
        if (knee < _kneeDepthRequired) {
          _bottomFrameCount++;
          if (_bottomFrameCount >= _minBottomFrames) {
            if (hip <= _hipAngleAtBottomMax) {
              _phase = _SquatPhase.bottom;
            }
          }
        } else if (knee > _kneeStandingMin) {
          _phase = _SquatPhase.standing;
          _bottomFrameCount = 0;
        }

      case _SquatPhase.bottom:
        if (knee > _kneeAscendTrigger) {
          _phase = _SquatPhase.ascending;
        }

      case _SquatPhase.ascending:
        if (knee >= _kneeStandingRestored) {
          final now = DateTime.now();
          final timeSinceLast = _lastRepTime == null
              ? _minRepDuration + const Duration(seconds: 1)
              : now.difference(_lastRepTime!);

          if (timeSinceLast >= _minRepDuration) {
            _repCount++;
            _lastRepTime = now;
          }

          _phase = _SquatPhase.standing;
          _bottomFrameCount = 0;
        } else if (knee < _kneeDepthRequired) {
          _phase = _SquatPhase.bottom;
        }
    }
  }
}
