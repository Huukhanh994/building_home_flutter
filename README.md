BuildHome VN — Flutter (iOS + Android)
Project location: /Users/khanhho/buildhome_flutter/

To run

cd /Users/khanhho/buildhome_flutter
flutter pub get
flutter run          # picks connected device
flutter run -d ios   # iOS Simulator
flutter run -d android  # Android Emulator
Project structure

buildhome_flutter/
├── pubspec.yaml                  ← dependencies
├── lib/
│   ├── main.dart                 ← app entry point
│   ├── theme/app_theme.dart      ← colors, typography (Be Vietnam Pro)
│   ├── models/
│   │   ├── house_type.dart       ← 5 house types + cost/m²
│   │   ├── project_model.dart
│   │   ├── material_estimate.dart
│   │   └── house_template.dart
│   ├── services/
│   │   ├── material_calculator.dart  ← all formulas
│   │   └── pdf_exporter.dart         ← A4 PDF with Noto Sans Vietnamese
│   ├── data/template_data.dart   ← 7 sample templates
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── calculator_screen.dart
│   │   ├── results_screen.dart
│   │   ├── templates_screen.dart
│   │   └── template_detail_screen.dart
│   └── widgets/app_card.dart
├── android/                      ← ready for Android
├── ios/                          ← ready for iOS
└── test/widget_test.dart         ← unit tests for calculator
Dependencies used
Package	Purpose
google_fonts	Be Vietnam Pro font
pdf + printing	PDF generation + share/print
intl	VND number formatting
share_plus + path_provider	Share PDF file
provider	State management (extensible)
