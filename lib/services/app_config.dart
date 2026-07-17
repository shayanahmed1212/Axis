// Static app constants — centralising these avoids magic strings
/// scattered across screens and makes version bumps a one-line change.
class AppConfig {
  static const String appName = 'Axis';
  static const String appVersion = '1.0.0';
  static const bool isDebug = bool.fromEnvironment('dart.vm.product');
}
