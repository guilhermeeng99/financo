import 'package:app_core/app_core.dart';
import 'package:flutter/foundation.dart';

class WidgetModuleProvider<T extends Module> extends StatefulWidget {
  const WidgetModuleProvider({
    required this.module,
    required this.child,
    super.key,
  });

  final T module;
  final Widget Function() child;

  @override
  State<WidgetModuleProvider> createState() => WidgetModuleProviderState();
}

class WidgetModuleProviderState<T extends Module>
    extends State<WidgetModuleProvider> {
  @override
  void initState() {
    super.initState();
    Modular.bindModule(widget.module);
    if (kDebugMode) print('-- ${widget.module.runtimeType} INITIALIZED');
  }

  @override
  void dispose() {
    Modular.unbindModule(type: widget.module.runtimeType.toString());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child();
  }
}
