import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget for receipt attachment with camera and gallery options
class ReceiptAttachmentWidget extends StatefulWidget {
  final XFile? attachedReceipt;
  final Function(XFile?) onReceiptChanged;

  const ReceiptAttachmentWidget({
    Key? key,
    required this.attachedReceipt,
    required this.onReceiptChanged,
  }) : super(key: key);

  @override
  State<ReceiptAttachmentWidget> createState() =>
      _ReceiptAttachmentWidgetState();
}

class _ReceiptAttachmentWidgetState extends State<ReceiptAttachmentWidget> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _showCameraPreview = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      if (!kIsWeb) {
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Ignore unsupported features
        }
      }

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo inicializar la cámara'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      widget.onReceiptChanged(photo);
      setState(() => _showCameraPreview = false);
      _cameraController?.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar la foto'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        widget.onReceiptChanged(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar la imagen'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
    }
  }

  Future<void> _showCameraOptions() async {
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se requiere permiso de cámara'),
            backgroundColor: AppTheme.expenseRed,
          ),
        );
      }
      return;
    }

    await _initializeCamera();
    if (_isCameraInitialized) {
      setState(() => _showCameraPreview = true);
    }
  }

  void _removeReceipt() {
    widget.onReceiptChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_showCameraPreview && _isCameraInitialized) {
      return _buildCameraPreview(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recibo (Opcional)',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        widget.attachedReceipt != null
            ? _buildReceiptPreview(theme)
            : _buildAttachmentButtons(theme),
      ],
    );
  }

  Widget _buildCameraPreview(ThemeData theme) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(_cameraController!),
          ),
          Positioned(
            bottom: 2.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  onPressed: () {
                    setState(() => _showCameraPreview = false);
                    _cameraController?.dispose();
                    _cameraController = null;
                    _isCameraInitialized = false;
                  },
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.incomeGold,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera',
                      color: AppTheme.primaryBackgroundDark,
                      size: 32,
                    ),
                  ),
                  onPressed: _capturePhoto,
                ),
                SizedBox(width: 12.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptPreview(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageWidget(
              imageUrl: widget.attachedReceipt!.path,
              width: 20.w,
              height: 20.w,
              fit: BoxFit.cover,
              semanticLabel: 'Vista previa del recibo adjunto',
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recibo adjunto',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  widget.attachedReceipt!.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'delete',
              color: AppTheme.expenseRed,
              size: 24,
            ),
            onPressed: _removeReceipt,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showCameraOptions,
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            label: Text('Cámara'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: CustomIconWidget(
              iconName: 'photo_library',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            label: Text('Galería'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
