import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/premium_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  await PremiumService.instance.init();
  runApp(const BuildHomeApp());
}

class BuildHomeApp extends StatefulWidget {
  const BuildHomeApp({super.key});

  @override
  State<BuildHomeApp> createState() => _BuildHomeAppState();
}

class _BuildHomeAppState extends State<BuildHomeApp> {
  @override
  void dispose() {
    PremiumService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildHome VN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
