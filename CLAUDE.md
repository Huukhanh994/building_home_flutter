# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run on connected device/emulator
flutter run

# Build release APK
flutter build apk --obfuscate --split-debug-info=./debug-info/

# Analyze code
flutter analyze

# Format all Dart files
dart format .

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Architecture

**BuildHome VN** is a Vietnamese home construction assistant app. It estimates building materials and costs from user-entered dimensions, and lets users browse house design templates.

### Navigation flow

`HomeScreen` → three entry points via `Navigator.push`:
- `CalculatorScreen` → `ResultsScreen` (manual input → material estimate)
- `PhotoCalculatorScreen` (camera/image picker → manual input → material estimate)
- `TemplatesScreen` → `TemplateDetailScreen`

No named routes; all navigation uses `MaterialPageRoute` directly.

### Data flow for material calculation

1. User fills `CalculatorScreen` (width, length, floors, `HouseType`)
2. `ProjectModel` is assembled from form fields
3. `MaterialCalculator.calculate(project)` applies fixed Vietnamese construction ratios (steel 90 kg/m², concrete 0.25 m³/m², etc.) and returns a `MaterialEstimate`
4. `ResultsScreen` renders the estimate and can export via `PdfExporter.generate(estimate)` → `Uint8List` (no file I/O, shared via `share_plus`)

### Calculation recipe

All unit costs and material ratios live in two places:
- **`lib/models/house_type.dart`** — `HouseType` enum holds `costPerM2` (VND) per construction type
- **`lib/services/material_calculator.dart`** — static method with all multipliers (steel, concrete, cement, sand, stone, bricks, cost splits)

To update construction cost estimates or material ratios, edit those two files.

### Key files

| File | Purpose |
|------|---------|
| `lib/services/material_calculator.dart` | All calculation logic and ratios |
| `lib/models/house_type.dart` | House type enum with cost-per-m² values |
| `lib/models/material_estimate.dart` | Output data class (areas + quantities + costs) |
| `lib/models/project_model.dart` | Input data class |
| `lib/data/template_data.dart` | Static list of house design templates |
| `lib/services/pdf_exporter.dart` | PDF generation using `pdf` + `printing` packages |
| `lib/theme/app_theme.dart` | `AppTheme.light` + `AppColors` constants |
| `lib/widgets/house_layout_painter.dart` | `CustomPainter` for floor plan rendering in PDF |

### State management

No external state management library. Screens use `StatefulWidget` with local state; data is passed between screens via constructor arguments. `provider` is listed as a dependency but not yet wired up.

### PDF export

`PdfExporter.generate()` loads `NotoSans` fonts via `PdfGoogleFonts` (requires network on first run) and returns raw bytes. Sharing is handled by the caller using `share_plus`. No file is written to disk.

### Android configuration

- Min SDK: set in `android/app/build.gradle`
- File sharing via `FileProvider` configured in `android/app/src/main/res/xml/file_paths.xml`
- Camera and storage permissions declared in `AndroidManifest.xml`

## Language

The app UI is in Vietnamese. All user-facing strings, labels, and template content are written in Vietnamese and should stay that way.
