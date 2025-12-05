import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_list_item_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/profile_toggle_item_widget.dart';

/// User Profile Screen for managing account settings, preferences, and app configuration
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // User data
  String _userName = 'María González';
  String _userEmail = 'maria.gonzalez@email.com';
  String _userPhone = '+52 55 1234 5678';
  final String _accountCreationDate = '15/03/2024';
  String? _avatarUrl;

  // Settings state
  bool _biometricEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkThemeEnabled = true;
  String _selectedCurrency = 'MXN';
  String _selectedDateFormat = 'DD/MM/YYYY';
  String _selectedLanguage = 'Español';

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from storage
  Future<void> _loadUserData() async {
    // Simulate loading user data
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _avatarUrl =
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop';
    });
  }

  /// Handle avatar edit
  Future<void> _handleEditAvatar() async {
    HapticFeedback.lightImpact();

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAvatarOptionsSheet(),
    );

    if (result != null) {
      if (result == 'camera') {
        await _pickImageFromCamera();
      } else if (result == 'gallery') {
        await _pickImageFromGallery();
      }
    }
  }

  /// Build avatar options bottom sheet
  Widget _buildAvatarOptionsSheet() {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Cambiar foto de perfil',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                'Tomar foto',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text(
                'Elegir de galería',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_avatarUrl != null)
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.expenseRed,
                  size: 6.w,
                ),
                title: Text(
                  'Eliminar foto',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.expenseRed,
                  ),
                ),
                onTap: () {
                  setState(() => _avatarUrl = null);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _avatarUrl = image.path;
        });
        _showSuccessMessage('Foto actualizada correctamente');
      }
    } catch (e) {
      _showErrorMessage('Error al tomar la foto');
    }
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _avatarUrl = image.path;
        });
        _showSuccessMessage('Foto actualizada correctamente');
      }
    } catch (e) {
      _showErrorMessage('Error al seleccionar la foto');
    }
  }

  /// Handle personal information edit
  void _handleEditPersonalInfo() {
    HapticFeedback.lightImpact();
    _showEditDialog(
      title: 'Editar información personal',
      fields: [
        {'label': 'Nombre', 'value': _userName, 'key': 'name'},
        {'label': 'Email', 'value': _userEmail, 'key': 'email'},
        {'label': 'Teléfono', 'value': _userPhone, 'key': 'phone'},
      ],
      onSave: (values) {
        setState(() {
          _userName = values['name'] ?? _userName;
          _userEmail = values['email'] ?? _userEmail;
          _userPhone = values['phone'] ?? _userPhone;
        });
        _showSuccessMessage('Información actualizada correctamente');
      },
    );
  }

  /// Handle password change
  void _handleChangePassword() {
    HapticFeedback.lightImpact();
    _showEditDialog(
      title: 'Cambiar contraseña',
      fields: [
        {
          'label': 'Contraseña actual',
          'value': '',
          'key': 'current',
          'obscure': true,
        },
        {
          'label': 'Nueva contraseña',
          'value': '',
          'key': 'new',
          'obscure': true,
        },
        {
          'label': 'Confirmar contraseña',
          'value': '',
          'key': 'confirm',
          'obscure': true,
        },
      ],
      onSave: (values) {
        if (values['new'] == values['confirm']) {
          _showSuccessMessage('Contraseña actualizada correctamente');
        } else {
          _showErrorMessage('Las contraseñas no coinciden');
        }
      },
    );
  }

  /// Handle currency selection
  void _handleCurrencySelection() {
    HapticFeedback.lightImpact();
    _showSelectionDialog(
      title: 'Seleccionar moneda',
      options: ['MXN', 'COP', 'ARS', 'USD', 'EUR'],
      currentValue: _selectedCurrency,
      onSelect: (value) {
        setState(() => _selectedCurrency = value);
        _showSuccessMessage('Moneda actualizada a $value');
      },
    );
  }

  /// Handle date format selection
  void _handleDateFormatSelection() {
    HapticFeedback.lightImpact();
    _showSelectionDialog(
      title: 'Formato de fecha',
      options: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
      currentValue: _selectedDateFormat,
      onSelect: (value) {
        setState(() => _selectedDateFormat = value);
        _showSuccessMessage('Formato de fecha actualizado');
      },
    );
  }

  /// Handle language selection
  void _handleLanguageSelection() {
    HapticFeedback.lightImpact();
    _showSelectionDialog(
      title: 'Seleccionar idioma',
      options: ['Español', 'English', 'Português'],
      currentValue: _selectedLanguage,
      onSelect: (value) {
        setState(() => _selectedLanguage = value);
        _showSuccessMessage('Idioma actualizado a $value');
      },
    );
  }

  /// Handle data export
  void _handleDataExport() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Exportar datos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Deseas exportar todos tus datos financieros? Se generará un archivo CSV con todas tus transacciones y presupuestos.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Datos exportados correctamente');
            },
            child: Text('Exportar'),
          ),
        ],
      ),
    );
  }

  /// Handle backup
  void _handleBackup() {
    HapticFeedback.lightImpact();
    _showSuccessMessage('Copia de seguridad creada correctamente');
  }

  /// Handle restore
  void _handleRestore() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Restaurar datos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Deseas restaurar tus datos desde la última copia de seguridad? Esto sobrescribirá tus datos actuales.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Datos restaurados correctamente');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
            ),
            child: Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  /// Handle clear cache
  void _handleClearCache() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Limpiar caché',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Deseas limpiar el caché de la aplicación? Esto puede mejorar el rendimiento.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Caché limpiado correctamente');
            },
            child: Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  /// Handle help center
  void _handleHelpCenter() {
    HapticFeedback.lightImpact();
    _showInfoMessage('Abriendo centro de ayuda...');
  }

  /// Handle contact support
  void _handleContactSupport() {
    HapticFeedback.lightImpact();
    _showInfoMessage('Abriendo soporte...');
  }

  /// Handle privacy policy
  void _handlePrivacyPolicy() {
    HapticFeedback.lightImpact();
    _showInfoMessage('Abriendo política de privacidad...');
  }

  /// Handle terms of service
  void _handleTermsOfService() {
    HapticFeedback.lightImpact();
    _showInfoMessage('Abriendo términos de servicio...');
  }

  /// Handle account deletion
  void _handleDeleteAccount() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Eliminar cuenta',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.expenseRed),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que deseas eliminar tu cuenta?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Esta acción es permanente y no se puede deshacer. Se eliminarán todos tus datos:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '• Todas tus transacciones\n• Todos tus presupuestos\n• Tu información personal\n• Tus preferencias',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Te recomendamos exportar tus datos antes de continuar.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.warningOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showFinalDeleteConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseRed,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// Show final delete confirmation
  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Confirmación final',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppTheme.expenseRed),
        ),
        content: Text(
          'Escribe "ELIMINAR" para confirmar la eliminación de tu cuenta.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage('Cuenta eliminada correctamente');
              Navigator.pushReplacementNamed(context, '/authentication-screen');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.expenseRed,
            ),
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// Handle logout
  void _handleLogout() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Cerrar sesión',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/authentication-screen');
            },
            child: Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  /// Show edit dialog
  void _showEditDialog({
    required String title,
    required List<Map<String, dynamic>> fields,
    required Function(Map<String, String>) onSave,
  }) {
    final controllers = <String, TextEditingController>{};
    for (var field in fields) {
      controllers[field['key']] = TextEditingController(
        text: field['value'] as String,
      );
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.map((field) {
              return Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: TextField(
                  controller: controllers[field['key']],
                  obscureText: field['obscure'] == true,
                  decoration: InputDecoration(
                    labelText: field['label'] as String,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (var controller in controllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final values = <String, String>{};
              controllers.forEach((key, controller) {
                values[key] = controller.text;
              });
              for (var controller in controllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
              onSave(values);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  /// Show selection dialog
  void _showSelectionDialog({
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String) onSelect,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final isSelected = option == currentValue;
            return ListTile(
              title: Text(
                option,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Theme.of(context).colorScheme.primary,
                      size: 5.w,
                    )
                  : null,
              onTap: () {
                Navigator.pop(context);
                onSelect(option);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Show success message
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successGreen,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.expenseRed,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Show info message
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'info',
              color: Theme.of(context).colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          title: 'Perfil',
          variant: CustomAppBarVariant.standard,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: 2.h),
              // Profile header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ProfileHeaderWidget(
                  userName: _userName,
                  userEmail: _userEmail,
                  accountCreationDate: _accountCreationDate,
                  avatarUrl: _avatarUrl,
                  onEditAvatar: _handleEditAvatar,
                ),
              ),
              SizedBox(height: 3.h),
              // Personal Information section
              ProfileSectionWidget(
                title: 'Información Personal',
                children: [
                  ProfileListItemWidget(
                    iconName: 'person',
                    title: 'Editar perfil',
                    subtitle: 'Nombre, email, teléfono',
                    onTap: _handleEditPersonalInfo,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Security section
              ProfileSectionWidget(
                title: 'Seguridad',
                children: [
                  ProfileListItemWidget(
                    iconName: 'lock',
                    title: 'Cambiar contraseña',
                    subtitle: 'Actualizar tu contraseña',
                    onTap: _handleChangePassword,
                  ),
                  ProfileToggleItemWidget(
                    iconName: 'fingerprint',
                    title: 'Autenticación biométrica',
                    subtitle: 'Face ID / Touch ID',
                    value: _biometricEnabled,
                    onChanged: (value) {
                      setState(() => _biometricEnabled = value);
                      _showSuccessMessage(
                        value ? 'Biometría activada' : 'Biometría desactivada',
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Preferences section
              ProfileSectionWidget(
                title: 'Preferencias',
                children: [
                  ProfileListItemWidget(
                    iconName: 'attach_money',
                    title: 'Moneda',
                    subtitle: _selectedCurrency,
                    onTap: _handleCurrencySelection,
                  ),
                  ProfileListItemWidget(
                    iconName: 'calendar_today',
                    title: 'Formato de fecha',
                    subtitle: _selectedDateFormat,
                    onTap: _handleDateFormatSelection,
                  ),
                  ProfileListItemWidget(
                    iconName: 'language',
                    title: 'Idioma',
                    subtitle: _selectedLanguage,
                    onTap: _handleLanguageSelection,
                  ),
                  ProfileToggleItemWidget(
                    iconName: 'notifications',
                    title: 'Notificaciones',
                    subtitle: 'Alertas y recordatorios',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _showSuccessMessage(
                        value
                            ? 'Notificaciones activadas'
                            : 'Notificaciones desactivadas',
                      );
                    },
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // App Settings section
              ProfileSectionWidget(
                title: 'Configuración de la App',
                children: [
                  ProfileToggleItemWidget(
                    iconName: 'dark_mode',
                    title: 'Tema oscuro',
                    subtitle: 'Activado por defecto',
                    value: _darkThemeEnabled,
                    onChanged: (value) {
                      setState(() => _darkThemeEnabled = value);
                      _showSuccessMessage(
                        value ? 'Tema oscuro activado' : 'Tema claro activado',
                      );
                    },
                  ),
                  ProfileListItemWidget(
                    iconName: 'file_download',
                    title: 'Exportar datos',
                    subtitle: 'Descargar tus datos en CSV',
                    onTap: _handleDataExport,
                  ),
                  ProfileListItemWidget(
                    iconName: 'backup',
                    title: 'Copia de seguridad',
                    subtitle: 'Respaldar tus datos',
                    onTap: _handleBackup,
                  ),
                  ProfileListItemWidget(
                    iconName: 'restore',
                    title: 'Restaurar datos',
                    subtitle: 'Recuperar desde respaldo',
                    onTap: _handleRestore,
                  ),
                  ProfileListItemWidget(
                    iconName: 'cleaning_services',
                    title: 'Limpiar caché',
                    subtitle: 'Liberar espacio',
                    onTap: _handleClearCache,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Support section
              ProfileSectionWidget(
                title: 'Soporte',
                children: [
                  ProfileListItemWidget(
                    iconName: 'help',
                    title: 'Centro de ayuda',
                    onTap: _handleHelpCenter,
                  ),
                  ProfileListItemWidget(
                    iconName: 'support_agent',
                    title: 'Contactar soporte',
                    onTap: _handleContactSupport,
                  ),
                  ProfileListItemWidget(
                    iconName: 'privacy_tip',
                    title: 'Política de privacidad',
                    onTap: _handlePrivacyPolicy,
                  ),
                  ProfileListItemWidget(
                    iconName: 'description',
                    title: 'Términos de servicio',
                    onTap: _handleTermsOfService,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Dangerous actions section
              ProfileSectionWidget(
                title: 'Zona de peligro',
                children: [
                  ProfileListItemWidget(
                    iconName: 'delete_forever',
                    title: 'Eliminar cuenta',
                    subtitle: 'Acción permanente',
                    onTap: _handleDeleteAccount,
                    isDangerous: true,
                    showDivider: false,
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Logout button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleLogout,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'logout',
                          color: theme.colorScheme.primary,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Cerrar sesión',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              // App version
              Text(
                'Versión 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedItem: CustomBottomBarItem.profile,
        onItemSelected: (item) {
          // Navigation handled by CustomBottomBar
        },
      ),
    );
  }
}
