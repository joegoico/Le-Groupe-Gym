import 'dart:async';
import 'package:flutter/material.dart';
import 'package:le_groupe_gym/core/app_theme.dart';
import 'package:le_groupe_gym/data/models/alumno_model.dart';
import 'package:le_groupe_gym/data/repositories/alumno_repository.dart';

class AlumnoSelector extends StatefulWidget {
  final AlumnoRepository alumnoRepository;
  final Alumno? alumnoSeleccionado;
  final ValueChanged<Alumno?> onAlumnoChanged;

  const AlumnoSelector({
    super.key,
    required this.alumnoRepository,
    required this.alumnoSeleccionado,
    required this.onAlumnoChanged,
  });

  @override
  State<AlumnoSelector> createState() => _AlumnoSelectorState();
}

class _AlumnoSelectorState extends State<AlumnoSelector> {
  Timer? _debounce;
  List<Alumno> _suggestions = [];
  bool _isLoading = false;

  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.alumnoSeleccionado != null) {
      _textController.text = widget.alumnoSeleccionado!.nombreCompleto;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AlumnoSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.alumnoSeleccionado != oldWidget.alumnoSeleccionado) {
      _textController.text = widget.alumnoSeleccionado?.nombreCompleto ?? '';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // 👇 delay para que el onTap se ejecute antes de cerrar
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _removeOverlay();
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _suggestions = [];
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isLoading = true);
      try {
        final results = await widget.alumnoRepository.searchAlumnos(
          query.trim(),
        );
        if (mounted) {
          _suggestions = results;
          _isLoading = false;
          setState(() {});
          _updateOverlay();
        }
      } catch (_) {
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  void _onAlumnoSelected(Alumno alumno) {
    _textController.text = alumno.nombreCompleto;
    _suggestions = [];
    _removeOverlay();
    _focusNode.unfocus();
    widget.onAlumnoChanged(alumno);
  }

  void _clearSelection() {
    _textController.clear();
    _suggestions = [];
    _removeOverlay();
    widget.onAlumnoChanged(null);
    setState(() {});
  }

  // ── Overlay management ──────────────────────────────────────────────

  void _updateOverlay() {
    _removeOverlay();
    if (_suggestions.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: AppColors.surfaceContainerHigh,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                itemBuilder: (_, index) {
                  final alumno = _suggestions[index];
                  //print("ALUMNO SELECCIONADO: ${alumno.nombreCompleto}");
                  return InkWell(
                    onTap: () => _onAlumnoSelected(alumno),
                    hoverColor: AppColors.onSurfaceVariant.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: index == 0
                        ? const BorderRadius.vertical(top: Radius.circular(8))
                        : index == _suggestions.length - 1
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          )
                        : BorderRadius.zero,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Text(
                        alumno.nombreCompleto,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Seleccionar alumno...',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          suffixIcon: _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _textController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: _clearSelection,
                  splashRadius: 16,
                )
              : const Icon(Icons.search, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blueAccent),
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerHighest,
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }
}
