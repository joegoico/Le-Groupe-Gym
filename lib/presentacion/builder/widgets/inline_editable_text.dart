/// Widget reutilizable que muestra un Text y al hacer doble tap
/// lo convierte en un TextField editable. Al presionar Done o perder foco,
/// llama a [onChanged] con el nuevo valor.
library;

import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';

class InlineEditableText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final ValueChanged<String> onChanged;

  const InlineEditableText({
    super.key,
    required this.text,
    required this.style,
    required this.onChanged,
  });

  @override
  State<InlineEditableText> createState() => _InlineEditableTextState();
}

class _InlineEditableTextState extends State<InlineEditableText> {
  bool _editing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant InlineEditableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      _commitEdit();
    }
  }

  void _startEditing() {
    setState(() {
      _editing = true;
      _controller.text = widget.text;
    });
    // Esperar al siguiente frame para que el TextField se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _commitEdit() {
    final newText = _controller.text.trim();
    setState(() => _editing = false);
    if (newText.isNotEmpty && newText != widget.text) {
      widget.onChanged(newText);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return SizedBox(
        height: 28,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: widget.style,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _commitEdit(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            filled: true,
            fillColor: AppColors.surfaceContainerHigh,
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(AppRadius.sm),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(widget.text, style: widget.style)),
        IconButton(
          onPressed: _startEditing,
          tooltip: 'Editar nombre',
          icon: const Icon(Icons.edit_rounded),
          iconSize: 17,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          style: IconButton.styleFrom(
            padding: const EdgeInsets.all(6),
            minimumSize: const Size(32, 32),
            hoverColor: AppColors.onSurfaceVariant.withValues(alpha: 0.12),
            highlightColor: AppColors.onSurfaceVariant.withValues(alpha: 0.2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.sm),
            ),
          ),
        ),
      ],
    );
  }
}
