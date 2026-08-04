import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard text input used across VaultKey.
///
/// - surface-container background
/// - Optional left icon (transitions to primary on focus)
/// - Optional right action (copy, visibility toggle, etc.)
/// - JetBrains Mono styling for password fields
class VaultInput extends StatefulWidget {
  const VaultInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixAction,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.isCode = false,
    this.textAlign = TextAlign.start,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixAction;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final bool isCode;
  final TextAlign textAlign;

  @override
  State<VaultInput> createState() => _VaultInputState();
}

class _VaultInputState extends State<VaultInput> {
  late final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = widget.isCode
        ? theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurface,
            letterSpacing: widget.obscureText ? 0.3 * 14 : 0.2 * 14,
          )
        : theme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurface);

    final hintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
    );

    Widget? prefix;
    if (widget.prefixIcon != null) {
      prefix = Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: Icon(
          widget.prefixIcon,
          size: 20,
          color: _isFocused ? AppTheme.primary : AppTheme.onSurfaceVariant,
        ),
      );
    }

    Widget? suffix;
    if (widget.obscureText) {
      suffix = IconButton(
        icon: Icon(
          _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppTheme.onSurfaceVariant,
        ),
        onPressed: () => setState(() => _obscure = !_obscure),
      );
    } else if (widget.suffixAction != null) {
      suffix = widget.suffixAction;
    }

    return TextField(
      focusNode: _focusNode,
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      textAlign: widget.textAlign,
      style: textStyle,
      cursorColor: AppTheme.primary,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppTheme.surfaceContainer,
        hintText: widget.hintText,
        hintStyle: hintStyle,
        labelText: widget.labelText,
        labelStyle: theme.textTheme.labelSmall?.copyWith(
          color: AppTheme.onSurfaceVariant,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1),
        ),
      ),
    );
  }
}
