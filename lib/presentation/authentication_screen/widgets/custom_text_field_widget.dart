import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Custom text field widget for authentication forms
class CustomTextFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String iconName;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CustomTextFieldWidget({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.iconName,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomTextFieldWidget> createState() => _CustomTextFieldWidgetState();
}

class _CustomTextFieldWidgetState extends State<CustomTextFieldWidget> {
  bool _obscureText = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _validateField(String value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.isPassword && _obscureText,
          onChanged: (value) {
            _validateField(value);
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: widget.iconName,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: CustomIconWidget(
                      iconName: _obscureText ? 'visibility_off' : 'visibility',
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            errorText: _errorText,
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
