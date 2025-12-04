import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart'; // Importante para el nuevo diseño
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantenemos tu inicialización de Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Bloquear orientación vertical para mejor experiencia móvil
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const FinanceFlowApp());
}

class FinanceFlowApp extends StatelessWidget {
  const FinanceFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sizer envuelve toda la app para que funcionen las medidas 10.h, 4.w, etc.
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'FinanceFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark, // Forzamos modo oscuro como en el diseño
          // Configuración de Rutas
          initialRoute: AppRoutes.initial,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
