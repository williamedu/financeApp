// lib/core/app_export.dart

// 1. Exporta Material para que esté disponible en toda la app
export 'package:flutter/material.dart';

// 2. Exporta tus Widgets y Tema (esto ya lo tenías y está bien)
export '../widgets/custom_icon_widget.dart';
export '../widgets/custom_image_widget.dart';
export '../theme/app_theme.dart';
export '../routes/app_routes.dart';

// NOTA: He eliminado 'connectivity_plus' y 'google_fonts' de aquí 
// porque google_fonts ya se usa dentro de app_theme.dart 
// y connectivity_plus no lo tenemos instalado.