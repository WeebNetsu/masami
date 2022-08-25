class Progress {
  double _progress = 0.00;
  double _increasePerStep = 0;
  String _currentStep = "";

  Progress(int steps, String intialStep) {
    _currentStep = intialStep;
    setStepCount(steps);
  }

  void increaseProgress(String? newStep) {
    if (_progress < 100) {
      _progress += _increasePerStep;
      _currentStep = newStep ?? _currentStep;
    }
  }

  double getProgress() {
    return _progress;
  }

  String getCurrentStep() {
    return _currentStep;
  }

  bool getProgressComplete() {
    return _progress >= 100;
  }

  void setStepCount(int steps) {
    if (steps != 0) _increasePerStep = 100 / steps;
  }

  void reset() {
    _currentStep = "";
    _progress = 0;
  }
}
