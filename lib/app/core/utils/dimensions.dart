// set the common devices dimensions here for mobile/ desktop
const mobileWidth = 600;

class AppDimensions {
  static bool _isUltraWideLayout = false;
  static set setUltraWideLayout(bool value) {
    _isUltraWideLayout = value;
    _isWideLayout = false;
    _isNarrowLayout = false;
    _isNarrowUltraLayout = false;
  }

  static bool get getUltraWideLayout => _isUltraWideLayout;

  static bool _isWideLayout = false;
  static set setWideLayout(bool value) {
    _isUltraWideLayout = false;
    _isWideLayout = value;
    _isNarrowLayout = false;
    _isNarrowUltraLayout = false;
  }
  static bool get getWideLayout => _isWideLayout;

  static bool _isNarrowLayout = false;
  static set setNarrowLayout(bool value) {
    _isUltraWideLayout = false;
    _isWideLayout = false;
    _isNarrowLayout = value;
    _isNarrowUltraLayout = false;
  }
  static bool get getNarrowLayout => _isNarrowLayout;

  static bool _isNarrowUltraLayout = false;
  static set setNarrowUltraLayout(bool value) {
    _isUltraWideLayout = false;
    _isWideLayout = false;
    _isNarrowLayout = false;
    _isNarrowUltraLayout = value;
  }
  static bool get getNarrowUltraLayout => _isNarrowUltraLayout;
}
