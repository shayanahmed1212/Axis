// Axis Design Tokens — Typography
// Space Grotesk for display/headlines: technical character, geometric precision.
// Inter for body/UI: tabular figures, neutral clarity, functional complement.
class AppTypography {
  // Display font — restrained personality for headlines and the app name
  static const String displayFamily = 'Space Grotesk';

  // Body font — justified by tabular figures and neutral clarity
  static const String bodyFamily = 'Inter';

  // Legacy alias — prefer displayFamily/bodyFamily
  static const String fontFamily = bodyFamily;

  // Display — used with restraint: app name, screen titles, dashboard heading
  static const double displaySize = 28.0;
  static const int displayWeight = 700;
  static const double displayLetterSpacing = -0.5;

  // Headline — section headers, screen titles
  static const double headlineSize = 20.0;
  static const int headlineWeight = 600;
  static const double headlineLetterSpacing = -0.3;

  // Card title — task titles, prominent labels
  static const double cardTitleSize = 16.0;
  static const int cardTitleWeight = 500;
  static const double cardTitleLetterSpacing = 0;

  // Body — descriptions, form text, general UI
  static const double bodySize = 15.0;
  static const int bodyWeight = 400;
  static const double bodyLetterSpacing = 0;

  // Body small — secondary info, metadata
  static const double bodySmSize = 13.0;
  static const int bodySmWeight = 400;
  static const double bodySmLetterSpacing = 0;

  // Caption — labels, timestamps, priority pills
  static const double captionSize = 11.0;
  static const int captionWeight = 500;
  static const double captionLetterSpacing = 0.3;

  // Button — all buttons, slightly wider tracking for legibility
  static const double buttonSize = 14.0;
  static const int buttonWeight = 600;
  static const double buttonLetterSpacing = 0.2;

  // Legacy aliases
  static const double displayMdSize = displaySize;
  static const int displayMdWeight = displayWeight;
  static const double displayMdLetterSpacing = displayLetterSpacing;
}
