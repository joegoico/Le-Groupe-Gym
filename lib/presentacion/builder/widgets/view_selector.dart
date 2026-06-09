import 'package:flutter/material.dart';

/// Widget de utilidad para aislar reconstrucciones (rebuilds).
/// Escucha un [listenable] (como un ChangeNotifier) y, cuando notifica,
/// evalúa [selector]. Solo si el valor retornado por [selector] cambia,
/// reconstruye el widget usando [builder].
/// Ideal para optimizar ChangeNotifier globales.
class ViewSelector<T> extends StatefulWidget {
  final Listenable listenable;
  final T Function() selector;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const ViewSelector({
    super.key,
    required this.listenable,
    required this.selector,
    required this.builder,
    this.child,
  });

  @override
  State<ViewSelector<T>> createState() => _ViewSelectorState<T>();
}

class _ViewSelectorState<T> extends State<ViewSelector<T>> {
  late T _value;

  @override
  void initState() {
    super.initState();
    _value = widget.selector();
    widget.listenable.addListener(_listener);
  }

  @override
  void didUpdateWidget(ViewSelector<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_listener);
      widget.listenable.addListener(_listener);
    }
    final newValue = widget.selector();
    if (newValue != _value) {
      _value = newValue;
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    final newValue = widget.selector();
    if (newValue != _value) {
      setState(() {
        _value = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value, widget.child);
  }
}
