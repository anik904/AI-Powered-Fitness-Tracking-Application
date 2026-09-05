import 'package:ai_fitness_tracker/repository/services/exercise/base_counter_service.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'pushup_validation_service.dart';

enum _PushupPhase { up, descending, bottom, ascending }

class PushupRepCounterService extends BaseCounterService {
  static const double _wristTopThreshold = 0.55;
  static const double _wristBottomThreshold = 0.28;
  static const double _wristRestoredThreshold = 0.50;
  static const double _elbowFlareMin = 0.15;

  static const double _maxPlankDeviation = 0.45;
  static const double _maxShoulderAsymmetry = 0.30;

  static const int _smoothingWindow = 4;
  static const int _minBottomFrames = 2;
  static const int _maxOutOfPosition = 15;
  static const Duration _minRepDuration = Duration(milliseconds: 700);

  int _repCount = 0;
  _PushupPhase _phase = _PushupPhase.up;
  DateTime? _lastRepTime;
  int _bottomFrameCount = 0;
  int _outOfPositionFrames = 0;
  double _bottomPlankDev = 0.0;
  double _bottomAsymmetry = 0.0;

  final List<double> _wristBuffer = [];
  final List<double> _flareBuffer = [];
  final List<double> _plankBuffer = [];

  final PushupValidationService _validationService = PushupValidationService();

  @override
  int get repCount => _repCount;

  @override
  void reset() {
    _repCount = 0;
    _phase = _PushupPhase.up;
    _lastRepTime = null;
    _bottomFrameCount = 0;
    _outOfPositionFrames = 0;
    _bottomPlankDev = 0.0;
    _bottomAsymmetry = 0.0;
    _wristBuffer.clear();
    _flareBuffer.clear();
    _plankBuffer.clear();
  }

  @override
  bool isSetupValid(List<Pose> poses) {
    if (poses.isEmpty) return false;
    final m = _validationService.getPushupMetrics(poses.first);
    if (m == null) return false;
    // Valid setup = in position + wrists are low
    return m.isInPushupPosition &&
        m.wristShoulderYRatio >= _wristTopThreshold - 0.15;
  }

  @override
  int processLandmarks(List<Pose> poses) {
    if (poses.isEmpty) return _repCount;

    final m = _validationService.getPushupMetrics(poses.first);
    if (m == null) return _repCount;

    _push(_wristBuffer, m.wristShoulderYRatio);
    _push(_flareBuffer, m.elbowFlareRatio);
    _push(_plankBuffer, m.plankDeviation.abs());

    if (!m.isInPushupPosition) {
      _outOfPositionFrames++;
      if (_outOfPositionFrames >= _maxOutOfPosition) {
        _softReset();
      }
      return _repCount;
    }

    _outOfPositionFrames = 0;

    final wrist = _smoothed(_wristBuffer);
    final flare = _smoothed(_flareBuffer);
    final plank = _smoothed(_plankBuffer);

    _updateFSM(wrist, flare, plank, m.shoulderAsymmetry);
    return _repCount;
  }

  void _softReset() {
    _phase = _PushupPhase.up;
    _bottomFrameCount = 0;
    _bottomPlankDev = 0.0;
    _bottomAsymmetry = 0.0;
  }

  void _push(List<double> buf, double v) {
    buf.add(v);
    if (buf.length > _smoothingWindow) buf.removeAt(0);
  }

  double _smoothed(List<double> buf) {
    if (buf.isEmpty) return 0;
    return buf.reduce((a, b) => a + b) / buf.length;
  }

  void _updateFSM(double wrist, double flare, double plank, double asymmetry) {
    switch (_phase) {
      case _PushupPhase.up:
        // Wrists moving toward shoulder level = started descending
        if (wrist < _wristTopThreshold) {
          _phase = _PushupPhase.descending;
          _bottomFrameCount = 0;
          _bottomPlankDev = 0.0;
          _bottomAsymmetry = 0.0;
        }

      case _PushupPhase.descending:
        if (wrist <= _wristBottomThreshold && flare >= _elbowFlareMin) {
          // Both signals agree: reached the bottom
          _bottomFrameCount++;
          _bottomPlankDev = plank;
          _bottomAsymmetry = asymmetry;
          if (_bottomFrameCount >= _minBottomFrames) {
            _phase = _PushupPhase.bottom;
          }
        } else if (wrist >= _wristTopThreshold) {
          // Went back up without reaching bottom — no count, reset
          _phase = _PushupPhase.up;
          _bottomFrameCount = 0;
        }

      case _PushupPhase.bottom:
        // Track worst form while at bottom
        _bottomPlankDev = _bottomPlankDev > plank ? _bottomPlankDev : plank;
        _bottomAsymmetry = _bottomAsymmetry > asymmetry
            ? _bottomAsymmetry
            : asymmetry;
        // Wrists rising = starting to come back up
        if (wrist > _wristBottomThreshold) {
          _phase = _PushupPhase.ascending;
        }

      case _PushupPhase.ascending:
        if (wrist >= _wristRestoredThreshold) {
          // Back at top — count if form was acceptable
          final formOk =
              _bottomPlankDev <= _maxPlankDeviation &&
              _bottomAsymmetry <= _maxShoulderAsymmetry;

          if (formOk) {
            final now = DateTime.now();
            final diff = _lastRepTime == null
                ? _minRepDuration + const Duration(seconds: 1)
                : now.difference(_lastRepTime!);
            if (diff >= _minRepDuration) {
              _repCount++;
              _lastRepTime = now;
            }
          }

          _phase = _PushupPhase.up;
          _bottomFrameCount = 0;
          _bottomPlankDev = 0.0;
          _bottomAsymmetry = 0.0;
        } else if (wrist <= _wristBottomThreshold) {
          // Went back down — return to bottom
          _phase = _PushupPhase.bottom;
        }
    }
  }
}
